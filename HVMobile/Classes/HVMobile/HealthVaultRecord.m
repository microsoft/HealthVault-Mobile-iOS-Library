//
//  HealthVaultRecord.m
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

#import "HealthVaultRecord.h"
#import "XmlTextReader.h"

@interface HealthVaultRecord (Private)

/// Initializes the fields using xml string provided.
/// @param xml - the full XML describing this record.
- (BOOL)parseFromXml: (NSString *)xml;

@end


@implementation HealthVaultRecord

@synthesize xml = _xml;
@synthesize personId = _personId;
@synthesize personName = _personName;
@synthesize recordId = _recordId;
@synthesize recordName = _recordName;
@synthesize authStatus = _authStatus;

+ (id)newFromXml: (NSString *)xml
		personId: (NSString *)personId
	  personName: (NSString *)personName {

	HealthVaultRecord *record = [[HealthVaultRecord alloc] initWithXml: xml
															  personId: personId
															personName: personName];
	if (!record.isValid) {
		[record release];
		return nil;
	}

	return record;

}

- (id)initWithXml: (NSString *)xml
		 personId: (NSString *)personId
	   personName: (NSString *)personName {

	if ((self = [super init])) {

		self.xml = xml;
		self.personId = personId;
		self.personName = personName;

		if (xml != nil)  {

			[self parseFromXml: xml];
		}
		
	}

	return self;
}

- (void)dealloc {

	self.xml = nil;
	self.personId = nil;
	self.personName = nil;
	self.recordId = nil;
	self.recordName = nil;
	self.authStatus = nil;

	[super dealloc];
}

- (BOOL)parseFromXml: (NSString *)xml {

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	@try {

		XmlTextReader *xmlReader = [[XmlTextReader new] autorelease];
		XmlElement *root = [xmlReader read: xml];

		if (!root) {
			return NO;
		}

		self.recordId = [root attrValue: @"id"];
		self.recordName = [root text];
		self.authStatus = [root attrValue: @"app-record-auth-action"];

	}
	@catch (id exc) {

		return NO;
	}
	@finally {

		[pool release];
	}

	return YES;
}

- (BOOL)getIsValid {

	return (self.authStatus != nil && [self.authStatus isEqual: @"NoActionRequired"]);
}

@end
