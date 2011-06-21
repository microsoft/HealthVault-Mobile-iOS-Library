//
//  WebResponse.m
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

#import "WebResponse.h"


@implementation WebResponse

@synthesize responseData = _responseData;
@synthesize errorText = _errorText;

- (void)dealloc {

	self.responseData = nil;
	self.errorText = nil;

	[super dealloc];
}

- (BOOL)getHasError {

    return self.errorText != nil;
}

@end
