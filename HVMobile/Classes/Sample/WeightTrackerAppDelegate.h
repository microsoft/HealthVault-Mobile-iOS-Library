//
// WeightTrackerAppDelegate.h
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

#import <UIKit/UIKit.h>
#import "HealthVaultService.h"


/// Application delegate.
@interface WeightTrackerAppDelegate : NSObject <UIApplicationDelegate> {

	IBOutlet UINavigationController *_navigationController;
	IBOutlet UIWindow *_window;
	IBOutlet UIView *_progressView;
}

/// Gets application window.
@property(readonly) UIWindow *window;

/// Gets application navigation controller.
@property(readonly) UINavigationController *navigationController;

/// Gets application progress view.
@property(readonly) UIView *progressView;

/// Returns instance of app delegate (ICanWeightAppDelegate instance).
/// @returns WeightTrackerAppDelegate instance.
+ (WeightTrackerAppDelegate *)instance;

/// Returns instance of HealthVault service.
/// @returns HealthVaultService instance.
+ (HealthVaultService *)healthVaultService;

/// Shows progress view.
+ (void)showProgressView;

/// Hides progress view.
+ (void)hideProgressView;

/// Shows Intro screen.
/// @param target - callback method owner.
/// @param callBack - callback will call when user presses "Continue" button on Intro screen.
+ (void)showIntroScreenWithTarget: (NSObject *)target andContinueCallback: (SEL)callBack;

/// Shows alert with error message.
/// @param errorMessage - error message text.
/// @param target - callback methods owner.
+ (void)showAlertWithError: (NSString *)errorMessage target: (NSObject *)target;

@end

