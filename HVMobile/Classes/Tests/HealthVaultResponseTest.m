//
//  HealthVaultResponseTest.m
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

#import "HealthVaultResponseTest.h"


@implementation HealthVaultResponseTest

- (void)testResponseObject {
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>55</code></status></response>";
	
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] init];
	
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	STAssertTrue(55 == hvResponse.statusCode, @"Status code isn't equal to expected");
	
	[hvRequest release];
	[hvResponse release];
	[webResponse release];
}

- (void)testResponseSimpleError {
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>5</code><error><message>Unknown method GetServiceDefinitionss</message></error></status></response>";
	
	HealthVaultRequest *hvRequest = [HealthVaultRequest new];
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	STAssertTrue(5 == hvResponse.statusCode, @"Recieved unexpected status code");
	STAssertNotNil(hvResponse.errorText, @"Error text is null");
	[hvResponse release];
	[hvRequest release];
	[webResponse release];
}

@end
