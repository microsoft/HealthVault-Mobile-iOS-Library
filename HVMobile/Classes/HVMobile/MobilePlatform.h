//
//  MobilePlatform.h
//  HealthVault Mobile Library for iPhone
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

/// Implements the platform-specific methods used by the HealthVaultService class.
@interface MobilePlatform : NSObject {

}

/// Gets a name and version for this platform/library combination.
+ (NSString *)platformAbbreviationAndVersion;

/// Gets a name for the device.
+ (NSString *)deviceName;

/// Computes a SHA 256 hash.
/// @param data - the data to hash.</param>
/// @returns the hash as a base64-encoded string.</returns>
+ (NSString *)computeSha256Hash: (NSString *)data;

/// Computes a SHA 256 hash and wraps the result in XML.
/// @param  data - the data to hash.</param>
/// @returns the wrapped hash.</returns>
+ (NSString *)computeSha256HashAndWrap: (NSString *)data;

/// Computes a SHA 256 HMAC.
/// @param key - the key to use.</param>
/// @param data - the input data.</param>
/// @returns a base-64 encoded HMAC.</returns>
+ (NSString *)computeSha256Hmac:(NSData *)key: (NSString *)data;

/// Computes a SHA 256 HMAC and wraps the result in XML.
/// @param key - the key to use.</param>
/// @param data - the input data.</param>
/// @returns the wrapped result.</returns>
+ (NSString *)computeSha256HmacAndWrap: (NSData *)key: (NSString *)data;

@end
