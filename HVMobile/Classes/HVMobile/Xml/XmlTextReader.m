//
//  XmlTextReader.m
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

#import <Foundation/NSXMLParser.h>
#import "XmlTextReader.h"
#import "Logger.h"

// Specifies the initial capacity for the array which stores child nodes for the element.
#define ELEMENT_CHILD_STORE_INITIAL_CAPACITY 3

// Specifies the initial length (capacity) of the string to store element text.
#define ELEMENT_CONTENT_INITIAL_CAPACITY 50

@implementation XmlTextReader

- (id)init {

	if (self = [super init]) {

		_elements = [NSMutableArray new];
		_rootElement = nil;
	}

	return self;
}

- (void)dealloc {

	[_rootElement release];
	[_elements release];

	[super dealloc];
}

- (XmlElement *)read: (NSString *)xml {
	
	NSData *xmlData = [xml dataUsingEncoding: NSUTF8StringEncoding];
	
	// set up internal SAX xmlReader instance (NSXMLParser)
	NSXMLParser *xmlReader = [[NSXMLParser alloc] initWithData: xmlData];
	[xmlReader setShouldProcessNamespaces: YES];
	[xmlReader setShouldReportNamespacePrefixes: YES];
	xmlReader.delegate = self;
	
	@try {

		// perform parsing itself
		if ([xmlReader parse]) {

			//Document parsing is done. No action required.
		}
		else { // xml is not valid, trace this event
		
			TraceComponentError(@"XMLxmlReader", @"%@ %@", @"Document parsing has failed; xml = ", xml);
			return nil;
		}
	}
	@finally {
		
		// be sure we released xmlReader instance
		[xmlReader release];
	}

	return _rootElement;
}

// Called when the start of an element is encountered in the document, this provides the name of the element, 
// a dictionary containing the attributes (if any) and (where namespaces are used) the namespace information for the element. 
// For more details see  NSXMLParser: didStartElement: namespaceURI: qualifiedName: attributes: 
- (void)parser: (NSXMLParser *)xmlReader didStartElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI
	qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributeDict {

	XmlElement *current = [XmlElement new];
	current.name = elementName;
	
	// copy attributes
	NSMutableDictionary *elementAttributes = [attributeDict mutableCopy];
	current.attributes = elementAttributes;
	[elementAttributes release];
	
	// children
	NSMutableDictionary *elementChildren = [NSMutableDictionary new];
	current.children = elementChildren;
	[elementChildren release];
	
	// if this is a root element
	if (_rootElement == nil) {
		
		_rootElement = [current retain];
		
	} else {
		
		XmlElement *parent = [_elements lastObject];
		
		NSMutableArray *children = [[parent children] objectForKey: current.name];
		
		if (children == nil) {
			
			children = [[NSMutableArray alloc] initWithCapacity: ELEMENT_CHILD_STORE_INITIAL_CAPACITY];
			[[parent children] setObject: children forKey: current.name];
			[children release];
		}
		
		[children addObject: current];
	}

	[_elements addObject: current];
	[current release];
}

// Called when the end of an element is encountered in the document.
- (void)parser: (NSXMLParser *)xmlReader didEndElement: (NSString *)elementName
		namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qName {

	[_elements removeLastObject];
}
// Called when the xmlReader found characters for the element.
// This can be called multiple times for the same element.
- (void)parser: (NSXMLParser *)xmlReader foundCharacters: (NSString *)string {

	XmlElement *current = [_elements lastObject];

	if (!current.text) {
		
		current.text = [NSMutableString stringWithCapacity: ELEMENT_CONTENT_INITIAL_CAPACITY];
	}
	[current.text appendString: string];
}

@end
