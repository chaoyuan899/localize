//
//  LanguageUtil.h
//  LocalizationTest
//
//  Created by Jason Wu on 13-3-29.
//  Copyright (c) 2013年 The Technology Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSUILocalizer.h"

@interface LanguageUtil : NSObject

+(NSBundle *)getCurrentBundle;
+(void)setLanguage:(NSString *)language withLocalizerObject:(TTSUILocalizer *)localizerObj;
+(NSString *)localizedStringForKey:(NSString *)key alter:(NSString *)alternate;
+(NSString *)localizedStringForKey:(NSString *)key;
@end
