//
//  HealthVaultRequest.m
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

#import "HealthVaultRequest.h"
#import "DateTimeUtils.h"
#import "MobilePlatform.h"
#import "Base64.h"


@implementation HealthVaultRequest

@synthesize methodName = _methodName;
@synthesize methodVersion = _methodVersion;
@synthesize infoXml = _infoXml;
@synthesize recordId = _recordId;
@synthesize personId = _personId;

@synthesize authorizationSessionToken = _authorizationSessionToken;
@synthesize appIdInstance = _appIdInstance;
@synthesize sessionSharedSecret = _sessionSharedSecret;

@synthesize language = _language;
@synthesize country = _country;
@synthesize msgTime = _msgTime;
@synthesize msgTTL = _msgTTL;
@synthesize userState = _userState;

@synthesize target = _target;
@synthesize callBack = _callBack;

- (id)initWithMethodName: (NSString *)name
		   methodVersion: (float)methodVersion
			 infoSection: (NSString *)info
				  target: (NSObject *)target
				callBack: (SEL)callBack {

	if (self = [super init]) {

		self.methodName = name;
		self.methodVersion = methodVersion;
		self.infoXml = info;
		self.target = target;
		self.callBack = callBack;

		// Sets default values.
		self.language = @"en";
		self.country = @"US";
		self.msgTTL = 1800;
	}

	return self;
}

- (void)dealloc {

	self.methodName = nil;
	self.infoXml = nil;
	self.recordId = nil;
	self.personId = nil;

	self.authorizationSessionToken = nil;
	self.appIdInstance = nil;
	self.sessionSharedSecret = nil;

	self.language = nil;
	self.country = nil;
	self.msgTime = nil;
	self.userState = nil;

	self.target = nil;

	[super dealloc];
}

- (NSString *)toXml {

	NSMutableString *xml = [NSMutableString new];

	[xml appendString:@"<wc-request:request xmlns:wc-request=\"urn:com.microsoft.wc.request\">"];

	NSMutableString *header = [NSMutableString new];

	[header appendString: @"<header>"];

	[header appendFormat: @"<method>%@</method>", self.methodName];
	[header appendFormat: @"<method-version>%.0f</method-version>", self.methodVersion];

	if (self.recordId) {
		[header appendFormat: @"<record-id>%@</record-id>", self.recordId];
	}

	if (self.authorizationSessionToken && self.authorizationSessionToken.length > 0) {

		[header appendString: @"<auth-session>"];
		[header appendFormat: @"<auth-token>%@</auth-token>", self.authorizationSessionToken];

		if (self.personId) {

			[header appendString: @"<offline-person-info>"];
			[header appendFormat: @"<offline-person-id>%@</offline-person-id>", self.personId];
			[header appendString: @"</offline-person-info>"];
		}

		[header appendString: @"</auth-session>"];
	}
	else {

		[header appendFormat: @"<app-id>%@</app-id>", self.appIdInstance];
	}

	[header appendFormat: @"<language>%@</language>", self.language];
	[header appendFormat: @"<country>%@</country>", self.country];


	[header appendFormat: @"<msg-time>%@</msg-time>", [DateTimeUtils dateToUtcString:self.msgTime]];
	[header appendFormat: @"<msg-ttl>%d</msg-ttl>", self.msgTTL];
	[header appendFormat: @"<version>%@</version>", [MobilePlatform platformAbbreviationAndVersion]];

	NSMutableString *infoString = [NSMutableString new];
	if (self.infoXml) {
		[infoString appendFormat: @"%@", self.infoXml];
	} else {
		[infoString appendFormat: @"<info />"];
	}
	
	BOOL isCreateAuthSessionTokenMethod = [@"CreateAuthenticatedSessionToken" compare: self.methodName] == NSOrderedSame;

	if (!isCreateAuthSessionTokenMethod) {
		
		[header appendFormat: @"<info-hash>%@</info-hash>", [MobilePlatform computeSha256HashAndWrap:infoString]];
	}

	[header appendString: @"</header>"];

	if (self.sessionSharedSecret && !isCreateAuthSessionTokenMethod) {
		NSData *decodedKey = [Base64 decodeBase64WithString: self.sessionSharedSecret];

		[xml appendFormat: @"<auth>%@</auth>", [MobilePlatform computeSha256HmacAndWrap: decodedKey : header]];
	}

	[xml appendString: header];
	[xml appendFormat: @"%@", infoString];

	[xml appendString: @"</wc-request:request>"];

	[header release];
	[infoString release];
	return [xml autorelease];
}

@end
