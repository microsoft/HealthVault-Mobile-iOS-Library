//
// WeightPickerView.m
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

#import "WeightPickerView.h"


/// Maximum value for picker view.
#define WEIGHT_PICKER_MAX_VALUE 600

/// Count of fraction for value.
#define WEIGHT_PICKER_FRACTION_VALUES_COUNT 10

/// Width for "Value" component.
#define VALUE_COMPONENT_WIDTH 120

/// Width for "Value Fractional" component.
#define VALUE_FRACTIONAL_COMPONENT_WIDTH 70

/// Width for "Title" component.
#define TITLE_COMPONENT_WIDTH 100

/// Caption for "Title" component.
#define TITLE_COMPONENT_CAPTION @"pounds"

/// Picker components.
enum {
	
	/// Shows value in pounds.
	ValueComponent,
	
	/// Shows fractional part of pound.
	ValueFractionalComponent,
	
	/// Contains title.
	TitleComponent,
	
	/// Components count in picker.
	ComponentsCount
};

@implementation WeightPickerView

@synthesize textField = _textField;
@synthesize isShown = _isShown;

- (id)init {

	if (self = [super init]) {

		self.dataSource = self;
		self.delegate = self;
		self.showsSelectionIndicator = YES;
		_isShown = NO;
		
		[self reloadAllComponents];
	}

	return self;
}

- (void)dealloc {

	self.textField = nil;

	[super dealloc];
}

/// Shows picker with animation.
- (void)show {
	
	_isShown = YES;
	
	// Moves picker to bottom of superview.
	int startY = self.superview.frame.size.height;
	CGRect frame = self.frame;
	frame.origin.y = startY;
	self.frame = frame;
	
	// Shows with animation picker.
	[UIView beginAnimations: nil
					context: nil];
	[UIView setAnimationDuration: 1];
	frame.origin.y = startY - self.frame.size.height;
	self.frame = frame;
	[UIView commitAnimations];
}

/// Hides picker with animation.
- (void)hide {
	
	_isShown = NO;
	
	// Moves picker to bottom of superview with animation.
	[UIView beginAnimations: nil
					context: nil];
	[UIView setAnimationDuration: 1];
	CGRect frame = self.frame;
	frame.origin.y = self.superview.frame.size.height;
	self.frame = frame;
	[UIView commitAnimations];
}

/// Sets picker's value.
/// @param value - value of weight in pounds.
- (void)setValue: (double)value {
	
	_valueInPounds = (int) value;
	_fractionalPartOfValue = round((value - _valueInPounds) * 10); 
	
	[self selectRow: _valueInPounds inComponent: ValueComponent animated: YES];
	[self selectRow: _fractionalPartOfValue inComponent: ValueFractionalComponent animated: YES];
}

#pragma mark Picker Events

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)thePickerView {

	return ComponentsCount;
}

- (CGFloat)pickerView: (UIPickerView *)pickerView widthForComponent: (NSInteger)component {

	switch (component) {

		case ValueComponent:
	        return VALUE_COMPONENT_WIDTH;

		case ValueFractionalComponent:
	        return VALUE_FRACTIONAL_COMPONENT_WIDTH;
	}

	return TITLE_COMPONENT_WIDTH;
}

- (NSInteger)pickerView: (UIPickerView *)thePickerView numberOfRowsInComponent: (NSInteger)component {

	switch (component) {

		case ValueComponent:
	        return WEIGHT_PICKER_MAX_VALUE;

		case ValueFractionalComponent:
	        return WEIGHT_PICKER_FRACTION_VALUES_COUNT;
	}

	// Returns default value. Title section contains one row.
	return 1;
}

- (UIView *)pickerView: (UIPickerView *)pickerView 
			viewForRow: (NSInteger)row
		  forComponent: (NSInteger)component
		   reusingView: (UIView *)view {

	// Makes custom label.
	UILabel *captionLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 145, 45)];
	captionLabel.textAlignment = UITextAlignmentCenter;
	captionLabel.opaque = NO;
	captionLabel.backgroundColor = [UIColor clearColor];
	captionLabel.textColor = [UIColor blackColor];
	captionLabel.font = [UIFont boldSystemFontOfSize: 20];

	switch (component) {

		case ValueComponent:
	        captionLabel.text = [NSString stringWithFormat: @"%d", row];
	        break;

		case ValueFractionalComponent:
	        captionLabel.text = [NSString stringWithFormat: @".%d", row];
	        break;

		case TitleComponent:
	        captionLabel.text = TITLE_COMPONENT_CAPTION;
	        break;
	}

	return [captionLabel autorelease];
}

- (void)pickerView: (UIPickerView *)thePickerView
	  didSelectRow: (NSInteger)row
	   inComponent: (NSInteger)component {

	switch (component) {

		case ValueComponent:
	        _valueInPounds = row;
	        break;

		case ValueFractionalComponent:
	        _fractionalPartOfValue = row;
	        break;
	}

	// Sets value for related text field.
	self.textField.text = [NSString stringWithFormat: @"%d.%d", _valueInPounds, _fractionalPartOfValue];
}

#pragma mark Picker Events End

@end
