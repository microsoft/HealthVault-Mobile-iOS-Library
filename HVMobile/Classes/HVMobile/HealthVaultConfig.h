//
//  HealthVaultConfig.h
//  HealthVault Mobile Library for iOS
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


#ifndef __OPTIMIZE__

	/// If TRUE then the library traces all requests, responses and other debug information to a console. 
	#define HEALTH_VAULT_TRACE_ENABLED 1

#else

	#define HEALTH_VAULT_TRACE_ENABLED 0

#endif

/// default HealthVault platform URL
#define HEALTH_VAULT_PLATFORM_URL @"https://platform.healthvault-ppe.com/platform/wildcat.ashx"

/// default HealthVault shell URL
#define HEALTH_VAULT_SHELL_URL @"https://account.healthvault-ppe.com" 

/// default language identifier
#define DEFAULT_LANGUAGE @"en"

/// default country code identifier
#define DEFAULT_COUNTRY @"US"