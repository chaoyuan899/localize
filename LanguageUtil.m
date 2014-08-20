//
//  LanguageUtil.m
//  LocalizationTest
//
//  Created by Jason Wu on 13-3-29.
//  Copyright (c) 2013年 The Technology Studios. All rights reserved.
//

#import "LanguageUtil.h"

@implementation LanguageUtil
static NSBundle *bundle = nil;

+(void)initialize {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString *current = [languages objectAtIndex:0];
    [self setLanguage:current withLocalizerObject:nil];
    
}

/*
 example calls:
 [Language setLanguage:@"it"];
 [Language setLanguage:@"de"];
 */
+(void)setLanguage:(NSString *)l withLocalizerObject:(TTSUILocalizer *)localizerObj{
    NSString *path = [[ NSBundle mainBundle ] pathForResource:l ofType:@"lproj" ];
    bundle = [NSBundle bundleWithPath:path];
    if (localizerObj != nil) {
        [localizerObj changeLocalizableLanguage];
    }
}

+(NSBundle *)getCurrentBundle{
    return bundle;
}

+(NSString *)localizedStringForKey:(NSString *)key alter:(NSString *)alternate {
    return [bundle localizedStringForKey:key value:alternate table:nil];
}

+(NSString *)localizedStringForKey:(NSString *)key{
    return [bundle localizedStringForKey:key value:nil table:nil];
}
@end
