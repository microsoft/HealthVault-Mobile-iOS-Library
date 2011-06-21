//
// RecordsViewController.m
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


#import "RecordsViewController.h"

#import "WebViewController.h"
#import "WeightTrackerAppDelegate.h"


@implementation RecordsViewController

- (id)init {

	if (self = [super init]) {

		self.title = @"Records";
		_records = [[WeightTrackerAppDelegate healthVaultService].records retain];
	}

	return self;
}

- (void)dealloc {

	[_records release];

	[super dealloc];
}

- (void)viewWillAppear: (BOOL)animated {

	_recordsTableView.backgroundColor = [UIColor clearColor];

	if (_mustUpdateRecordsList) {

		_mustUpdateRecordsList = NO;
		[[WeightTrackerAppDelegate healthVaultService] performAuthenticationCheck: self
														  authenticationCompleted: @selector(authenticationCompleted:)
																shellAuthRequired: @selector(shellAuthRequired:)];
		[WeightTrackerAppDelegate showProgressView];
	}
}

/// Performs adding new record.
- (IBAction)addRecordAction {

	[WeightTrackerAppDelegate showIntroScreenWithTarget: self
									andContinueCallback: @selector(continueButtonPressed)];
}

#pragma mark Authentication Logic

/// Callback, invoked when user was successfully identified by HealtVault.
/// @param response - HealthVaultResponse object.
- (void)authenticationCompleted: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];

	if (response.hasError) {

		[WeightTrackerAppDelegate showAlertWithError: response.errorText
											  target: nil];
		return;
	}

	if (_records) {
		[_records release];
	}
	_records = [[WeightTrackerAppDelegate healthVaultService].records retain];

	[_recordsTableView reloadData];
}

/// Callback, invoked when user was not identified by HealtVault.
/// And user should authenticate via web (embedded web-component).
/// @param response - HealthVaultResponse object.
- (void)shellAuthRequired: (HealthVaultResponse *)response {

	[WeightTrackerAppDelegate hideProgressView];

	if (response.hasError) {
		
		[WeightTrackerAppDelegate showAlertWithError: response.errorText
											  target: nil];
		return;
	}
	
	[WeightTrackerAppDelegate showIntroScreenWithTarget: self
									andContinueCallback: @selector(continueButtonPressed)];
}

- (void)continueButtonPressed {
	
		_mustUpdateRecordsList = YES;
		
		// URL for authentication user records for app.
		NSString *authorizationUrl = [[WeightTrackerAppDelegate healthVaultService] getUserAuthorizationUrl];
		WebViewController *webController = [[WebViewController alloc] initWithUrl: authorizationUrl];
		[self.navigationController pushViewController: webController
											 animated: NO];
		[webController release];
}

#pragma mark Authentication Logic End


#pragma mark Records Table View Logic

- (NSString *)tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section {

	if(_records.count == 0)
		return @"There are no connected persons";
	
	return @"Please select a record";
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {

	return _records.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {

	static NSString *RecordCellId = @"RecordCellId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: RecordCellId];

	if (!cell) {

		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
									   reuseIdentifier: RecordCellId] autorelease];
	}

	HealthVaultRecord *record = [_records objectAtIndex: indexPath.row];
	cell.textLabel.text = record.recordName;

	// Shows "current" flag on row if row is current record.
	HealthVaultRecord *currentRecord = [WeightTrackerAppDelegate healthVaultService].currentRecord;
	if ([record.recordName isEqualToString: currentRecord.recordName]) {
		cell.detailTextLabel.text = @"Current";
	} else {
		cell.detailTextLabel.text = @"";
	}

	return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {

	// Updates service setting according to selected record.
	HealthVaultService *service = [WeightTrackerAppDelegate healthVaultService];
	service.currentRecord = [_records objectAtIndex: indexPath.row];
	[service saveSettings: @"Default"];

	[self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Records Table View Logic End

@end
