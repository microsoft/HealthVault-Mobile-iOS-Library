//
// WeightTrackerAppDelegate.m
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

#import "WeightTrackerAppDelegate.h"
#import "HealthVaultService.h"

#import "IntroViewController.h"

#import "Settings.h"
#import <mach/mach.h>


@interface WeightTrackerAppDelegate (Private)

/// Initializes HealthValueService instance.
+ (void)initHealthVault;

/// Starts memory tracking one time in specified interval.
- (void)startTrackingMemoryUsage;

@end


@implementation WeightTrackerAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize progressView = _progressView;

/// HealthVault service instance.
/// Initialized by initHealthVault method.
static HealthVaultService *_healthVaultService = nil;


#pragma mark Application Lifecycle

- (BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions {

	// Initializes HealthValueService instance.
	[WeightTrackerAppDelegate initHealthVault];
	
	_window.rootViewController = _navigationController;
	[_window makeKeyAndVisible];


#ifdef ENABLE_MEMORY_TRACKER
	[self startTrackingMemoryUsage];
#endif

	return YES;
}

#pragma mark Application Lifecycle End


/// Initializes HealthVaultService instance.
+ (void)initHealthVault {

	_healthVaultService = [[HealthVaultService alloc] initWithUrl: HEALTH_VAULT_PLATFORM_URL
														 shellUrl: HEALTH_VAULT_SHELL_URL
													  masterAppId: HEALTH_VAULT_MASTER_APPLICATION_ID];
	// Loads default settings for service.
	[_healthVaultService loadSettings: @"Default"];

#ifdef LOG_SERVER_REQUEST_AND_RESPONSE
	//where to trace communication with HealthVault messages or not
	[WebTransport setRequestResponseLogEnabled: LOG_SERVER_REQUEST_AND_RESPONSE];
#endif
	
}

/// Returns instance of app delegate (ICanWeightAppDelegate instance).
/// @returns WeightTrackerAppDelegate instance.
+ (WeightTrackerAppDelegate *)instance {

	return (WeightTrackerAppDelegate *)[UIApplication sharedApplication].delegate;
}

/// Returns instance of HealthVault service.
/// @returns HealthVaultService instance.
+ (HealthVaultService *)healthVaultService {

	return _healthVaultService;
}

/// Shows progress view.
+ (void)showProgressView {

	WeightTrackerAppDelegate *appDelegate = [WeightTrackerAppDelegate instance];
	[appDelegate.window addSubview: appDelegate.progressView];
	[appDelegate.window bringSubviewToFront: appDelegate.progressView];
}

/// Hides progress view.
+ (void)hideProgressView {

	WeightTrackerAppDelegate *appDelegate = [WeightTrackerAppDelegate instance];
	[appDelegate.progressView removeFromSuperview];
}

/// Shows Intro screen.
/// @param target - callback method owner.
/// @param callBack - callback will call when user press "Continue" button on Intro screen.
+ (void)showIntroScreenWithTarget: (NSObject *)target andContinueCallback: (SEL)callBack {

	IntroViewController *introController = [[IntroViewController alloc] initWithTarget: target
																   andContinueCallback: callBack];
	[[WeightTrackerAppDelegate instance].navigationController pushViewController: introController
																	 animated: YES];
	[introController release];
}

/// Shows alert with error message.
/// @param errorMessage - error message text.
/// @param target - callback methods owner.
+ (void)showAlertWithError: (NSString *)errorMessage target: (NSObject *) target {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
													message: errorMessage
												   delegate: target
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert autorelease];
}

#pragma mark Memory Tracker

/// Starts memory tracking one time in specified interval.
- (void)startTrackingMemoryUsage {

	[NSTimer scheduledTimerWithTimeInterval: MEMORY_TRACKER_TIME_INTERVAL
									 target: self
								   selector: @selector(updateMemoryStatusIndicator)
								   userInfo: nil
									repeats: YES];
}

/// Updates memory usage indicator with current value.
- (void)updateMemoryStatusIndicator {

	// Retrieves current memory using info.
	struct task_basic_info info;
	mach_msg_type_number_t size = sizeof(info);
	kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);

	const int BytesPerMegabyte = 1024 * 1024;
	float currentMemoryUsage = ((kerr == KERN_SUCCESS) ? info.resident_size : -1) / BytesPerMegabyte;

	static UILabel *memoryStatusLabel = nil;

	if (!memoryStatusLabel) {

		memoryStatusLabel = [[UILabel alloc] initWithFrame: CGRectMake(110, 1, 100, 10)];
		memoryStatusLabel.backgroundColor = [UIColor clearColor];
		memoryStatusLabel.textColor = [UIColor whiteColor];
		memoryStatusLabel.textAlignment = UITextAlignmentCenter;
		memoryStatusLabel.font = [UIFont systemFontOfSize: 9];

		[_navigationController.navigationBar addSubview: memoryStatusLabel];
	}

	if (currentMemoryUsage > 0)
		memoryStatusLabel.text = [NSString stringWithFormat: @"%4.3f Mbytes", currentMemoryUsage];
	else
		memoryStatusLabel.text = @"Error";
}

#pragma mark Memory Tracker End

@end
