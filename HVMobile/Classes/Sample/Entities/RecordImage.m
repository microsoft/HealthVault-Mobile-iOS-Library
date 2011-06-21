//
// RecordImage.m
// Weight Tracker sample application
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

#import "RecordImage.h"
#import "XmlTextReader.h"
#import "Base64.h"
#import "WeightTrackerAppDelegate.h"


@implementation RecordImage

@synthesize image = _image;

- (void)dealloc {

	self.image = nil;

	[super dealloc];
}


#pragma mark Xml Logic

/// Parses xml and returns new RecordImage object.
/// @param xml - xml with image in Base64 string.
/// @returns RecordImage instance.
+ (RecordImage *)parseImageFromXml: (NSString *)xml {

	// Parses response and retrives record image.
	XmlTextReader *xmlReader = [[XmlTextReader new] autorelease];
	XmlElement *infoNode = [xmlReader read: xml];
	XmlElement *groupNode = [infoNode selectSingleNode: @"group"];
	NSArray *blobNodes = [[groupNode selectSingleNode: @"thing"] selectNodes: @"blob-payload"];

	for (XmlElement *blobNode in blobNodes) {

		XmlElement *base64DataNode = [[blobNode selectSingleNode: @"blob"] selectSingleNode: @"base64data"];
		if (base64DataNode) {

			RecordImage *recordImage = [RecordImage new];

			NSString *base64ImageString = base64DataNode.text;
			recordImage.image = [UIImage imageWithData: [Base64 decodeBase64WithString: base64ImageString]];

			return [recordImage autorelease];
		}
	}

	return nil;
}

#pragma mark Xml Logic End


#pragma mark Server Logic

/// Loads image(avatar) for current record.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
+ (void)loadRecordImage: (NSObject *)target callBack: (SEL)callBack {

	// Prepares xml to load image for currect record.
	NSString *xml = 
			@"<info>"
				"<group>"
					"<filter>"
						"<type-id>a5294488-f865-4ce3-92fa-187cd3b58930</type-id>"
						"<thing-state>Active</thing-state>"
					"</filter>"
					"<format>"
						"<section>core</section>"
						"<section>blobpayload</section>"
						"<type-version-format>a5294488-f865-4ce3-92fa-187cd3b58930</type-version-format>"
						"<blob-payload-request>"
							"<blob-format>"
								"<blob-format-spec>inline</blob-format-spec>"
							"</blob-format>"
						"</blob-payload-request>"
					"</format>"
				"</group>"
			"</info>";

	// Sends request to server.
	HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																   methodVersion: 3
																	 infoSection: xml
																		  target: target
																		callBack: callBack];
	[[WeightTrackerAppDelegate healthVaultService] sendRequest: request];
	[request release];
}

#pragma mark Server Logic

@end
