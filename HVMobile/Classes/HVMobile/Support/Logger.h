//
//  Logger.h
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

#import <Foundation/Foundation.h>
#import "HealthVaultConfig.h"

#if HEALTH_VAULT_TRACE_ENABLED
#	define TraceMessage(s, ... ) [Logger write: [NSString stringWithFormat: @"[%s, line = %d] %@", __func__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__]]]
#	define TraceComponentEvent(component, code, s, ... ) [Logger write: [NSString stringWithFormat: @"[%@, code = %d]: %@", component, code, [NSString stringWithFormat:(s), ##__VA_ARGS__]]]
#	define TraceComponentMessage(component, s, ... ) TraceComponentEvent(component, 0, s, ##__VA_ARGS__)
#	define TraceComponentError(component, s, ... ) TraceComponentEvent(component, -1, s, ##__VA_ARGS__)
#else
#	define TraceMessage(s, ... ) {}
#	define TraceComponentEvent(component, code, s, ... ) {}
#	define TraceComponentMessage(component, s, ... ) {}
#	define TraceComponentError(component, s, ... ) {}
#endif

/// Implements logging related functionality.
@interface Logger: NSObject

/// Writes the message to a log.
/// @param text - text to write.
+ (void)write: (NSString *)text;

@end 