//
// IntroViewController.h
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


/// Screen contains user introduction text,
/// should be shown before login screen.
@interface IntroViewController : UIViewController {

	/// Callback handler.
	NSObject *_target;

	/// Callback that will be called when the "Continue" button is pressed.
	SEL _continueCallBack;
}

/// Initializes a new instance of the IntroViewController class.
/// @param target - the continue callback handler.
/// @param callBack - the continue callback that will be called.
/// @returns IntroViewController instance.
- (id)initWithTarget: (NSObject *)target
 andContinueCallback:(SEL)callBack;

/// Performs continue action.
- (IBAction)continueAction;

@end
