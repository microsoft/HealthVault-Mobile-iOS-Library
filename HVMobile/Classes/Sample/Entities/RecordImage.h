//
// RecordImage.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Represents HealthVault Record Image thing.
@interface RecordImage : NSObject {

	UIImage *_image;
}

/// Gets or sets record image (avatar).
@property(retain) UIImage *image;

/// Loads image(avatar) for current record.
/// @param target - callback method owner.
/// @param callBack - callback which is invoked when operation is completed.
+ (void)loadRecordImage: (NSObject *)target callBack: (SEL)callBack;

/// Parses xml and returns new RecordImage object.
/// @param xml - xml with image in Base64 string.
/// @returns RecordImage instance.
+ (RecordImage *)parseImageFromXml: (NSString *)xml;

@end
