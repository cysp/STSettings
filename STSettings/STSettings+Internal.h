//
//  STSettings_Internal.h
//  STSettings
//
//  Created by Scott Talbot on 9/04/13.
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STSettings.h"


typedef NS_ENUM(NSUInteger, STSettingsPreferenceType) {
	STSettingsPreferenceTypeUnknown = 0,
	STSettingsPreferenceTypeIgnorable,
	STSettingsPreferenceTypePreference,
	STSettingsPreferenceTypeLink,
};


extern STSettingsPreferenceType STSettingsPreferenceTypeFromTypeString(NSString *string);
