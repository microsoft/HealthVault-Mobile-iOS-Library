//
// MainViewController.h
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


@class WeightPickerView;

/// Represents app Main screen. Contains info about person record.
@interface MainViewController : UIViewController <UITextFieldDelegate> {

	/// Navigation bar buttons.
	IBOutlet UIBarButtonItem* _newAppItem;
	/// "New App" confirmation alert.
	UIAlertView *_newAppConfirmAlert;
	IBOutlet UIBarButtonItem* _recordsItem;
	
	/// Record info table.
	IBOutlet UITableView *_recordInfoTableView;

	/// "Record Info" section.
	IBOutlet UITableViewCell *_recordInfoCell;
	IBOutlet UILabel *_recordNameLabel;
	IBOutlet UIImageView *_recordImageView;

	/// "Save Weight" section.
	IBOutlet UITableViewCell *_saveWeightCell;
	IBOutlet UITableViewCell *_cancelWeightCell;
	IBOutlet UITextField *_newWeightTextField;
	IBOutlet UILabel *_newWeightDateLabel;
	WeightPickerView *_weightPickerView;
	NSString* _lastWeightValue;

	/// "Delete All" section.
	IBOutlet UITableViewCell *_deleteAllCell;
	/// "Delete All" confirmation alert.
	UIAlertView *_deleteAllConfirmAlert;
	
	/// Contains weights for current record.
	NSMutableArray *_weights;
	
	/// Shown if error occurred in authentication process.
	UIAlertView *_authAlert;
}

/// Performs addition of new weight for current record.
- (IBAction)addWeightAction;

/// Performs canceling of new weight addition.
- (IBAction)cancelAddingWeightAction;

/// Performs deleting all weights for current record. 
- (IBAction)deleteAllWeightsAction;

/// Performs application re-registration.
- (IBAction)newAppAction;

/// Shows screens with records for current authenticated user.
- (IBAction)recordsAction;

@end

