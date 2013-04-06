//
//  STSettingsTests.m
//  STSettingsTests
//
//  Created by Scott Talbot on 6/04/13.
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STSettingsTests.h"

#import "STSettings.h"


@implementation STSettingsTests

- (void)testLoad {
	NSBundle * const bundle = [NSBundle bundleForClass:[self class]];
	NSString * const settingsPath = [bundle pathForResource:@"Settings" ofType:@"bundle"];
	NSDictionary * const defaults = [STSettings defaultsFromSettingsBundleAtPath:settingsPath];
	STAssertNotNil(defaults, @"", nil);
}

@end
