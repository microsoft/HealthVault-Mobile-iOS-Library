//
//  HealthVaultRecordTest.m
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

#import "HealthVaultRecordTest.h"


@implementation HealthVaultRecordTest

- (void) testRecordCreationNoActionRequired {
	
	NSString *xml = @"<record id=\"3401572b-d7ee-407c-846a-90a72e4a8740\" record-custodian=\"true\" rel-type=\"13\" rel-name=\"Pet\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"BigRedDog\" state=\"Active\" date-created=\"2011-03-29T23:28:29.867Z\" max-size-bytes=\"104857600\" size-bytes=\"2760\" app-record-auth-action=\"NoActionRequired\">Big Dog</record>";
	
	HealthVaultRecord *record = [[HealthVaultRecord newFromXml: xml
													  personId: @"1efce308-fee7-475d-a1d8-0c8a873b39db"
													personName: @"John Doe"] autorelease];
	
	STAssertNotNil(record, @"Incorrect record");
	
	STAssertEqualObjects(record.personId, @"1efce308-fee7-475d-a1d8-0c8a873b39db", @"Incorrect person id");
	STAssertEqualObjects(record.personName, @"John Doe", @"Incorrect person name");
	STAssertEqualObjects(record.recordId, @"3401572b-d7ee-407c-846a-90a72e4a8740", @"Incorrect record id");
	STAssertEqualObjects(record.recordName, @"Big Dog", @"Incorrect record name");
	
}

- (void) testRecordCreationActionRequired {
	
	NSString* xml = @"<record id=\"3401572b-d7ee-407c-846a-90a72e4a8740\" record-custodian=\"true\" rel-type=\"13\" rel-name=\"Pet\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"BigRedDog\" state=\"Active\" date-created=\"2011-03-29T23:28:29.867Z\" max-size-bytes=\"104857600\" size-bytes=\"2760\" app-record-auth-action=\"AuthRequired\">Big Dog</record>";
	
	HealthVaultRecord* record = [[HealthVaultRecord newFromXml: xml
													  personId: @"1efce308-fee7-475d-a1d8-0c8a873b39db"
													personName: @"John Doe"] autorelease];
	
	STAssertNil(record, @"Incorrect record");
}

@end
