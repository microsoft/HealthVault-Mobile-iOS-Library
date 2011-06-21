//
//  HealthVaultSettings.h
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

/// Provides settings management functionality.
@interface HealthVaultSettings : NSObject {

	NSString *_version;
	NSString *_applicationId;
	NSString *_applicationCreationToken;
	NSString *_authorizationSessionToken;
	NSString *_sharedSecret;
	NSString *_country;
	NSString *_language;
	NSString *_sessionSharedSecret;
	NSString *_personId;
	NSString *_recordId;
	NSString *_name;
}

/// Gets or sets the settings name.
@property (retain) NSString *name;

/// Gets or sets application version.
@property (retain) NSString *version;

/// Gets or sets the application Id. 
@property (retain) NSString *applicationId;

/// Gets or sets the application creation token.
@property (retain) NSString *applicationCreationToken;

/// Gets or sets the authorization session token.
@property (retain) NSString *authorizationSessionToken;

/// Gets or sets the shared secret.
@property (retain) NSString *sharedSecret;

/// Gets or sets country.
@property (retain) NSString *country;

/// Gets or sets language.
@property (retain) NSString *language;

/// Gets or sets session shared secret.
@property (retain) NSString *sessionSharedSecret;

/// Gets or sets person Id.
@property (retain) NSString *personId;

/// Gets or sets record Id.
@property (retain) NSString *recordId;

/// Initializes settings with specific name.
/// @param name - settings file name.
- (id)initWithName: (NSString *)name;

/// Saves settings.
- (void)save;

/// Loads settings with specified name.
/// @param name - settings file name.
/// @returns settings instance loaded with specific name.
+ (HealthVaultSettings *)loadWithName: (NSString *)name;

@end
