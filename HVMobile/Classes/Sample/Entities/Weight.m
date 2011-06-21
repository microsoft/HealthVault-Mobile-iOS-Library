//
// Weight.m
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

#import "Weight.h"
#import "XmlTextReader.h"
#import "DateTimeUtils.h"
#import "WeightTrackerAppDelegate.h"


@interface Weight (Private)

/// Generates xml with date in HealthVault format.
/// @param date - specified date.
/// @returns xml with date in HealthVault format.
+ (NSString *)getWhenXmlForDate: (NSDate *)date;

@end

@implementation Weight

@synthesize weightId = _weightId;
@synthesize effDate = _effDate;
@synthesize display = _display;
@synthesize units = _units;
@synthesize versionStamp = _versionStamp;

- (void)dealloc {

	self.weightId = nil;
	self.effDate = nil;
	self.display = nil;
	self.units = nil;
	self.versionStamp = nil;

	[super dealloc];
}


#pragma mark Xml Logic

/// Parses xml and returns array of Weight objects.
/// @param xml - xml with weights.
/// @returns array of Weight instances.
+ (NSArray *)parseWeightsFromXml: (NSString *)xml {

	XmlTextReader *xmlReader = [XmlTextReader new];

	XmlElement *infoNode = [xmlReader read: xml];
	XmlElement *groupNode = [infoNode selectSingleNode: @"group"];
	NSArray *thingNodes = [groupNode selectNodes: @"thing"];

	NSMutableArray *weights = [[NSMutableArray new] autorelease];

	for (XmlElement *thingNode in thingNodes) {

		Weight *weight = [Weight new];

		XmlElement *thingIdNode = [thingNode selectSingleNode: @"thing-id"];
		weight.weightId = thingIdNode.text;
		weight.versionStamp = [thingIdNode.attributes objectForKey: @"version-stamp"];

		XmlElement *displayNode = [[[[thingNode selectSingleNode: @"data-xml"]
				selectSingleNode: @"weight"] selectSingleNode: @"value"] selectSingleNode: @"display"];

		weight.display = displayNode.text;
		weight.units = [displayNode.attributes objectForKey: @"units"];

		NSString *effDateString = [thingNode selectSingleNode: @"eff-date"].text;
		weight.effDate = [DateTimeUtils UtcStringToDate: effDateString];

		[weights addObject: weight];
		[weight release];
	}

	[xmlReader release];

	return weights;
}

/// Generates xml with date in HealthVault format.
/// @param date - specified date.
/// @returns xml with date in HealthVault format.
+ (NSString *)getWhenXmlForDate: (NSDate *)date {

	// Retrieves date values.
	NSUInteger calendarUnits = NSDayCalendarUnit | NSMonthCalendarUnit | 
		NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | 
		NSSecondCalendarUnit;
	
	// We are using UTC for timestamp.
	NSCalendar *calendar = [[NSCalendar alloc]   initWithCalendarIdentifier: NSGregorianCalendar];
	[calendar setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"UTC"]];

	NSDateComponents *components = [calendar components: calendarUnits
											   fromDate: date];
	[calendar release];
	
	NSInteger year = [components year];
	NSInteger month = [components month];
	NSInteger day = [components day];

	NSInteger hour = [components hour];
	NSInteger minute = [components minute];
	NSInteger second = [components second];
	NSInteger milliSecond = 0;
	
	

	// Prepares xml.
	NSString *xml = [NSString stringWithFormat: 
				@"<when>"
					 "<date>"
						"<y>%i</y>"
						"<m>%i</m>"
						"<d>%i</d>"
					"</date>"
					 "<time>"
						"<h>%i</h>"
						"<m>%i</m>"
						"<s>%i</s>"
						"<f>%i</f>"
					 "</time>"
				"</when>",
			year, month, day, hour, minute, second, milliSecond];
	
	return xml;
}

#pragma mark XML Logic


#pragma mark Server Logic

/// Puts new weight to HealtVault server for current record.
/// @param pounds - pounds value.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
+ (void)putWeight: (double)pounds
		   target: (NSObject *)target
		 callBack: (SEL)callBack {

	NSString *poundsString = [NSString stringWithFormat: @"%.2f", pounds];

	// Converts pounds to kgs.
	const double PoundsToKgsRatio = 2.204;
	double kgs = pounds / PoundsToKgsRatio;
	NSString *kgsString = [NSString stringWithFormat: @"%f", kgs];

	NSDate *dateNow = [NSDate date];
	NSString *whenString = [self getWhenXmlForDate: dateNow];

	// Prepares weight thing xml. It should contain:
	// weight in pounds
	// weight in kgs
	// creation date ('when' tag).
	NSString *xml = [NSString stringWithFormat:
					 @"<info>"
						"<thing>"
							"<type-id>3d34d87e-7fc1-4153-800f-f56592cb0d17</type-id>"
							"<thing-state>Active</thing-state>"
							"<flags>0</flags>"
							"<data-xml>"
								"<weight>"
									"%@"
									"<value>"
										"<kg>%@</kg>"
										"<display units=\"pounds\">%@</display>"
									"</value>"
								"</weight>"
								"<common/>"
							"</data-xml>"
						"</thing>"
					 "</info>", 
					 whenString, kgsString, poundsString];

	// Sends request for putting.
	HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"PutThings"
																   methodVersion: 2
																	 infoSection: xml
																		  target: target
																		callBack: callBack];
	[[WeightTrackerAppDelegate healthVaultService] sendRequest: request];
	[request release];
}

/// Deletes specified weights for current record.
/// @param weights - array of Weight which should be deleted.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
+ (void)deleteAllWeights: (NSArray *)weights
				  target: (NSObject *)target
				callBack: (SEL)callBack {

	// Prepares xml for deleting weights.
	NSMutableString *xml = [[NSMutableString new] autorelease];

	[xml appendString: @"<info>"];

	// Puts thing id to xml.
	for (Weight *weight in weights) {

		NSString *thingId = [NSString stringWithFormat: @"<thing-id version-stamp='%@'>%@</thing-id>",
				weight.versionStamp, weight.weightId];
		[xml appendString: thingId];
	}

	[xml appendString: @"</info>"];

	// Sends request for deleting.
	HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"RemoveThings"
																   methodVersion: 1
																	 infoSection: xml
																		  target: target
																		callBack: callBack];
	[[WeightTrackerAppDelegate healthVaultService] sendRequest: request];
	[request release];
}

/// Composes HealthVaultRequest to load weights.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
/// @returns HealthVaultRequest instance.
+ (HealthVaultRequest *)getLoadWeightsRequest: (NSObject *)target
									 callBack: (SEL)callBack {
	// Prepares xml for retrieving weights.
	NSString *xml = 
	@"<info>"
		"<group>"
			"<filter>"
				"<type-id>3d34d87e-7fc1-4153-800f-f56592cb0d17</type-id>"
				"<thing-state>Active</thing-state>"
			"</filter>"
			"<format>"
				"<section>core</section>"
				"<xml/>"
				"<type-version-format>3d34d87e-7fc1-4153-800f-f56592cb0d17</type-version-format>"
			"</format>"
		"</group>"
	"</info>";
	
	// Request for retrieving weights.
	HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"GetThings"
																   methodVersion: 3
																	 infoSection: xml
																		  target: target
																		callBack: callBack];
	return [request autorelease];
}

/// Loads all weights for current record.
/// @param target - callback method owner.
/// @param callBack - callback which invoked when operation is completed.
+ (void)loadWeights: (NSObject *)target
		   callBack: (SEL)callBack {
	
	HealthVaultRequest *request = [self getLoadWeightsRequest: target
													 callBack: callBack];
	[[WeightTrackerAppDelegate healthVaultService] sendRequest: request];
}

#pragma mark Server Logic End

@end
