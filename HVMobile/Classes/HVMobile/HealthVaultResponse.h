//
//  HealthVaultResponse.h
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
#import "WebResponse.h"
#import "HealthVaultRequest.h"

/// OK status
#define RESPONSE_OK  0;

/// App does not exist, app is invalid, app is not active or calling IP is invalid.
#define RESPONSE_INVALID_APPLICATION 6

/// Represents security problem for current app.
#define RESPONSE_ACCESS_DENIED 8

/// Represents that current token has been expired and should be updated. 
#define RESPONSE_AUTH_SESSION_TOKEN_EXPIRED 65

/// Implements HealthVault response.
@interface HealthVaultResponse : NSObject {

	int _statusCode;
	NSString *_infoXml;
	NSString *_responseXml;
	NSString *_errorText;
	NSString *_errorContextXml;
	NSString *_errorInfo;

	HealthVaultRequest *_request;
}

/// Gets or sets numeric status code of the operation.
@property (assign) int statusCode;

/// Gets or sets the informational part of the response.
@property (retain) NSString *infoXml;

/// Gets or sets the raw xml that was returned from the request.
@property (retain) NSString *responseXml;

/// Gets or sets the text of the error that occurred.
/// If the error was returned from the HealthVault service,
/// additional error information may be found in the ResponseXml.
@property (retain) NSString *errorText;

/// Gets or sets a contextual xml description of the the error.
@property (retain) NSString *errorContextXml;

/// Gets or sets the informational part of the response.
@property (retain) NSString *errorInfo;

/// Gets or sets the request that was sent.
@property (retain) HealthVaultRequest *request;

/// Indicates whether the operation has failed.
@property (readonly, getter=getHasError) BOOL hasError;

/// Initializes a new instance of the HealthVaultResponse class.
/// @param webResponse - the web response from server side.
/// @request - the original request.
- (id)initWithWebResponse: (WebResponse *)webResponse
				  request: (HealthVaultRequest *)request;

@end
