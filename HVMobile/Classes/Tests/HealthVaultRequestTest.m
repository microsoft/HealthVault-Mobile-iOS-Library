//
//  HealthVaultRequestTest.m
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

#import "HealthVaultRequestTest.h"
#import "HealthVaultService.h"
#import "MobilePlatform.h"
#import "Base64.h"


@implementation HealthVaultRequestTest

- (void)testInfoHash {
	NSString *infoString = @"<info><data /></info>";
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																	 methodVersion: 2
																	   infoSection: infoString
																			target: nil
																		  callBack: nil];
	NSString *requestXml = [hvRequest toXml];
	
	STAssertNotNil(requestXml, @"Request XML is null");
	[hvRequest release];
	
	NSRange range = [requestXml rangeOfString: @"<hash-data algName=\"SHA256\">so4ytpjC0gRMGmO3v9eo/oiORDAWnrDsRvTAFOvswic=</hash-data>"];
	STAssertTrue(range.location != NSNotFound, @"Hash data isn't equal to expected.");
}

- (void)testAbbreviationAndVersionPassed {
	NSString *infoString = @"My request data";
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																	 methodVersion: 2
																	   infoSection: infoString
																			target: nil
																		  callBack: nil];
	NSString *requestXml = [hvRequest toXml];
	[hvRequest release];
	
	STAssertNotNil(requestXml, @"Request XML is null");
	
	NSRange range = [requestXml rangeOfString: [[[NSString alloc] initWithFormat: @"<version>%@</version>", [MobilePlatform platformAbbreviationAndVersion]] autorelease]];
	STAssertTrue(range.location != NSNotFound, @"Incorrect version in request xml.");
}

- (void)testAuthTokenPresent {
	NSString *infoString = @"<info>My request data</info>";
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																	 methodVersion: 2
																	   infoSection: infoString
																			target: nil
																		  callBack: nil];
	hvRequest.authorizationSessionToken = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==";
	NSString *requestXml = [hvRequest toXml];
	[hvRequest release];
	
	STAssertNotNil(requestXml, @"Request XML is null");
	
	NSRange range = [requestXml rangeOfString: @"<auth-token>ASAAADNt1Jwbx…+wsXjPFs00soe9w==</auth-token>"];
	STAssertTrue(range.location != NSNotFound, @"Auth-token isn't equal to expected.");
}

- (void)testAppIdPresent {
	NSString *infoString = @"<info>My request data</info>";
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																	 methodVersion: 2
																	   infoSection: infoString
																			target: nil
																		  callBack: nil];
	hvRequest.appIdInstance = @"ce121dd2-7b5b-40f4-b41f-01d16f23e391";
	
	NSString *requestXml = [hvRequest toXml];
	[hvRequest release];
	
	STAssertNotNil(requestXml, @"Request XML is null");
	
	NSRange range = [requestXml rangeOfString: @"<app-id>ce121dd2-7b5b-40f4-b41f-01d16f23e391</app-id>"];
	STAssertTrue(range.location != NSNotFound, @"App Id isn't equal to expected.");
}

- (void)testHmacPresent {
	NSString *infoString = @"<info>My request data</info>";
	NSString *ketString = @"My test key";
	NSData *keyData = [ketString dataUsingEncoding:NSUTF8StringEncoding];
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																	 methodVersion: 2
																	   infoSection: infoString
																			target: nil
																		  callBack: nil];
	hvRequest.authorizationSessionToken = @"ASAAADNt1Jwbx…+wsXjPFs00soe9w==";
	hvRequest.sessionSharedSecret = [Base64 encodeBase64WithData: keyData];
	
	NSString *requestXml = [hvRequest toXml];
	[hvRequest release];
	
	STAssertNotNil(requestXml, @"Request XML is null");
	
	NSRange range = [requestXml rangeOfString: @"<auth><hmac-data algName=\"HMACSHA256\">nwSDqPJCpSXsU5BEcCSseUD9xOCwOzeGxI5kUNuu0WI=</hmac-data></auth>"];
	STAssertTrue(range.location != NSNotFound, @"HMac data isn't equal to expected.");
}

- (void) testLanguageAndCountry {
	NSString *infoString = @"My request data";
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																	 methodVersion: 2
																	   infoSection: infoString
																			target: nil
																		  callBack: nil];
	hvRequest.country = @"CA";
	hvRequest.language = @"fr";
	NSString *requestXml = [hvRequest toXml];
	[hvRequest release];
	
	STAssertNotNil(requestXml, @"Request XML is null");
	
	NSRange countryRange = [requestXml rangeOfString: @"<country>CA</country>"];
	NSRange languageRange = [requestXml rangeOfString: @"<language>fr</language>"];
	
	STAssertTrue(countryRange.location != NSNotFound, @"Country isn't equal to expected.");
	STAssertTrue(languageRange.location != NSNotFound, @"Language isn't equal to expected.");
}

@end
