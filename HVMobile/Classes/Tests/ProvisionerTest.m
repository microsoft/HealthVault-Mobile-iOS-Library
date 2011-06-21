//
//  ProvisionerTest.m
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

#import "ProvisionerTest.h"
#import "HealthVaultService.h"
#import "AuthenticationCheckState.h"
#import "Provisioner.h"


@implementation ProvisionerTest

- (void)testNoAuthorizedPeople {
	HealthVaultService *hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
																   shellUrl: @"https://account.healthvault-ppe.com"
																masterAppId: @"53c18557-d353-4362-80cf-c87ae57b11cf"];
	
	AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: hvService
																				 target: nil
																  authCompletedCallBack: nil
															  shellAuthRequiredCallBack: nil];
	
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedPeople\"><response-results></response-results></wc:info></response>";
	
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] init];
	hvRequest.userState = state;
	
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	[Provisioner getAuthorizedPeopleCompleted: hvResponse];
	
	STAssertTrue(0 == hvService.records.count, @"Unexpected records");
	
	[hvRequest release];
	[hvResponse release];
	[webResponse release];
	[state release];
	[hvService release];
}

- (void)testAuthorizedPeopleSuccess {
	HealthVaultService *hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
																   shellUrl: @"https://account.healthvault-ppe.com"
																masterAppId: @"53c18557-d353-4362-80cf-c87ae57b11cf"];
	
	AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: hvService
																				 target: nil
																  authCompletedCallBack: nil
															  shellAuthRequiredCallBack: nil];
	
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedPeople\"><response-results><person-info><person-id>68701ce3-00f5-4407-a741-d20f13c375d6</person-id><name>Sean Test</name><record id=\"99999999-9999-9999-9999-999999999999\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"2070-01-01T00:00:00Z\" display-name=\"Sean's Test Record\" state=\"Active\" date-created=\"2011-02-18T17:14:44.217Z\" max-size-bytes=\"104857600\" size-bytes=\"1115\" app-record-auth-action=\"NoActionRequired\">Sean's Test Record</record></person-info><more-results>false</more-results></response-results></wc:info></response>";
	
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] init];
	hvRequest.userState = state;
	
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	[Provisioner getAuthorizedPeopleCompleted: hvResponse];
	
	STAssertTrue(1 == hvService.records.count, @"Couldn't get record from response");
	
	HealthVaultRecord *record = [hvService.records objectAtIndex:0];
	
	STAssertEqualObjects(record.personId, @"68701ce3-00f5-4407-a741-d20f13c375d6", @"Received unexpected personId");
	STAssertEqualObjects(record.recordId, @"99999999-9999-9999-9999-999999999999", @"Received unexpected recordId");
	STAssertEqualObjects(record.personName, @"Sean Test", @"Received unexpected person name");
	STAssertEqualObjects(record.recordName, @"Sean's Test Record", @"Received unexpected person name");
	
	[hvRequest release];
	[hvResponse release];
	[webResponse release];
	[state release];
	[hvService release];
}

- (void)testAuthorizedPeopleOneGoodOneBadRecord {
	HealthVaultService *hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
																   shellUrl: @"https://account.healthvault-ppe.com"
																masterAppId: @"53c18557-d353-4362-80cf-c87ae57b11cf"];
	
	AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: hvService
																				 target: nil
																  authCompletedCallBack: nil
															  shellAuthRequiredCallBack: nil];
	
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedPeople\"><response-results><person-info><person-id>68701ce3-00f5-4407-a741-d20f13c375d6</person-id><name>Sean Test</name><record id=\"99999999-9999-9999-9999-999999999999\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"2070-01-01T00:00:00Z\" display-name=\"Sean's Test Record\" state=\"Active\" date-created=\"2011-02-18T17:14:44.217Z\" max-size-bytes=\"104857600\" size-bytes=\"1115\" app-record-auth-action=\"NoActionRequired\">Sean's Test Record</record><record id=\"99999999-9999-9999-9999-999999999988\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"2070-01-01T00:00:00Z\" display-name=\"Bad record\" state=\"Active\" date-created=\"2011-02-18T17:14:44.217Z\" max-size-bytes=\"104857600\" size-bytes=\"1115\" app-record-auth-action=\"AuthorizationRequired \">bad record</record></person-info><more-results>false</more-results></response-results></wc:info></response>";
	
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] init];
	hvRequest.userState = state;
	
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	[Provisioner getAuthorizedPeopleCompleted: hvResponse];
	
	STAssertTrue(1 == hvService.records.count, @"Couldn't get record from response");
	
	HealthVaultRecord *record = [hvService.records objectAtIndex:0];
	
	STAssertEqualObjects(record.personId, @"68701ce3-00f5-4407-a741-d20f13c375d6", @"Received unexpected personId");
	STAssertEqualObjects(record.recordId, @"99999999-9999-9999-9999-999999999999", @"Received unexpected recordId");
	STAssertEqualObjects(record.personName, @"Sean Test", @"Received unexpected person name");
	STAssertEqualObjects(record.recordName, @"Sean's Test Record", @"Received unexpected person name");
	
	[hvRequest release];
	[hvResponse release];
	[webResponse release];
	[state release];
	[hvService release];
}

- (void)testAuthorizedPeopleOneBadRecord {
	HealthVaultService *hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
																   shellUrl: @"https://account.healthvault-ppe.com"
																masterAppId: @"53c18557-d353-4362-80cf-c87ae57b11cf"];
	
	AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: hvService
																				 target: nil
																  authCompletedCallBack: nil
															  shellAuthRequiredCallBack: nil];
	
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedPeople\"><response-results><person-info><person-id>68701ce3-00f5-4407-a741-d20f13c375d6</person-id><name>Sean Test</name><record id=\"99999999-9999-9999-9999-999999999988\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"2070-01-01T00:00:00Z\" display-name=\"Bad record\" state=\"Active\" date-created=\"2011-02-18T17:14:44.217Z\" max-size-bytes=\"104857600\" size-bytes=\"1115\" app-record-auth-action=\"AuthorizationRequired \">bad record</record></person-info><more-results>false</more-results></response-results></wc:info></response>";
	
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] init];
	hvRequest.userState = state;
	
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	[Provisioner getAuthorizedPeopleCompleted: hvResponse];
	
	STAssertTrue(0 == hvService.records.count, @"Received unexpected record.");
	
	[hvRequest release];
	[hvResponse release];
	[webResponse release];
	[state release];
	[hvService release];
}

- (void) testNoSharedSecretCallNewApplicationCreationInfo {
	HealthVaultService *hvService = [[HealthVaultService alloc] initWithUrl: @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
																   shellUrl: @"https://account.healthvault-ppe.com"
																masterAppId: @"53c18557-d353-4362-80cf-c87ae57b11cf"];
	
	AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: hvService
																				 target: nil
																  authCompletedCallBack: nil
															  shellAuthRequiredCallBack: nil];
	
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.NewApplicationCreationInfo\"><app-id>106b443f-3b14-4064-9055-eaf8bb05c206</app-id><shared-secret>PRZoiwotdtjU444q+63M22H/v5zc/MozY/y4gcu17hA=</shared-secret><app-token>ASAAANQgT2YQJwRHpCLOMJXTvlmkPBRmpPB9SzPNHzMndfpiVKBij2RgkLRrQY+oKFKzHP9KxJnFxAC8AyIT77HgfCs1Wq7gol4WovDHAkgslSWMLYEesBLF4i/5DXLr/clsU88vlNR3LKYQSHb8BGcr2wqNGHXFN2I092YeCcN8pujwB6GzXcuTQwvnrs4UB8YbCe8lDMf0ugSH0P12PObFwes9Ya5BRP2TtsFtmVPv+yesNtl8CoglFrzDfA5qb4m7jt4IlFsBHRldPOPA1jFNWHGUJrMdO+ZbR0coG0aSac5S8oIUBKqpI5bWzWwxCoz9luntD6oYvWvY0IFU+zjdrKOHIUIB</app-token></wc:info></response>";
	
	HealthVaultRequest *hvRequest = [[HealthVaultRequest alloc] init];
	hvRequest.userState = state;
	
	HealthVaultResponse *hvResponse = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			   request: hvRequest];
	
	[Provisioner newApplicationCreationInfoCompleted: hvResponse];
	
	STAssertEqualObjects(hvService.appIdInstance, @"106b443f-3b14-4064-9055-eaf8bb05c206", @"Received unexpected AppIdInstance"); 
	
	[hvRequest release];
	[hvResponse release];
	[webResponse release];
	[state release];
	[hvService release];
}

@end
