//
//  WebTransport.m
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

#import "WebTransport.h"
#import "WebResponse.h"
#import "Logger.h"
#import "HealthVaultConfig.h"


/// Default HTTP method.
#define DEFAULT_HTTP_METHOD @"POST"

/// Default timeout time for request.
/// Apple-recommended value for such operations.
#define DEFAULT_REQUEST_TIMEOUT 240

@interface WebTransport (Private)

/// Logs message, prints it to console.
/// @param message - message to be written.
+ (void)addMessageToRequestResponseLog: (NSString *)message;

/// Sends a post request to a specific URL.
/// @param url - string which contains server address.
/// @param data - string will be sent in POST header.
/// @param context - any object will be passed to callBack with response.
/// @param target - callback method owner.
/// @param callBack - the method to call when the request has completed.
- (void)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack;

/// Performs callBack on target when response is received.
/// @param response - response to send.
- (void)performCallBack: (WebResponse *)response;

@end


@implementation WebTransport

/// Represents logging status (enabled/disabled).
static BOOL _isRequestResponseLogEnabled = HEALTH_VAULT_TRACE_ENABLED;

- (void)dealloc {

    [_target release];
    [_context release];
    [_responseBody release];

    [super dealloc];
}

#pragma mark Static Messages

+ (BOOL)isRequestResponseLogEnabled {

    return _isRequestResponseLogEnabled;
}

+ (void)setRequestResponseLogEnabled: (BOOL)enabled {

    @synchronized (self) {

        _isRequestResponseLogEnabled = enabled;
    }
}

+ (void)addMessageToRequestResponseLog: (NSString *)message {

    if (!_isRequestResponseLogEnabled) {
        return;
    }

    [Logger write: [NSString stringWithFormat: NSLocalizedString(@"HealthVault web transport message key",
																 @"Format to display web transport message"), message]];
}

#pragma mark Static Messages End

+ (void)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack {

    WebTransport *transport = [[WebTransport new] autorelease];
    [transport sendRequestForURL: url
            withData: data
            context: context
            target: target
            callBack: callBack];
}

- (void)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack {

    _target = [target retain];
    _callBack = callBack;
    _context = [context retain];
    _responseBody = [[NSMutableData data] retain];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
	
#ifdef CONNECTION_ALLOW_ANY_HTTPS_CERTIFICATE
	// required for unit tests, see http://www.openradar.me/8385355
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString: url] host]];
	// alternative way is handling canAuthenticateAgainstProtectionSpace challannge
	// http://stackoverflow.com/questions/933331/
#endif
	
    [request setTimeoutInterval: DEFAULT_REQUEST_TIMEOUT];

    if (data) {
        [WebTransport addMessageToRequestResponseLog: data];

        NSData *xmlData = [data dataUsingEncoding: NSUTF8StringEncoding];

        [request setHTTPMethod: DEFAULT_HTTP_METHOD];
        [request addValue: [NSString stringWithFormat: @"%d", xmlData.length] forHTTPHeaderField: @"Content-Length"];
        [request setHTTPBody: xmlData];
    }

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
    [connection start];
}

#pragma mark Connection Events

- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {

    if (_responseBody) {
        [_responseBody setLength: 0];
    }
}

- (void)connection: (NSURLConnection *)conn didReceiveData: (NSData *)data {

    if (_responseBody && data) {
        [_responseBody appendData: data];
    }
}

- (void)connectionDidFinishLoading: (NSURLConnection *)conn {

	TraceComponentMessage(@"WebTransport", NSLocalizedString(@"Received bytes key",
															 @"Format to display amount of received bytes"), _responseBody.length);

    NSString *responseString = [[NSString alloc] initWithData: _responseBody encoding: NSUTF8StringEncoding];

    [WebTransport addMessageToRequestResponseLog: responseString];

    WebResponse *response = [WebResponse new];
    response.responseData = responseString;
    [self performCallBack: response];
    [response release];
    [responseString release];

    [conn release];
}

- (void)connection: (NSURLConnection *)conn didFailWithError: (NSError *)error {

    NSString *errorString = [error localizedDescription];

    TraceComponentError(@"WebTransport", NSLocalizedString(@"Connection error key",
														   @"Format to display connection error"), errorString);

    [WebTransport addMessageToRequestResponseLog: errorString];

    WebResponse *response = [WebResponse new];
    response.errorText = errorString;
    [self performCallBack: response];
    [response release];

    [conn release];
}

#pragma mark Connection Events End

- (void)performCallBack: (WebResponse *)response {

    if (_target && [_target respondsToSelector: _callBack]) {

        [_target performSelector: _callBack withObject: response withObject: _context];
    }
}

@end
