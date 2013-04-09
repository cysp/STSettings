//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STSettingsLinter.h"
#import "STSettings+Internal.h"


@interface STSettingsLint ()
- (id)initWithSeverity:(STSettingsLintSeverity)severity string:(NSString *)string;
@end
@implementation STSettingsLint
- (id)init {
	return [self initWithSeverity:STSettingsLintSeverityNote string:nil];
}
- (id)initWithSeverity:(STSettingsLintSeverity)severity string:(NSString *)string {
	if ((self = [super init])) {
		_severity = severity;
		_string = [string copy];
	}
	return self;
}
@end


@interface STSettingsLinter ()
@property (nonatomic,copy,readonly) NSString *settingsBundlePath;
@end

@implementation STSettingsLinter

- (id)init {
	return [self initWithSettingsBundlePath:nil];
}
- (id)initWithSettingsBundlePath:(NSString *)path {
	NSParameterAssert([path length]);
	if ((self = [super init])) {
		_settingsBundlePath = [path copy];
	}
	return self;
}

- (NSArray *)lint {
	NSFileManager * const fileManager = [[NSFileManager alloc] init];

	NSString * const settingsBundlePath = self.settingsBundlePath;

	{
		BOOL isDirectory = NO;
		BOOL const exists = [fileManager fileExistsAtPath:settingsBundlePath isDirectory:&isDirectory];
		if (!exists || !isDirectory) {
			return @[ [[STSettingsLint alloc] initWithSeverity:STSettingsLintSeverityError string:@"bundle not found"] ];
		}
	}

	NSMutableOrderedSet * const plistNamesToRead = [[NSMutableOrderedSet alloc] initWithObject:@"Root"];
	NSMutableSet * const plistNamesRead = [[NSMutableSet alloc] init];
	NSCountedSet * const plistNamesSeen = [[NSCountedSet alloc] init];
	NSCountedSet * const preferenceKeysSeen = [[NSCountedSet alloc] init];

	NSMutableArray * const lint = [[NSMutableArray alloc] init];

	[plistNamesSeen addObjectsFromArray:[plistNamesToRead array]];

	while ([plistNamesToRead count]) {
		NSString * const plistName = [plistNamesToRead firstObject];
		[plistNamesRead addObject:plistName];
		[plistNamesToRead removeObject:plistName];

		NSString * const plistFilename = [plistName stringByAppendingPathExtension:@"plist"];
		NSString * const plistPath = [settingsBundlePath stringByAppendingPathComponent:plistFilename];

		if (![fileManager fileExistsAtPath:plistPath]) {
			[lint addObject:[[STSettingsLint alloc] initWithSeverity:STSettingsLintSeverityError string:[NSString stringWithFormat:@"plist missing: '%@'", plistFilename]]];
			continue;
		}
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
					if ([childPlistName length]) {
						[plistNamesSeen addObject:childPlistName];
						if (![plistNamesRead containsObject:childPlistName]) {
							[plistNamesToRead addObject:childPlistName];
						}
					}
				} break;
				case STSettingsPreferenceTypePreference: {
					NSString * const key = preferenceSpecifier[@"Key"];
					if ([key length]) {
						[preferenceKeysSeen addObject:key];
					}
				} break;
			}
		}
	}

	for (NSString *plistName in plistNamesSeen) {
		NSUInteger count = [plistNamesSeen countForObject:plistName];
		if (count > 1) {
			[lint addObject:[[STSettingsLint alloc] initWithSeverity:STSettingsLintSeverityError string:[NSString stringWithFormat:@"child pane seen multiple times: '%@'", plistName]]];
		}
	}

	for (NSString *key in preferenceKeysSeen) {
		NSUInteger count = [preferenceKeysSeen countForObject:key];
		if (count > 1) {
			[lint addObject:[[STSettingsLint alloc] initWithSeverity:STSettingsLintSeverityError string:[NSString stringWithFormat:@"preference key seen multiple times: '%@'", key]]];
		}
	}

	return lint;
}

@end
