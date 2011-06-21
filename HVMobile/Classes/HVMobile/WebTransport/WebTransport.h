//
//  WebTransport.h
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


/// Class to simplify making POSTs and obtaining the responses.
@interface WebTransport : NSObject {

    NSMutableData *_responseBody;
    NSObject *_context;
    NSObject *_target;
    SEL _callBack;
}

/// Returns whether all requests and responses should be logged.
+ (BOOL)isRequestResponseLogEnabled;

/// Sets current logging status. 
/// @param enabled - If YES then both request and response will be logged.
+ (void)setRequestResponseLogEnabled: (BOOL)enabled;

/// Sends a post request to a specific URL.
/// @param url - string which contains server address.
/// @param data - string will be sent in POST header.
/// @param context - any object will be passed to callBack with response.
/// @param target - callback method owner.
/// @param callBack - the method to call when the request has completed.
+ (void)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack;

@end
