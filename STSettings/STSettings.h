//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@interface STSettings : NSObject

+ (BOOL)registerDefaultsFromMainBundle;
+ (BOOL)registerDefaultsFromSettingsBundleAtPath:(NSString *)settingsBundlePath;

+ (NSDictionary *)defaultsFromMainBundle;
+ (NSDictionary *)defaultsFromSettingsBundleAtPath:(NSString *)settingsBundlePath;

@end
