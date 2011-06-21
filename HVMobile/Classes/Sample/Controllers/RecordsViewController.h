//
// RecordsViewController.h
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


/// Represents list of person records authorized for current application instance.
@interface RecordsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	/// Table view to display records.
	IBOutlet UITableView *_recordsTableView;

	/// Records array.
	NSMutableArray *_records;
	
	/// Specifies whether we must update records list via request to the HealthVault platform.
	BOOL _mustUpdateRecordsList;
}

/// Performs adding new record.
- (IBAction)addRecordAction;

@end
