//
//  HealthVaultServiceTest.m
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

#import "HealthVaultServiceTest.h"
#import "MobilePlatformTest.h"
#import "MobilePlatform.h"
#import "Base64.h"
#import "Provisioner.h"
#import "AuthenticationCheckState.h"

@implementation HealthVaultServiceTest

- (void)setUp {
	// HealthVault Service with test master app Id.
	_hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
												shellUrl: @"https://account.healthvault-ppe.com"
											 masterAppId: @"c55cf02c-7de7-487a-8b8f-f694a7d9d737"];
	STAssertNotNil(_hvService, @"Could not create test instance of HealthVaultService.");
}


- (void)tearDown {
	[_hvService release];
}

- (void)testDefaultValues {
	STAssertEquals(_hvService.language, @"en", @"Incorrect language");
}

- (void)testApplicationCreationUrl {
	_hvService.applicationCreationToken = @"ASAAAAukJ0r+NLVGks0yQoquKlmHOE95AQNgjsa/BPGWRSI0KqG2YVYYFFQE3Ma2Exafr7sChj8/p/h0/YvBzgrcp/hBZiMjiwQZBgg1gNATUUkgNUK1TqwnO9w6GrK1iigSNaZmkqE9ahjFH3cO8RhJ65+mTQHEFQzhhNS8VcwnGkoHBD9aevpQbL/XcXe9Y6flgzoj4Wyw8sj6CRXluagLv/k777V8EC9SynU0hCfcL7Fvq4L3MYOg5ej3CHk28nm+wMOzDFQgQFsG0fkSFJ8J5KE4b2CrKpdw6uzQvBAWa1yT6fS4B2M1OnZzmQ3NiOf/OSWZl5zBLaf6dP21QqOvO2yeEHWr";

	NSString *expectedResult = @"https://account.healthvault-ppe.com/redirect.aspx?target=CREATEAPPLICATION&targetqs=%3Fappid%3dc55cf02c-7de7-487a-8b8f-f694a7d9d737%26appCreationToken%3DASAAAAukJ0r%252BNLVGks0yQoquKlmHOE95AQNgjsa%252FBPGWRSI0KqG2YVYYFFQE3Ma2Exafr7sChj8%252Fp%252Fh0%252FYvBzgrcp%252FhBZiMjiwQZBgg1gNATUUkgNUK1TqwnO9w6GrK1iigSNaZmkqE9ahjFH3cO8RhJ65%252BmTQHEFQzhhNS8VcwnGkoHBD9aevpQbL%252FXcXe9Y6flgzoj4Wyw8sj6CRXluagLv%252Fk777V8EC9SynU0hCfcL7Fvq4L3MYOg5ej3CHk28nm%252BwMOzDFQgQFsG0fkSFJ8J5KE4b2CrKpdw6uzQvBAWa1yT6fS4B2M1OnZzmQ3NiOf%252FOSWZl5zBLaf6dP21QqOvO2yeEHWr%26instanceName%3DiOS%2520Device%26ismra%3Dtrue";
	NSString *result = [_hvService getApplicationCreationUrl];
	NSComparisonResult compareResult = [result caseInsensitiveCompare: expectedResult];

	STAssertEquals(compareResult, NSOrderedSame, @"Incorrect Application Creation Url");
}

BOOL isAppCreationInfoRequestDone;

- (void)testNewApplicationCreationInfoRequest {


	HealthVaultRequest *request = [[[HealthVaultRequest alloc] initWithMethodName: @"NewApplicationCreationInfo"
																	methodVersion: 1
																	  infoSection: nil
																		   target: self
																		 callBack: @selector(testNewApplicationCreationInfoRequestHandler:)] autorelease];

	isAppCreationInfoRequestDone = NO;

	AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: _hvService
																				target: nil
																 authCompletedCallBack: nil
															 shellAuthRequiredCallBack: nil];
	request.userState = state;
	
	[_hvService sendRequest: request];


	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	int numTries = 0;
	while (!isAppCreationInfoRequestDone && [theRL runMode: NSDefaultRunLoopMode
												beforeDate: [NSDate dateWithTimeIntervalSinceNow: 1]]) {
		if (numTries++ > ASYNC_TEST_TIMEOUT_SEC) {
			break;
		}
	}


	STAssertTrue (isAppCreationInfoRequestDone, @"Request timeout");
}

- (void)testNewApplicationCreationInfoRequestHandler: (HealthVaultResponse *)response {

	// if this method was run as a separate unit test, skip it
	if (response == nil) return;

	STAssertNotNil(response, nil);

	STAssertFalse([response getHasError], nil);
	STAssertTrue(response.statusCode == 0, nil);
	STAssertNotNil(response.infoXml, nil);
	
	[Provisioner newApplicationCreationInfoCompleted: response];
	STAssertNotNil(_hvService.appIdInstance, @"Received unexpected instance app Id (null).");
	STAssertNotNil(_hvService.sharedSecret, @"Received unexpected shared secret (null).");
	STAssertNotNil(_hvService.applicationCreationToken, @"Received unexpected application creation token (null).");

	isAppCreationInfoRequestDone = YES;
}

- (void)testAuthRequestAuthRequired {
	
	isAppCreationInfoRequestDone = NO;
	
	[_hvService performAuthenticationCheck: self
				   authenticationCompleted: @selector(unexpectedCallback:)
						 shellAuthRequired: @selector(shellAuthRequired:)];
	
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	int numTries = 0;
	while (!isAppCreationInfoRequestDone && [theRL runMode: NSDefaultRunLoopMode
												beforeDate: [NSDate dateWithTimeIntervalSinceNow: 1]]) {
		if (numTries++ > ASYNC_TEST_TIMEOUT_SEC) {
			break;
		}
	}
	
	
	STAssertTrue (isAppCreationInfoRequestDone, @"Request timeout");
}

- (void)shellAuthRequired: (HealthVaultResponse *)response {
	STAssertNotNil(_hvService.appIdInstance, @"Received unexpected instance app Id (null).");
	STAssertNotNil(_hvService.sharedSecret, @"Received unexpected shared secret (null).");
	isAppCreationInfoRequestDone = YES;
}

- (void)testAuthRequestAuthSuccess {
	
	// Sets test app instance Id and shared secret.
	// Application should have one record for those credentials.
	_hvService.appIdInstance = @"f63e8825-d1c7-4f45-973d-d102ca886ba3";
	_hvService.sharedSecret = @"UsajkMAGbFMdgWfOk5DYdWX8TLdYf6545R163PnZbuA=";
	
	isAppCreationInfoRequestDone = NO;
	
	[_hvService performAuthenticationCheck: self
				   authenticationCompleted: @selector(authenticationCompleted:)
						 shellAuthRequired: @selector(unexpectedCallback:)];
	
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	int numTries = 0;
	while (!isAppCreationInfoRequestDone && [theRL runMode: NSDefaultRunLoopMode
												beforeDate: [NSDate dateWithTimeIntervalSinceNow: 1]]) {
		if (numTries++ > ASYNC_TEST_TIMEOUT_SEC) {
			break;
		}
	}
	
	
	STAssertTrue (isAppCreationInfoRequestDone, @"Request timeout");
}

- (void)authenticationCompleted: (HealthVaultResponse *)response {
	STAssertNotNil(_hvService.records, @"Couldn't get records");
	int recordsCount = [_hvService.records count];
	STAssertTrue(recordsCount == 1, @"Received unexpected records count");
	isAppCreationInfoRequestDone = YES;
}

- (void)unexpectedCallback: (HealthVaultResponse *) response {
	STFail(@"Received unexpected callback");
	isAppCreationInfoRequestDone = YES;
}

- (void) testGetApplicationCreationUrlNoApplicationYet {
	_hvService.applicationCreationToken = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==";
	
	NSString *result = [_hvService getApplicationCreationUrl];
	
	NSRange range = [result rangeOfString: @"target=CREATEAPPLICATION"];
	STAssertTrue(range.location != NSNotFound, @"Target block not found");
	
	range = [result rangeOfString: @"targetqs="];
	STAssertTrue(range.location != NSNotFound, @"targetqs not found");
	NSString *substring = [result substringFromIndex:range.location + @"targetqs=".length];
	
	CFStringRef encodedToken = CFURLCreateStringByAddingPercentEscapes(NULL,
																	   (CFStringRef)_hvService.applicationCreationToken,
																	   NULL,
																	   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																	   kCFStringEncodingUTF8);
	NSString *expectedToken = [[NSString alloc] initWithFormat: @"appCreationToken=%@", (NSString *)encodedToken];
	CFRelease(encodedToken);
	encodedToken = CFURLCreateStringByAddingPercentEscapes(NULL,
														   (CFStringRef)expectedToken,
														   NULL,
														   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
														   kCFStringEncodingUTF8);
	
	CFStringRef encodedDeviceName = CFURLCreateStringByAddingPercentEscapes(NULL,
																	   (CFStringRef)[MobilePlatform deviceName],
																	   NULL,
																	   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																	   kCFStringEncodingUTF8);
	
	NSString *expectedDeviceName = [[NSString alloc] initWithFormat: @"instanceName=%@", (NSString *)encodedDeviceName];
	CFRelease(encodedDeviceName);
	encodedDeviceName = CFURLCreateStringByAddingPercentEscapes(NULL,
														   (CFStringRef)expectedDeviceName,
														   NULL,
														   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
														   kCFStringEncodingUTF8);
	
	
	NSRange rangeToken = [substring rangeOfString: (NSString *)encodedToken];
	NSRange rangeDeviceName = [substring rangeOfString: (NSString *)encodedDeviceName];
	STAssertTrue(rangeToken.location != NSNotFound, @"Token in URL isn't equal to expected.");
	STAssertTrue(rangeDeviceName.location != NSNotFound, @"Device name in URL isn't equal to expected.");
	
	[expectedToken release];
	[expectedDeviceName release];
	CFRelease(encodedToken);
	CFRelease(encodedDeviceName);
}

- (void) testGetApplicationCreationUrlAppNoUserAuth {
	NSString *instanceAppID = @"471b9f73-53d3-c80f-6243-a17e5871bccf";
	_hvService.applicationCreationToken = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==";
	_hvService.sessionSharedSecret = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==";
	_hvService.appIdInstance = instanceAppID;
	
	NSString *result = [_hvService getUserAuthorizationUrl];
	
	NSString *expectedAppID = [[NSString alloc] initWithFormat:@"appid=%@", instanceAppID];
	
	CFStringRef encodedExpectedID = CFURLCreateStringByAddingPercentEscapes(NULL,
																			(CFStringRef)expectedAppID,
																			NULL,
																			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			kCFStringEncodingUTF8);
	
	
	NSRange range = [result rangeOfString: (NSString *)encodedExpectedID];
	STAssertTrue(range.location != NSNotFound, @"Application ID isn't equal to expected.");
	range = [result rangeOfString:@"target=APPAUTH"];
	STAssertTrue(range.location != NSNotFound, @"Application target isn't equal to expected.");
	[expectedAppID release];
	CFRelease(encodedExpectedID);
}

- (void)testSaveRestoreState {
	NSString *settingsName = @"TestSettings";
	_hvService.appIdInstance = @"ce121dd2-7b5b-40f4-b41f-01d16f23e391";
	_hvService.applicationCreationToken = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==xxx";
	_hvService.authorizationSessionToken = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==xxx";
	
	NSData *keyData = [@"My test key" dataUsingEncoding: NSUTF8StringEncoding];
	_hvService.sharedSecret = [Base64 encodeBase64WithData: keyData];
	_hvService.country = @"CA";
	_hvService.language = @"fr";
	
	NSData *sessionSharedSecretData = [@"My session key" dataUsingEncoding: NSUTF8StringEncoding];
	_hvService.sessionSharedSecret = [Base64 encodeBase64WithData: sessionSharedSecretData];
	
	HealthVaultRecord *record = [HealthVaultRecord new];
	record.personId = @"12ce1dd2-5b7b-f440-1fb4-f23e01d16391";
	record.recordId = @"12345678-1234-1234-1234-123456789012";
	_hvService.currentRecord = record;
	
	[_hvService saveSettings: settingsName];
	
	HealthVaultService *hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
																   shellUrl: @"https://account.healthvault-ppe.com"
																masterAppId: @"53c18557-d353-4362-80cf-c87ae57b11cf"];
	[hvService loadSettings: settingsName];
	STAssertEquals(_hvService.appIdInstance, hvService.appIdInstance, @"Couldn't load AppIDInstance.");
	STAssertTrue(nil == hvService.applicationCreationToken, @"Received applicationCreationToken from settings.");
	STAssertEquals(_hvService.authorizationSessionToken, hvService.authorizationSessionToken,
				   @"Couldn't load AuthorizationSessionToken.");
	STAssertEquals(_hvService.sharedSecret, hvService.sharedSecret, @"Couldn't load SharedSecret.");
	STAssertEquals(_hvService.country, hvService.country, @"Couldn't load Country.");
	STAssertEquals(_hvService.language, hvService.language, @"Couldn't load Language.");
	STAssertEquals(_hvService.sessionSharedSecret, hvService.sessionSharedSecret, @"Couldn't load SessionSharedSecret.");
	STAssertEquals(_hvService.currentRecord.personId, hvService.currentRecord.personId, @"Couldn't load personId.");
	STAssertEquals(_hvService.currentRecord.recordId, hvService.currentRecord.recordId, @"Couldn't load recordIdl.");
	
	[hvService release];
}

- (NSString *)getExpectedSharedSecret {
	return @"+xEF24ekXQh1geVWpvTvg0BT8OP6g4LWvooZXiE+ftyjU+5U3dxyR7MdzlEgDTznepXDNEEpcCvbxTv2Dx5qxQ==";
}
- (NSString *)getExpectedSessionToken {
	return @"ASAAAEJsFrdImoBPhEuDFRUObCJw2M1gj+RhF8+q2oJ9N396v3NE9+kBK61ME168S+p52rvwiFKZW1xtxNi/DC+d7TRtL40j32fpDBB9OB22awEm4g5IkObUMC3jvaP00FzFISYqKO1dXtiQ7PklURP1wrPn7o7mxsaYIo4TmN2ftTWvWs9MJ6konzREIguU0JrtX1iNEuGlkOS+xs8q/2MRB6gNL4TWWTiPWwYoqECYNSwoafw4Kv8RqUJ+mJ2dUGVxpDLhsWSYDhHMa8KpQr94dMSJyn6mhnEBIynwk5BcJ1qvxpn2zw==";
}

- (NSString *) getValidCastCallResult {
	return [[[NSString alloc] initWithFormat: @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.CreateAuthenticatedSessionToken2\"><token app-id=\"99999999-9999-9999-9999-999999999999\" app-record-auth-action=\"NoActionRequired\">%@</token><shared-secret>%@</shared-secret></wc:info></response>", [self getExpectedSessionToken], [self getExpectedSharedSecret]] autorelease];
}

- (void)testCASTCallSuccess {
	STAssertTrue(nil == _hvService.sessionSharedSecret, @"Service has already initialized");
	STAssertTrue(nil == _hvService.authorizationSessionToken, @"Service has already initialized");
	
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = [self getValidCastCallResult];
	
	HealthVaultRequest *hvRequest = [HealthVaultRequest new];
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	[_hvService saveCastCallResults: [hvResponse infoXml]];
	
	STAssertEqualObjects(_hvService.sessionSharedSecret, [self getExpectedSharedSecret], @"Shared secret isn't equal to expected.");
	STAssertEqualObjects(_hvService.authorizationSessionToken, [self getExpectedSessionToken], @"Authorization session token isn't equal to expected.");

	[hvResponse release];
	[hvRequest release];
	[webResponse release];
}

@end
