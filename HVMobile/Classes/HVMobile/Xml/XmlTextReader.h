//
//  XmlTextReader.h
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
#import "XmlElement.h"

/// Reads xml data and creates xml tree.
@interface XmlTextReader : NSObject <NSXMLParserDelegate> {

	/// Xml tree root element.
	XmlElement *_rootElement;

	/// Stack used for creating xml tree.
	NSMutableArray *_elements;
}

/// Reads xml data, creates xml tree.
/// @param xml - xml text to parse.
/// @returns reference to tree root element.
- (XmlElement *)read: (NSString *)xml;

@end
