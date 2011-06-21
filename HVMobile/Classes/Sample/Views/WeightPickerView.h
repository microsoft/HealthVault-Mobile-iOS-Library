//
// WeightPickerView.h
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


/// Picker for selecting weight.
@interface WeightPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate> {

	/// Displays current weight value.
	UITextField *_textField;

	/// Pоunds value.
	int _valueInPounds;
	
	/// Fractional part of pound.
	int _fractionalPartOfValue;

	/// Indicates that picker is shown.
	BOOL _isShown;
}

/// Gets or sets textfield which accepts selected value from picker view.
@property(retain) UITextField *textField;

/// Indicates that picker view is shown.
@property(assign, readonly) BOOL isShown;

/// Shows picker with animation.
- (void)show;

/// Hides picker with animation.
- (void)hide;

/// Sets picker's value.
/// @param value - value of weight in pounds.
- (void)setValue: (double)value;

@end
