//
// Weight.h
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


/// Represents HealthVault Weight thing.
@interface Weight : NSObject {

	NSString *_weightId;
	NSDate *_effDate;
	NSString *_display;
	NSString *_units;
	NSString *_versionStamp;
}

/// Gets or sets weight Id (thing Id).
@property(retain) NSString *weightId;

/// Gets or sets eff-date.
@property(retain) NSDate *effDate;

/// Gets or sets weight display value.
@property(retain) NSString *display;

/// Gets or sets weight units.
@property(retain) NSString *units;

/// Gets or sets version stamp.
@property(retain) NSString *versionStamp;

/// Puts new weight to HealthVault server for current record.
/// @param pounds - pounds value.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
+ (void)putWeight: (double)pounds
		   target: (NSObject *)target
		 callBack: (SEL)callBack;

/// Deletes specified weights for current record.
/// @param weights - array of Weight which should be deleted.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
+ (void)deleteAllWeights: (NSArray *)weights
				  target: (NSObject *)target
				callBack: (SEL)callBack;

/// Loads all weights for current record.
/// @param target - callback method owner.
/// @param callBack - callback which is invoked when operation is completed.
+ (void)loadWeights: (NSObject *)target callBack: (SEL)callBack;

/// Parses xml and returns array of Weight objects.
/// @param xml - xml with weights.
/// @returns array of Weight instances.
+ (NSArray *)parseWeightsFromXml: (NSString *)xml;

@end
