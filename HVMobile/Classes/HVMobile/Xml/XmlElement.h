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

#import <Foundation/Foundation.h>

/// Represents xml tree node.
@interface XmlElement : NSObject {

	/// Element name.
	NSString *_name;	
	
	/// Element inner text.
	NSMutableString *_text;

	/// Element attributes.
	NSMutableDictionary *_attributes;

	/// Element children.
	NSMutableDictionary *_children;
}

/// Gets or sets element name.
@property (retain) NSString *name;

/// Gets or sets element inner text.
@property (retain) NSMutableString *text;

/// Gets or sets element attributes.
@property (retain) NSMutableDictionary *attributes;

/// Gets or sets elements children.
@property (retain) NSMutableDictionary *children;

/// Returns an array of children matching the given element name.
/// @param name - children name.
/// @returns an array of children matching the given element name.
- (NSArray *)selectNodes: (NSString *)name;

/// Returns the child node with the given name 
/// @param name - child name.
/// @returns the first occurrence if there is more than one.
- (XmlElement *)selectSingleNode: (NSString *)name;

/// Returns the nth child with the given name.
/// @param name - child name.
/// @param at - position index (starting from zero).
/// @returns the nth child with the given name.
- (XmlElement *)selectSingleNode: (NSString *)name at: (NSInteger)position;

/// Returns attribute value.
/// @param name - attribute name.
/// @returns attribute value.
- (NSString *)attrValue: (NSString *)name;

@end
