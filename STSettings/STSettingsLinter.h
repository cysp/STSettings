//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, STSettingsLintSeverity) {
	STSettingsLintSeverityNote = 1,
	STSettingsLintSeverityWarning,
	STSettingsLintSeverityError,
};


@interface STSettingsLint : NSObject
@property (nonatomic,assign,readonly) STSettingsLintSeverity severity;
@property (nonatomic,copy,readonly) NSString *string;
@end


@interface STSettingsLinter : NSObject

- (id)initWithSettingsBundlePath:(NSString *)path;

- (NSArray *)lint;

@end
