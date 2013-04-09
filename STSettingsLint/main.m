//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>

#import "STSettingsLinter.h"


static void __attribute__((noreturn))usage(char const *);

int main(int argc, char const * argv[]) {
	BOOL clean = YES;
	@autoreleasepool {
		if (argc < 2) {
			usage(argv[0]);
		}

		char const * const settingsBundlePathCString = argv[1];
		NSString * const settingsBundlePath = [[NSString alloc] initWithBytes:settingsBundlePathCString length:strlen(settingsBundlePathCString) encoding:NSUTF8StringEncoding];

		STSettingsLinter * const linter = [[STSettingsLinter alloc] initWithSettingsBundlePath:settingsBundlePath];

		NSArray * const lints = [linter lint];

		NSFileHandle * const stderrFileHandle = [NSFileHandle fileHandleWithStandardError];

		for (STSettingsLint *lint in lints) {
			STSettingsLintSeverity const severity = lint.severity;
			NSString * const lintDescription = lint.string;
			switch (severity) {
				case STSettingsLintSeverityNote:
					[stderrFileHandle writeData:[@"info: " dataUsingEncoding:NSUTF8StringEncoding]];
					break;
				case STSettingsLintSeverityWarning:
					clean = NO;
					[stderrFileHandle writeData:[@"warning: " dataUsingEncoding:NSUTF8StringEncoding]];
					break;
				case STSettingsLintSeverityError:
					clean = NO;
					[stderrFileHandle writeData:[@"error: " dataUsingEncoding:NSUTF8StringEncoding]];
					break;
			}

			[stderrFileHandle writeData:[lintDescription dataUsingEncoding:NSUTF8StringEncoding]]; 
			[stderrFileHandle writeData:[NSData dataWithBytesNoCopy:"\n" length:1 freeWhenDone:NO]];
		}
	}
    return !clean;
}

static void __attribute__((noreturn)) usage(char const *progname) {
	fprintf(stderr, "Usage: %s <Settings.bundle>\n", progname);
	exit(1);
}
