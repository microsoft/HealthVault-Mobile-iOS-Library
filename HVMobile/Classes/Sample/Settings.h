//
// Settings.h
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


#define HEALTH_VAULT_PLATFORM_URL @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"
#define HEALTH_VAULT_SHELL_URL @"https://account.healthvault-ppe.com" 

#define HEALTH_VAULT_MASTER_APPLICATION_ID @"cf36aef7-5d87-4688-88b2-f9b57c086d7d"

/// Enables/Disables debug logic in app.
/// #define DEBUG_MODE 1

#ifdef DEBUG_MODE

	/// Enables/Disables logging for server response.
	#define LOG_SERVER_REQUEST_AND_RESPONSE YES

	/// Enables memory tracker.
	#define ENABLE_MEMORY_TRACKER 1

#endif

/// Interval between tracking memory by tracker.
#define MEMORY_TRACKER_TIME_INTERVAL 1