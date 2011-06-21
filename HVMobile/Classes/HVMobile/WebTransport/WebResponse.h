//
//  WebResponse.h
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


/// Represents xml response from HealthVault server.
/// The data related to a request.
@interface WebResponse : NSObject {

	NSString *_responseData;
	NSString *_errorText;
}

/// Gets or sets the response data.
@property (retain) NSString *responseData;

/// Gets or sets the error text.
@property (retain) NSString *errorText;

/// Gets error status for response. Returns YES if request has been failed.
@property (readonly, getter = getHasError) BOOL hasError;

@end
