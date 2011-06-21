//
//  WeightTest.m
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

#import "WeightTest.h"

#import "HealthVaultService.h"
#import "Weight.h"
#import "DateTimeUtils.h"

@implementation WeightTest

- (void)testLoadWeightsRequest {
	HealthVaultRequest *healthVaultRequest = [Weight getLoadWeightsRequest: nil
																  callBack: nil];
	STAssertTrue(healthVaultRequest != nil, @"Couldn't get request to load weights");
	STAssertEqualObjects(healthVaultRequest.methodName, @"GetThings", @"Method name isn't equal to expected");
	STAssertTrue(healthVaultRequest.methodVersion == 3.0, @"Method version isn't equal to expected");
	NSRange range = [healthVaultRequest.infoXml rangeOfString: @"<type-id>3d34d87e-7fc1-4153-800f-f56592cb0d17</type-id>"];
	STAssertTrue(range.location != NSNotFound, @"Couldn't find expected type-id in request");
	range = [healthVaultRequest.infoXml rangeOfString: @"<type-version-format>3d34d87e-7fc1-4153-800f-f56592cb0d17</type-version-format>"];
	STAssertTrue(range.location != NSNotFound, @"Couldn't find expected type-version-format in request");
}

- (void)testWeightFromXml {
	WebResponse *webResponse = [WebResponse new];
	webResponse.responseData = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\">"
		"<group><thing><thing-id version-stamp=\"6fa3752a-deeb-4900-9774-2ffb165107d7\">e2a124d8-0390-4c4b-aad6-766e75c9942d</thing-id>"
		"<type-id name=\"Weight Measurement\">3d34d87e-7fc1-4153-800f-f56592cb0d17</type-id><thing-state>Active</thing-state><flags>0</flags>"
		"<eff-date>2011-04-20T12:25:29.218</eff-date><data-xml><weight><when><date><y>2011</y><m>4</m><d>20</d></date><time><h>12</h><m>25</m><s>29</s><f>218</f></time></when>"
		"<value><kg>65.7894736842105</kg><display units=\"pounds\">145</display></value></weight><common /></data-xml></thing>"
		"<thing><thing-id version-stamp=\"f7e2206b-31f8-4d98-9e7b-898a41131815\">820a384c-7b47-44df-97d9-488331751795</thing-id>"
		"<type-id name=\"Weight Measurement\">3d34d87e-7fc1-4153-800f-f56592cb0d17</type-id><thing-state>Active</thing-state>"
		"<flags>0</flags><eff-date>2011-04-20T08:18:44</eff-date><data-xml><weight><when><date><y>2011</y><m>4</m><d>20</d></date><time><h>8</h><m>18</m><s>44</s><f>0</f></time></when>"
		"<value><kg>63.520871</kg><display units=\"pounds\">140.00</display></value></weight><common /></data-xml></thing></group></wc:info></response>";
	
	HealthVaultRequest *request = [HealthVaultRequest new];
	HealthVaultResponse *response = [[HealthVaultResponse alloc] initWithWebResponse: webResponse
																			 request: request];
	NSArray *weights = [[Weight parseWeightsFromXml: response.infoXml] retain];
	
	STAssertTrue(weights != nil, @"Couldn't parse Weight info from Xml string");
	STAssertTrue(weights.count == 2, @"Received incorrect count of weights from xml");
	
	Weight *weight = [weights objectAtIndex:0];
	
	STAssertTrue(weight.effDate != nil, @"Couldn't parse effDate");
	NSString *date = [DateTimeUtils dateToUtcString: weight.effDate];
	STAssertEqualObjects(date, @"2011-04-20T12:25:29.218Z", @"EffData isn't equal to expected");
	
	STAssertEqualObjects(weight.display, @"145", @"Display data isn't equal to expected");
	STAssertEqualObjects(weight.units, @"pounds", @"Units data isn't equal to expected");
	
	weight = [weights objectAtIndex:1];
	
	STAssertTrue(weight.effDate != nil, @"Couldn't parse effDate");
	date = [DateTimeUtils dateToUtcString: weight.effDate];
	STAssertEqualObjects(date, @"2011-04-20T08:18:44.000Z", @"EffData isn't equal to expected");
	
	STAssertEqualObjects(weight.display, @"140.00", @"Display data isn't equal to expected");
	STAssertEqualObjects(weight.units, @"pounds", @"Units data isn't equal to expected");
}

@end
