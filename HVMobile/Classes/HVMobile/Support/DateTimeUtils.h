//
//  DateTimeUtils.h
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

/// Provides date conversion utilities.
@interface DateTimeUtils : NSObject

/// Converts date to UTC formatted string.
/// @param date - date to be converted.
/// @returns UTC formatted string.
+ (NSString *)dateToUtcString: (NSDate *)date;

/// Converts string with date in UTC format to date object.
/// @param string - string to be converted.
/// @returns date in UTC format.
+ (NSDate *)UtcStringToDate: (NSString *)string;

@end
