//
//  Base64.m
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

#import "Base64.h"

@implementation Base64

// Encoding charset
static const char _encodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSString *)encodeBase64WithData:(NSData *)dataToEncode {
	
	// args checking
	if (dataToEncode == nil || [dataToEncode length] == 0) {
		
		return nil;
	}
	
	int lenght = [dataToEncode length];
	
	// initializing output buffer
	const unsigned char * input = [dataToEncode bytes];
	
	char *output = (char *)calloc(((lenght + 2) / 3) * 4, sizeof(char));	
	char *outputPtr = output;
	
	// encoding
	int currChar, prevChar; // current and previous characters

	for (int idxInput = 0; idxInput < lenght; idxInput++) {
		
	    currChar = input[idxInput];		

	    switch (idxInput % 3) {
			
			case 0:
				*outputPtr++ = _encodingTable[(currChar >> 2) & 0x3F];
				break;
				
			case 1:
				*outputPtr++ = _encodingTable[((prevChar << 4) & 0x30) | ((currChar >> 4) & 0xF)];
				break;
				
			case 2:
				*outputPtr++ = _encodingTable[((prevChar << 2) & 0x3C) | ((currChar >> 6) & 0x3)];
				*outputPtr++ = _encodingTable[currChar & 0x3F];
				break;
	    }
		
	    prevChar = currChar;
	}
	
	
	// padding characters		
	switch (lenght % 3) {
			
		case 1: 
			*outputPtr++ = _encodingTable[(prevChar << 4) & 0x30];
			*outputPtr++ = '=';
			*outputPtr++ = '=';			
			break;
			
		case 2:			
			*outputPtr++ = _encodingTable[(prevChar << 2) & 0x3C];
			*outputPtr++ = '=';
			break;
	}
	
	*outputPtr = '\0';
	
	NSString *encodedInput = [NSString stringWithCString: output encoding: NSUTF8StringEncoding];
	
	free(output);
	
	return encodedInput;
}

+ (NSData *)decodeBase64WithString:(NSString *)stringToDecode {
	NSMutableData* data = [[[NSMutableData alloc] init] autorelease];
	data = [[[NSPropertyListSerialization dataFromPropertyList: data
														format: NSPropertyListXMLFormat_v1_0 errorDescription: nil] mutableCopy] autorelease];
	char endByte = 0;
	[data appendBytes: &endByte length: 1];
	NSMutableString* plist = [NSMutableString stringWithUTF8String: ([data bytes])];
	[plist replaceOccurrencesOfString: @"<data>"
						   withString: [@"<data>" stringByAppendingString: stringToDecode]
							  options: 0
								range: NSMakeRange(0, [plist length])];
	
	data = [[[NSPropertyListSerialization propertyListFromData: [NSData dataWithBytes: [plist UTF8String]
																			   length: [plist length]]
											  mutabilityOption: NSPropertyListImmutable
														format: nil
											  errorDescription: nil] mutableCopy] autorelease];
	return data;
}

@end
