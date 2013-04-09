//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STSettings.h"
#import "STSettings+Internal.h"


STSettingsPreferenceType STSettingsPreferenceTypeFromTypeString(NSString *string) {
	if ([@"PSGroupSpecifier" isEqualToString:string]) {
		return STSettingsPreferenceTypeIgnorable;
	}

	if ([@"PSChildPaneSpecifier" isEqualToString:string]) {
		return STSettingsPreferenceTypeLink;
	}

	NSSet *settingTypeStrings = [NSSet setWithObjects:
		@"PSTextFieldSpecifier",
		@"PSTitleValueSpecifier",
		@"PSToggleSwitchSpecifier",
		@"PSSliderSpecifier",
		@"PSMultiValueSpecifier",
		@"PSRadioGroupSpecifier",
	nil];
	if ([settingTypeStrings containsObject:string]) {
		return STSettingsPreferenceTypePreference;
	}

	return STSettingsPreferenceTypeUnknown;
}


@implementation STSettings

+ (BOOL)registerDefaultsFromMainBundle {
	NSDictionary * const defaults = [self defaultsFromMainBundle];
	if (!defaults) {
		return NO;
	}

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

	return YES;
}

+ (BOOL)registerDefaultsFromSettingsBundleAtPath:(NSString *)settingsBundlePath {
	NSDictionary * const defaults = [self defaultsFromSettingsBundleAtPath:settingsBundlePath];
	if (!defaults) {
		return NO;
	}

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

	return YES;
}


+ (NSDictionary *)defaultsFromMainBundle {
	NSBundle * const bundle = [NSBundle mainBundle];

	NSString * const pathForSettingsBundle = [bundle pathForResource:@"Settings" ofType:@"bundle"];
	if (![pathForSettingsBundle length]) {
		return nil;
	}

	return [self defaultsFromSettingsBundleAtPath:pathForSettingsBundle];
}

+ (NSDictionary *)defaultsFromSettingsBundleAtPath:(NSString *)settingsBundlePath {
	NSFileManager * const fileManager = [[NSFileManager alloc] init];

	NSMutableDictionary * const defaults = [[NSMutableDictionary alloc] init];

	{
		BOOL isDirectory = NO;
		BOOL const exists = [fileManager fileExistsAtPath:settingsBundlePath isDirectory:&isDirectory];
		if (!exists || !isDirectory) {
			return nil;
		}
	}

	NSMutableOrderedSet * const plistNamesToRead = [[NSMutableOrderedSet alloc] initWithObject:@"Root"];
	NSMutableSet * const plistNamesSeen = [[NSMutableSet alloc] init];

	while ([plistNamesToRead count]) {
		NSString * const plistName = [plistNamesToRead firstObject];
		[plistNamesSeen addObject:plistName];
		[plistNamesToRead removeObject:plistName];

		NSString * const plistFilename = [plistName stringByAppendingPathExtension:@"plist"];
		NSString * const plistPath = [settingsBundlePath stringByAppendingPathComponent:plistFilename];
		NSDictionary * const plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];

		NSArray * const preferenceSpecifiers = plistDict[@"PreferenceSpecifiers"];
		for (NSDictionary *preferenceSpecifier in preferenceSpecifiers) {
			NSString * const preferenceSpecifierTypeString = preferenceSpecifier[@"Type"];
			STSettingsPreferenceType const preferenceSpecifierType = STSettingsPreferenceTypeFromTypeString(preferenceSpecifierTypeString);
			switch (preferenceSpecifierType) {
				case STSettingsPreferenceTypeUnknown:
				case STSettingsPreferenceTypeIgnorable:
					break;
				case STSettingsPreferenceTypeLink: {
					NSString * const childPlistName = preferenceSpecifier[@"File"];
					if ([childPlistName length] && ![plistNamesSeen containsObject:childPlistName]) {
						[plistNamesToRead addObject:childPlistName];
					}
				} break;
				case STSettingsPreferenceTypePreference: {
					NSString * const key = preferenceSpecifier[@"Key"];
					id const defaultValue = preferenceSpecifier[@"DefaultValue"];
					if ([key length] && defaultValue) {
						defaults[key] = defaultValue;
					}
				} break;
			}
		}
	}

	return defaults;
}

@end
