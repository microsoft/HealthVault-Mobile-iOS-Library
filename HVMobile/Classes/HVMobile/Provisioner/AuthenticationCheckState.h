//
//  AuthenticationCheckState.h
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


@class HealthVaultService;

/// The data required to perform the authentication flow.
@interface AuthenticationCheckState : NSObject {

    HealthVaultService *_service;
    NSObject *_target;
    SEL _authCompletedCallBack;
    SEL _shellAuthRequiredCallBack;
}

/// Gets or sets the service.
@property (retain) HealthVaultService *service;

/// Gets or sets the callback handler.
@property (retain) NSObject *target;

/// Gets or sets the authentication completed handler.
@property (assign) SEL authCompletedCallBack;

// Gets or sets the Shell Authorization required handler.
@property (assign) SEL shellAuthRequiredCallBack;

/// Initializes a new instance of the AuthenticationCheckState class.
/// @param service - the HealthVaultService instance.
/// @param target - callBack method owner.
/// @param authCallBack - callback if shell authorization is completed.
/// @param authRequiredCallBack - callBack if shell authorization is required.
- (id)initWithService: (HealthVaultService *)service
			   target: (NSObject *)target
authCompletedCallBack: (SEL)authCallBack
shellAuthRequiredCallBack: (SEL)authRequiredCallBack;

@end
