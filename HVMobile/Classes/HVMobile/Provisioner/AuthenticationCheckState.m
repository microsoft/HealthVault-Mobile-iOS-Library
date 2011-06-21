//
//  AuthenticationCheckState.m
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

#import "AuthenticationCheckState.h"
#import "HealthVaultService.h"


@implementation AuthenticationCheckState

@synthesize service = _service;
@synthesize target = _target;
@synthesize authCompletedCallBack = _authCompletedCallBack;
@synthesize shellAuthRequiredCallBack = _shellAuthRequiredCallBack;

- (id)initWithService: (HealthVaultService *)service target: (NSObject *)target
                                      authCompletedCallBack: (SEL)authCallBack
                                   shellAuthRequiredCallBack: (SEL)authRequiredCallBack {

    if (self = [super init]) {

        self.service = service;
        self.target = target;
        self.authCompletedCallBack = authCallBack;
        self.shellAuthRequiredCallBack = authRequiredCallBack;
    }

    return self;
}

- (void)dealloc {

    self.service = nil;
    self.target = nil;

    [super dealloc];
}

@end
