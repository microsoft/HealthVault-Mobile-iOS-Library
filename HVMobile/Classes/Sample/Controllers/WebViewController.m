//
// WebViewController.m
// Weight Tracker sample application
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


#import "WebViewController.h"
#import "WeightTrackerAppDelegate.h"


@implementation WebViewController

- (id)initWithUrl: (NSString *)url {

	if (self = [super init]) {

		self.title = @"Sign In";
		_urlAddress = [url retain];
	}

	return self;
}

- (void)dealloc {

	[_urlAddress release];

	[super dealloc];
}

- (void)viewWillDisappear: (BOOL)animated {
	
	[_webView stopLoading];
}

- (void)viewDidLoad {

	[super viewDidLoad];
	
	[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: _urlAddress]]];
}

#pragma mark Web View Events

- (BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request
 navigationType: (UIWebViewNavigationType)navigationType {

	NSString *urlAbsoluteString = [[request URL] absoluteString];

	// If URL contains "arget=AppAuthSuccess" then operaion of connecting app
	// to records finished success.
	// Redirect to Main screen.
	NSRange authSuccessRange = [urlAbsoluteString rangeOfString: @"target=AppAuthSuccess"];
	if (authSuccessRange.location != NSNotFound) {

		[webView stopLoading];
		[self.navigationController popViewControllerAnimated: YES];
	}

	return YES;
}

- (void)webViewDidStartLoad: (UIWebView *)webView {

	// Shows progress view when web view loading page.
	[WeightTrackerAppDelegate showProgressView];
}

- (void)webViewDidFinishLoad: (UIWebView *)webView {

	// Hides progress view.
	[WeightTrackerAppDelegate hideProgressView];
}

- (void)webView: (UIWebView *)webView didFailLoadWithError: (NSError *)error {

	// Hides progress view.
	[WeightTrackerAppDelegate hideProgressView];
	
	// "The operation couldn't be completed" error code.
	const int OperationCouldNotBeCompletedCode = -999;
	
	// We should filter this error. Because it occures in case
	// when we manualy perform "stopLoading" for web view.
	if([error code] == OperationCouldNotBeCompletedCode)
		return;
	
	[webView stopLoading];
	// Shows alert to user with "Try Again" and "Back" buttons.
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
													message: [error localizedDescription]
												   delegate: self
										  cancelButtonTitle: @"Back"
										  otherButtonTitles: @"Try again", nil];
	[alert show];
	[alert autorelease];
}

#pragma mark Web View Events End

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
	
	// "Try Again" button index.
	const int TryAgainButtonIndex = 1;
	
	if(buttonIndex == TryAgainButtonIndex) {
		
		// If user pressed "Try Again" button then we are trying to reload web view.
		[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: _urlAddress]]];
	}
	else {
		
		// If "Back" button has been pressed return to previus screen.
		[self.navigationController popViewControllerAnimated: YES];
	}
}

@end
