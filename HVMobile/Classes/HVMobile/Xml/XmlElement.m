//
//  XmlElement.h
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

#import "XmlElement.h"

@implementation XmlElement

@synthesize name = _name;

@synthesize attributes = _attributes;

@synthesize text = _text;

@synthesize children = _children;

- (void)dealloc {

	self.name = nil;
	self.text = nil;	
	self.children = nil;	
	self.attributes = nil;

	[super dealloc];
}

- (NSArray *)selectNodes: (NSString *)elementname {

	return [self.children valueForKey: elementname];
}

- (XmlElement *)selectSingleNode: (NSString *)elementname at: (NSInteger)position {

	NSArray *children = [self selectNodes: elementname];

	if (children && [children count] > position) {
		
		return [children objectAtIndex: position];
	}

	return nil;
}

- (XmlElement *)selectSingleNode: (NSString *)elementname {
	
	NSArray *parts = [elementname componentsSeparatedByString: @"/"];
	XmlElement *current = self;
	
	for (NSString *part in parts) {
		
		current = [current selectSingleNode: part at: 0];
		
		if (!current) return nil;		
	}
	
	return current;
}

- (NSString *)attrValue: (NSString *)attributename {

	return [self.attributes valueForKey: attributename];
}

@end
