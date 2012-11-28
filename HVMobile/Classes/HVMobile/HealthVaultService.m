//
//  HealthVaultService.m
//  HealthVault Mobile Library for iOS
//
// Copyright 2011 Microsoft Corp.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "HealthVaultService.h"
#import "MobilePlatform.h"
#import "WebTransport.h"
#import "WebResponse.h"
#import "HealthVaultRequest.h"
#import "HealthVaultResponse.h"
#import "Base64.h"
#import "DateTimeUtils.h"
#import "Provisioner.h"
#import "XmlTextReader.h"
#import "HealthVaultSettings.h"
#import "HealthVaultConfig.h"

@interface HealthVaultService (Private)

/// Generates the info section for the cast call.
/// @returns the generate info section.
- (NSString *)getCastCallInfoSection;

/// Refreshes the session token.
/// Makes a CAST call to get a new session token, 
/// and then re-issues the original request.
/// @param request - the original request.
- (void)refreshSessionToken: (HealthVaultRequest *)request;

/// Invokes the calling application's callback.
/// @param request - the request object.
/// @param response - the response object.
- (void)performAppCallBack: (HealthVaultRequest *)request
				  response: (HealthVaultResponse *)response;

@end


@implementation HealthVaultService

@synthesize healthServiceUrl = _healthServiceUrl;
@synthesize shellUrl = _shellUrl;
@synthesize authorizationSessionToken = _authorizationSessionToken;
@synthesize sharedSecret = _sharedSecret;
@synthesize sessionSharedSecret = _sessionSharedSecret;
@synthesize masterAppId = _masterAppId;
@synthesize language = _language;
@synthesize country = _country;
@synthesize appIdInstance = _appIdInstance;
@synthesize applicationCreationToken = _applicationCreationToken;
@synthesize records = _records;
@synthesize currentRecord = _currentRecord;

- (id)init {

	return [self initWithUrl: nil
			shellUrl: nil
			masterAppId: nil];
}

- (id)initWithDefaultUrl: (NSString *)masterAppId {
	
	return [self initWithUrl: HEALTH_VAULT_PLATFORM_URL
					shellUrl: HEALTH_VAULT_SHELL_URL
				 masterAppId: masterAppId];
}

- (id)initWithUrl: (NSString *)healthServiceUrl
		 shellUrl: (NSString *)shellUrl
	  masterAppId: (NSString *)masterAppId {

	if (self = [super init]) {

		self.healthServiceUrl = healthServiceUrl;
		self.shellUrl = shellUrl;
		self.masterAppId = masterAppId;

		self.language = DEFAULT_LANGUAGE;
		self.country = DEFAULT_COUNTRY;

		_records = [NSMutableArray new];
	}
	return self;
}


- (void)dealloc {

	self.healthServiceUrl = nil;
	self.shellUrl = nil;
	self.authorizationSessionToken = nil;
	self.sharedSecret = nil;
	self.sessionSharedSecret = nil;
	self.masterAppId = nil;
	self.language = nil;
	self.country = nil;
	self.appIdInstance = nil;
	self.applicationCreationToken = nil;
	self.records = nil;
	self.currentRecord = nil;

	[super dealloc];
}

#pragma mark Url Generating Logic

- (NSString *)getApplicationCreationUrl {

	CFStringRef tokenEncoded = CFURLCreateStringByAddingPercentEscapes(NULL,
			(CFStringRef)self.applicationCreationToken,
			NULL,
			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
			kCFStringEncodingUTF8);
	
	CFStringRef deviceNameEncoded = CFURLCreateStringByAddingPercentEscapes(NULL,
			(CFStringRef)[MobilePlatform deviceName],
			NULL,
			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
			kCFStringEncodingUTF8);

	NSString *queryString = [NSString stringWithFormat:@"?appid=%@&appCreationToken=%@&instanceName=%@&ismra=true",
			self.masterAppId, tokenEncoded, deviceNameEncoded];

	CFStringRef queryStringEncoded = CFURLCreateStringByAddingPercentEscapes(NULL,
			(CFStringRef)queryString,
			NULL,
			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
			kCFStringEncodingUTF8);

	NSString *appCreationUrl = [NSString stringWithFormat: @"%@/redirect.aspx?target=CREATEAPPLICATION&targetqs=%@",
			self.shellUrl, (NSString *)queryStringEncoded];

	CFRelease(tokenEncoded);
	CFRelease(deviceNameEncoded);
	CFRelease(queryStringEncoded);

	return appCreationUrl;
}

- (NSString *)getUserAuthorizationUrl {

	NSString *queryString = [NSString stringWithFormat: @"?appid=%@&ismra=true", self.appIdInstance];

	CFStringRef queryStringEncoded = CFURLCreateStringByAddingPercentEscapes(NULL,
			(CFStringRef)queryString,
			NULL,
			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
			kCFStringEncodingUTF8);

	NSString *userAuthUrl = [NSString stringWithFormat: @"%@/redirect.aspx?target=APPAUTH&targetqs=%@",
			self.shellUrl, (NSString *)queryStringEncoded];

	CFRelease(queryStringEncoded);

	return userAuthUrl;
}

#pragma mark Url Generating Logic End

#pragma mark Send Request Logic

- (void)sendRequest: (HealthVaultRequest *)request {

	request.msgTime = [NSDate date];
	
	if (self.appIdInstance && self.appIdInstance.length > 0) {

		request.appIdInstance = self.appIdInstance;
	}
	else {

		request.appIdInstance = self.masterAppId;
	}
	if(self.currentRecord != nil) {
		
		request.personId = self.currentRecord.personId;
		request.recordId = self.currentRecord.recordId;
	}
	request.authorizationSessionToken = self.authorizationSessionToken;
	request.sessionSharedSecret = self.sessionSharedSecret;

	NSString *requestXml = [request toXml];

	[WebTransport sendRequestForURL: self.healthServiceUrl
						   withData: requestXml
							context: request
							 target: self
						   callBack: @selector(sendRequestCallback: context:)];
}

- (void)sendRequestCallback: (WebResponse *)response
					context: (HealthVaultRequest *)healthVaultRequest {

	HealthVaultResponse *healthVaultResponse = [[[HealthVaultResponse alloc] initWithWebResponse: response
																						 request: healthVaultRequest] autorelease];

	// The token that is returned from GetAuthenticatedSessionToken has a limited lifetime. When it expires,
	// we will get an error here. We detect that situation, get a new token, and then re-issue the call.
	if (healthVaultResponse.statusCode == RESPONSE_AUTH_SESSION_TOKEN_EXPIRED) {
		[self refreshSessionToken: healthVaultRequest];
		return;
	}
	
	// Returns source request and response to app.
	[self performAppCallBack: healthVaultRequest
					response: healthVaultResponse];
}

#pragma mark Send Request Logic End

#pragma mark Auth Logic

- (void)performAuthenticationCheck: (NSObject *)target
	authenticationCompleted: (SEL)authCompleted
		  shellAuthRequired: (SEL)shellAuthRequired {

	[Provisioner performAuthenticationCheck: self
									 target: target
					authenticationCompleted: authCompleted
						  shellAuthRequired: shellAuthRequired];
}

- (void)authorizeRecords: (NSObject *)target
 authenticationCompleted: (SEL)authCompleted
	   shellAuthRequired: (SEL)shellAuthRequired {

	[Provisioner authorizeRecords: self
						   target: target
		  authenticationCompleted: authCompleted
				shellAuthRequired: shellAuthRequired];
}

- (BOOL)getIsApplicationCreated {
	
	return self.authorizationSessionToken != nil;
}

#pragma mark Auth Logic End

#pragma mark Token Refreshing Logic

- (void)refreshSessionToken: (HealthVaultRequest *)request {

	self.authorizationSessionToken = nil;
	NSString *infoSection = [self getCastCallInfoSection];

	HealthVaultRequest *refreshTokenRequest =
			[[HealthVaultRequest alloc] initWithMethodName: @"CreateAuthenticatedSessionToken"
											 methodVersion: 2
											   infoSection: infoSection
													target: self
												  callBack: @selector(refreshSessionTokenCompleted:)];

	// Saves source response to userState property, it will be resent
	// after token updating.
	refreshTokenRequest.userState = request;

	[self sendRequest: refreshTokenRequest];
	[refreshTokenRequest release];
}

- (void)refreshSessionTokenCompleted: (HealthVaultResponse *)response {

	// Retrieves source request, which was failed.
	HealthVaultRequest *originalRequest = (HealthVaultRequest *)response.request.userState;
	
	// Any error just gets returned to the application.
	if (response.hasError) {

		[self performAppCallBack: originalRequest
						response: response];
		return;
	}


	// If the CAST was successful the results were saved and
	// the original request is restarted.
	[self saveCastCallResults: response.infoXml];

	// Resend original request.
	[self sendRequest: originalRequest];
}

#pragma mark Token Refreshing Logic End

#pragma mark Cast Call Logic

- (void)saveCastCallResults: (NSString *)responseXml {

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	XmlTextReader *xmlReader = [XmlTextReader new];
	XmlElement *responseRootNode = [xmlReader read: responseXml];

	self.authorizationSessionToken = [responseRootNode selectSingleNode: @"token"].text;
	self.sessionSharedSecret = [responseRootNode selectSingleNode: @"shared-secret"].text;

	[xmlReader release];

	[pool release];
}

- (NSString *)getCastCallInfoSection {

	NSString *msgTimeString = [DateTimeUtils dateToUtcString: [NSDate date]];

	NSMutableString *stringToSign = [NSMutableString new];
	[stringToSign appendString: @"<content>"];
	[stringToSign appendFormat: @"<app-id>%@</app-id>", self.appIdInstance];
	[stringToSign appendString: @"<hmac>HMACSHA256</hmac>"];
	[stringToSign appendFormat: @"<signing-time>%@</signing-time>", msgTimeString];
	[stringToSign appendString: @"</content>"];

	NSData *keyData = [Base64 decodeBase64WithString: self.sharedSecret];
	NSString *keyString = [[NSString alloc] initWithData: keyData
												encoding: NSUTF8StringEncoding];
	NSString *hmac = [MobilePlatform computeSha256Hmac: keyData
													  : stringToSign];
	[keyString release];

	NSMutableString *xml = [NSMutableString new];
	[xml appendString: @"<info>"];
	[xml appendString: @"<auth-info>"];
	[xml appendFormat: @"<app-id>%@</app-id>", self.appIdInstance];
	[xml appendString: @"<credential>"];
	[xml appendString: @"<appserver2>"];
	[xml appendFormat: @"<hmacSig algName=\"HMACSHA256\">%@</hmacSig>", hmac];
	[xml appendString: stringToSign];
	[stringToSign release];
	[xml appendString: @"</appserver2>"];
	[xml appendString: @"</credential>"];
	[xml appendString: @"</auth-info>"];
	[xml appendString: @"</info>"];

	return [xml autorelease];
}

#pragma mark Cast Call Logic End

#pragma mark Settings Logic

- (void)saveSettings: (NSString *)name {

	HealthVaultSettings *settings = [[HealthVaultSettings alloc] initWithName: name];

	settings.applicationId = self.appIdInstance;
	settings.authorizationSessionToken = self.authorizationSessionToken;
	settings.sharedSecret = self.sharedSecret;
	settings.country = self.country;
	settings.language = self.language;
	settings.sessionSharedSecret = self.sessionSharedSecret;
	settings.version = [MobilePlatform platformAbbreviationAndVersion];

	if (self.currentRecord) {

		settings.personId = self.currentRecord.personId;
		settings.recordId = self.currentRecord.recordId;
	}

	[settings save];
	[settings release];
}

- (void)loadSettings: (NSString *)name {

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	HealthVaultSettings *settings = [HealthVaultSettings loadWithName: name];

	self.appIdInstance = settings.applicationId;
	self.authorizationSessionToken = settings.authorizationSessionToken;
	self.sharedSecret = settings.sharedSecret;
	self.country = settings.country;
	self.language = settings.language;
	self.sessionSharedSecret = settings.sessionSharedSecret;

	if (settings.personId && settings.recordId) {

		HealthVaultRecord *record = [HealthVaultRecord new];
		record.personId = settings.personId;
		record.recordId = settings.recordId;
		self.currentRecord = record;
		[record release];
	} else {

		self.currentRecord = nil;
	}

	[pool release];
}

#pragma mark Settings Logic End

- (void)performAppCallBack: (HealthVaultRequest *)request
				  response: (HealthVaultResponse *)response {

	if (request && request.target && [request.target respondsToSelector:request.callBack]) {

		[request.target performSelector: request.callBack
							 withObject: response];
	}
}

@end
