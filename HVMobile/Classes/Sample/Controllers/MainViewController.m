//
// MainViewController.m
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


#import "MainViewController.h"

#import "WeightTrackerAppDelegate.h"
#import "WebViewController.h"
#import "RecordsViewController.h"
#import "WeightPickerView.h"

#import "Weight.h"
#import "RecordImage.h"


/// Weight default value.
#define WEIGHT_DEFAULT_VALUE @"160.0"

/// Offset for record info table, when weight picker
/// is shown.
#define ADDING_NEW_WEIGHT_TABLE_TOP_OFFSET 130


/// Sections for record info table.
enum {

	/// "Record Info" section.
	RecordInfoSection,
	
	/// "Save Weight" section.
	SaveWeightSection,
	
	/// "Weights" section.
	WeightsSection,
	
	/// "Delete All" section.
	DeleteAllSection,
	
	/// Count of section in table.
	SectionsCount
};

/// Rows index of "Save Weight" section.
enum {

	CancelButtonRow = 1
};

@interface MainViewController (Private)

/// Updates label text according to current time.
- (void)updateNewWeightDateLabel;

/// Performs HealthVault service authentication.
- (void)authenticate;

/// Performs app re-connection.
- (void)reConnectApp;

/// Shows standard alert with specified message.
/// @param message - alert message.
- (void)showAlertWithMessage: (NSString *)message;

/// Shows "New App" confimation alert.
- (void)showNewAppConfirmationAlert;

/// Shows "Delete All" alert which prompts user to confirm his or her choice.
- (void)showDeleteAllConfirmationAlert;

/// Shows alert with "Try Again" button.
/// @param messsage - alert message.
/// @param target - callback methods owner.
- (void)showTryAgainAlert: (NSString *)message;

/// Shows Weight picker view.
- (void)showWeightPickerView;

/// Hides Weight picker view.
- (void)hideWeightPickerView;

@end

@implementation MainViewController


- (void)dealloc {

	[_weights release];
	[_weightPickerView release];
	[_lastWeightValue release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	
	self.navigationItem.leftBarButtonItem = _newAppItem;
	self.navigationItem.rightBarButtonItem = _recordsItem;
	_recordInfoTableView.backgroundColor = [UIColor clearColor];
	
	[self updateNewWeightDateLabel];
	
	/// Updates newWeightDateLabel each 10 seconds.
	const int UpdateNewWeightLabelTimerInterval = 10;
	[NSTimer scheduledTimerWithTimeInterval: UpdateNewWeightLabelTimerInterval
									 target: self 
								   selector: @selector(updateNewWeightDateLabel) 
								   userInfo: nil 
									repeats: YES];
}

- (void)viewWillAppear: (BOOL)animated {

	/// Hides record info table.
	_recordInfoTableView.hidden = YES;
	
	/// Removes old record image.
	_recordImageView.image = nil;
	
	[self authenticate];
}

- (void)viewWillDisappear: (BOOL)animated {
	
	[self hideWeightPickerView];
}

/// Updates label text according to current time.
- (void)updateNewWeightDateLabel {
	
	/// Updates label with new date / time.
	_newWeightDateLabel.text = [NSDateFormatter localizedStringFromDate: [NSDate date]
															  dateStyle: kCFDateFormatterMediumStyle
															  timeStyle: kCFDateFormatterShortStyle];
}

#pragma mark Buttons Actions

/// Shows screens with records for current authenticated user.
- (IBAction)recordsAction {

	RecordsViewController *recordsController = [RecordsViewController new];
	[self.navigationController pushViewController: recordsController animated: YES];
	[recordsController release];
}

/// Performs application re-registration.
- (IBAction)newAppAction {

	// Shows "New App" confimation alert.
	[self showNewAppConfirmationAlert];
}

/// Performs adding new weight for current record.
- (IBAction)addWeightAction {

	// Validates text field, it should not be empty.
	if(_newWeightTextField.text.length == 0) {
		
		[self showAlertWithMessage: @"Please input weight."];
		return;
	}
	
	NSString *poundsString = _newWeightTextField.text;
	double pounds = [poundsString doubleValue];
	
	// Validate weight, it should be greater than zero.
	if(pounds == 0) {
		
		[self showAlertWithMessage: @"Weight cannot be zero."];
		return;
	}
	
	// Hides "Weight picker" view.
	[self hideWeightPickerView];
	
	// Sends new weight to HealthVault server.
	[Weight putWeight: pounds target: self callBack: @selector(putWeightCompleted:)];

	[WeightTrackerAppDelegate showProgressView];
}

/// Performs deleting all weights for current record.
- (IBAction)deleteAllWeightsAction {

	// Shows confirmation alert for user.
	[self showDeleteAllConfirmationAlert];
}

/// Performs canceling of new weight adding.
- (IBAction)cancelAddingWeightAction {
	
	_newWeightTextField.text = _lastWeightValue;
	
	[self hideWeightPickerView];
}

#pragma mark Buttons Actions End


#pragma mark Authentication Logic

/// Performs app re-conection.
- (void)reConnectApp {
	
	HealthVaultService *service = [WeightTrackerAppDelegate healthVaultService];
	
	// Resets HealthVault service settings.
	service.sessionSharedSecret = nil;
	service.authorizationSessionToken = nil;
	service.sharedSecret = nil;
	service.appIdInstance = nil;
	service.currentRecord = nil;
	
	[service saveSettings: @"Default"];
	
	[self authenticate];
}

// Performs HealthVault service authentication.
- (void)authenticate {

	[WeightTrackerAppDelegate showProgressView];

	[[WeightTrackerAppDelegate healthVaultService] performAuthenticationCheck: self
													  authenticationCompleted: @selector(authenticationCompleted:)
															shellAuthRequired: @selector(shellAuthRequired:)];
}

/// Callback, invoked when user was successfully identified by HealtVault.
/// @param response - HealthVaultResponse object.
- (void)authenticationCompleted: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];

	HealthVaultService *service = [WeightTrackerAppDelegate healthVaultService];
	
	if (response.hasError) {
		
		[self showTryAgainAlert: response.errorText];
	}
	else {
		
		// By default gets first record in person record set.
		if (service.currentRecord == nil && service.records != nil && service.records.count > 0) {

			service.currentRecord = [service.records objectAtIndex: 0];
		}
		else if (!service.currentRecord) {

			/// If current person does not have records, notify user about it.
			[self showAlertWithMessage: @"Unfortunately, your person doest have any records."];
		}
		
		if(service.currentRecord) {
			
			_recordNameLabel.text = service.currentRecord.recordName;
		
			// Loads weights data and image for current record.
			[Weight loadWeights: self callBack: @selector(loadWeightsCompleted:)];
			[RecordImage loadRecordImage: self callBack: @selector(loadRecordImageCompleted:)];
		
			[WeightTrackerAppDelegate showProgressView];
		}
	}
	
	// Save current state of HealthVault service
	[service saveSettings: @"Default"];
}

/// Callback, invoked when user was not identified by HealtVault.
/// And user should authenticate via web (embedded web-component).
/// @param response - HealthVaultResponse object.
- (void)shellAuthRequired: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];
	
	// Save current state of HealthVault service
	HealthVaultService *service = [WeightTrackerAppDelegate healthVaultService];
	[service saveSettings: @"Default"];

	if (response.hasError) {
		
		[self showTryAgainAlert: response.errorText];
		return;
	}

	[WeightTrackerAppDelegate showIntroScreenWithTarget: self
									andContinueCallback: @selector(introScreenContinueButtonPressed)];
}

/// Calback for "Continue" button on Intro screen.
/// Redirects user to view where he can be authenticated.
- (void)introScreenContinueButtonPressed {
	
	// URL for authentication user records for app.
	NSString *url = [[WeightTrackerAppDelegate healthVaultService] getApplicationCreationUrl];
	
	WebViewController *webController = [[WebViewController alloc] initWithUrl: url];
	[self.navigationController pushViewController: webController animated: YES];
	[webController release];
}

#pragma mark Authentication Logic End


#pragma mark Server CallBacks

/// Callback for adding new weight server request.
/// @param response - HealthVaultResponse object.
- (void)putWeightCompleted: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];

	if (response.hasError) {
		[WeightTrackerAppDelegate showAlertWithError: response.errorText target: self];
		return;
	}

	// Reloads weights list.
	[Weight loadWeights: self callBack: @selector(loadWeightsCompleted:)];
}

/// Callback for deleting all weight server request.
/// @param response - HealthVaultResponse object.
- (void)deleteAllWeightsCompleted: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];

	if (response.hasError) {
		[WeightTrackerAppDelegate showAlertWithError: response.errorText target: self];
		return;
	}

	// After deleting clear weights list and reload table.
	[_weights removeAllObjects];
	[_recordInfoTableView reloadData];
	// Clears new weight text field.
	_newWeightTextField.text = @"";

	[self showAlertWithMessage: @"Your saved weights have been successfully deleted."];
}

/// Callback for loading weight server request.
/// @param response - HealthVaultResponse object.
- (void)loadWeightsCompleted: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];

	if (response.hasError) {
		[WeightTrackerAppDelegate showAlertWithError: response.errorText target: self];
		return;
	}

	// Parses received xml with weights.
	if (_weights) {
		[_weights release];
	}
	_weights = [[Weight parseWeightsFromXml: response.infoXml] retain];

	// Shows hidden table and reload it.
	_recordInfoTableView.hidden = NO;
	[_recordInfoTableView reloadData];

	if (_weights.count > 0) {

		Weight *lastWeight = [_weights objectAtIndex: 0];
		_newWeightTextField.text = [NSString stringWithFormat: @"%.1f", [lastWeight.display doubleValue]];
	}
	else {
		
		_newWeightTextField.text = @"";
	}
}

/// Callback for loading image for current record.
/// @param response - HealthVaultResponse object.
- (void)loadRecordImageCompleted: (HealthVaultResponse *)response {

	if (response.hasError) {
		return;
	}

	RecordImage *recordImage = [RecordImage parseImageFromXml: response.infoXml];

	if (recordImage) {
		_recordImageView.image = recordImage.image;
	}
}

#pragma mark Server CallBacks End


#pragma mark Weights Table View Events

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {

	// If record doest not have tracked weights then
	// hide "Weights" and "Delete All" sections.
	if (_weights.count == 0) {

		return SaveWeightSection + 1;
	}

	return SectionsCount;
}

- (NSString *)tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section {

	// Custom header for "Save Weight" and "Weights" sections.
	switch (section) {

		case SaveWeightSection:
			return @"Track your weight";

		case WeightsSection:
			return @"Weights";
	}

	// Returns empty header for other sections.
	return @"";
}

- (CGFloat)tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
	
	// Height for double cell ("Record Info" and "Save Weight");
	const int DoubleCellHeight = 100;
	
	// Height for cell from weights list.
	const int WeightsCellHeight = 44;
	
	// Height for cell from "Delete All" section.
	const int DeleteAllCellHeight = 65;
	
	// Custom row height for "Record Info", "Save Weight", "Delete All" sections.
	switch (indexPath.section) {

		case RecordInfoSection:
			return DoubleCellHeight;

		case SaveWeightSection:
			if (indexPath.row == 0) {
				return DoubleCellHeight;
			}
			break;
		
		case WeightsSection:
			return WeightsCellHeight;

		case DeleteAllSection:
			return DeleteAllCellHeight;
	}

	// Returns default cell height.
	return tableView.rowHeight;
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {

	// "Record Info", "Save Weight", "Delete All" sections contains one row.
	if (section == RecordInfoSection || section == SaveWeightSection || section == DeleteAllSection) {

		// If weight picker is shown then "Save Weight" section contains 2 rows ("Save" and "Cancel"),
		// otherwise one row.
		if (section == SaveWeightSection && _weightPickerView.isShown) {
			return 2;
		}

		return 1;
	}

	// Returns rows count for "Weights" section.
	return _weights.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {

	UITableViewCell *cell = nil;

	switch (indexPath.section) {

		case RecordInfoSection: {
			
			cell = _recordInfoCell;
			break;
		}

		// "Save Weight" section, may contain one or two rows.
		// Second row contains "Cancel" button and is shown 
		// when weight picker is active.
		case SaveWeightSection: {

			if (indexPath.row == 1) {

				cell = _cancelWeightCell;
			}
			else {
				cell = _saveWeightCell;
			}
			break;
		}

		// Prepare cell for "Weights" section.
		case WeightsSection: {

			static NSString *WeightCellId = @"WeightCellId";
			cell = [tableView dequeueReusableCellWithIdentifier: WeightCellId];

			if (!cell) {

				cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
											   reuseIdentifier: WeightCellId] autorelease];
			}

			Weight *weight = (Weight *)[_weights objectAtIndex: indexPath.row];

			NSString *value = [NSString stringWithFormat: @"%.1f %@", [weight.display doubleValue], weight.units];
			cell.textLabel.text = value;
			cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate: weight.effDate
																	   dateStyle: kCFDateFormatterShortStyle
																	   timeStyle: kCFDateFormatterShortStyle];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			break;
		}

		case DeleteAllSection: {

			cell = _deleteAllCell;
			break;
		}
	}

	return cell;
}

#pragma mark Weights Table View Events End


#pragma mark Weight PickerView Logic

/// Shows Weight picker view.
- (void)showWeightPickerView {

	if (!_weightPickerView) {
		_weightPickerView = [WeightPickerView new];
		_weightPickerView.textField = _newWeightTextField;
		[self.view addSubview: _weightPickerView];
	}
	else if (_weightPickerView.isShown) {

		return;
	}

	if(_lastWeightValue) {
		[_lastWeightValue release];
		_lastWeightValue = nil;
	}
	_lastWeightValue = [_newWeightTextField.text retain];
	
	// Sets weight default value for text field.
	if(_newWeightTextField.text.length == 0)
		_newWeightTextField.text = WEIGHT_DEFAULT_VALUE;
	
	// Sets weight default value for weight picker.
	double pounds = [_newWeightTextField.text doubleValue];
	[_weightPickerView setValue: pounds];
	
	// Shows picker with animation.
	[_weightPickerView show];

	// Moves table view to top of screen.
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 1];
	CGRect frame = _recordInfoTableView.frame;
	frame.origin.y -= ADDING_NEW_WEIGHT_TABLE_TOP_OFFSET;
	_recordInfoTableView.frame = frame;
	[UIView commitAnimations];

	// Inserts "Cancel" button row after "Save Weight" button row.
	NSArray *insertPaths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow: CancelButtonRow
																		inSection: SaveWeightSection]];
	[_recordInfoTableView insertRowsAtIndexPaths: insertPaths
								withRowAnimation: UITableViewRowAnimationFade];

	// Scrolls table view to top.
	NSIndexPath *scrollPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
	[_recordInfoTableView scrollToRowAtIndexPath: scrollPath
								atScrollPosition: UITableViewScrollPositionTop
										animated: YES];
}

/// Hides Weight picker view.
- (void)hideWeightPickerView {

	if (!_weightPickerView.isShown) {
		return;
	}

	// Hides picker with animation.
	[_weightPickerView hide];
		
	// Moves table view to normal layout.
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 1];
	CGRect frame = _recordInfoTableView.frame;
	frame.origin.y += ADDING_NEW_WEIGHT_TABLE_TOP_OFFSET;
	_recordInfoTableView.frame = frame;
	[UIView commitAnimations];

	NSArray *deletePaths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow: CancelButtonRow
																		inSection: SaveWeightSection]];
	[_recordInfoTableView deleteRowsAtIndexPaths: deletePaths
								withRowAnimation: UITableViewRowAnimationFade];
}

/// Shows standard alert with specified message.
- (void)showAlertWithMessage: (NSString *)message {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Weight Tracker"
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert autorelease];
}

/// Shows "New App" confimation alert.
- (void)showNewAppConfirmationAlert {
	
	_newAppConfirmAlert = [[UIAlertView alloc] initWithTitle: @"Weight Tracker"
													 message: @"Are you really want to re-connect app?"
													delegate: self
										   cancelButtonTitle: @"Cancel"
										   otherButtonTitles: @"Yes", nil];
	[_newAppConfirmAlert show];
	[_newAppConfirmAlert autorelease];
}


/// Shows "Delete All" alert which suggest user to confirm his choise.
- (void)showDeleteAllConfirmationAlert {

	_deleteAllConfirmAlert = [[UIAlertView alloc] initWithTitle: @"Weight Tracker"
														message: @"Are you really want to delete all your saved weights?"
													   delegate: self
											  cancelButtonTitle: @"Cancel"
											  otherButtonTitles: @"Yes", nil];
	[_deleteAllConfirmAlert show];
	[_deleteAllConfirmAlert autorelease];
}

/// Shows alert with "Try Again" button.
/// @param messsage - alert message.
/// @param target - callback methods owner.
- (void)showTryAgainAlert: (NSString *)message {
	
	_authAlert = [[UIAlertView alloc] initWithTitle: @"Error"
											message: message
										   delegate: self
								  cancelButtonTitle: nil
								  otherButtonTitles: @"Try again", nil];
	[_authAlert show];
	[_authAlert autorelease];
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {

	// 'Yes' button index in "Delete All" and "New App" confirmation alerts.
	const int YesButtonIndex = 1;

	if(alertView == _authAlert) {
		
		[self authenticate];
	}
	// If user pressed "Yes" button.
	else if(buttonIndex == YesButtonIndex) {
		
		if(alertView == _newAppConfirmAlert) {
		
			[self reConnectApp];
			_newAppConfirmAlert = nil;
		}	
		// Checks that current alert is "Delete All".
		else if (alertView == _deleteAllConfirmAlert) {

			[WeightTrackerAppDelegate showProgressView];
		
			// Performs deleting.
			[Weight deleteAllWeights: _weights target: self callBack: @selector(deleteAllWeightsCompleted:)];
			_deleteAllConfirmAlert = nil;
		}
	}
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField {

	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing: (UITextField *)textField {

	// Shows weight picker instead of keyboard.
	[textField resignFirstResponder];
	[self showWeightPickerView];

	return NO;
}

@end
