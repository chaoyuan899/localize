//
//  TTSUILocalizer.m
//  LocalizationTest
//
//  Created by Jason Wu on 13-3-29.
//  Copyright (c) 2013年 The Technology Studios. All rights reserved.
//

#import "TTSUILocalizer.h"
#import "GTMDefines.h"
#import "LanguageUtil.h"

#define TAG_START 2000

@interface TTSUILocalizer (TTSUILocalizerPrivate)
- (void)localizeAccessibility:(id)object;

// Never recursively call any of these methods. Always call
// -[self localizeObject:recursively:].
- (void)localizeToolbar:(UIToolbar *)toolbar;
- (void)localizeSegmentedControl:(UISegmentedControl *)segmentedControl;
- (void)localizeView:(UIView *)view recursively:(BOOL)recursive;
- (void)localizeButton:(UIButton *)button;
@end

@implementation TTSUILocalizer{
    NSMutableDictionary *propKeyMap;
    NSInteger tagNum;
}
@synthesize owner = owner_;
@synthesize otherObjectToLocalize = otherObjectToLocalize_;
@synthesize yetAnotherObjectToLocalize = yetAnotherObjectToLocalize_;

- (id)initWithBundle:(NSBundle *)bundle {
    if ((self = [super init])) {
        bundle_ = bundle;
    }
    return self;
}

- (void)awakeFromNib {
    id owner = self.owner;
    tagNum = TAG_START;
    propKeyMap = [NSMutableDictionary dictionary];
    if (owner) {
//        NSBundle *newBundle = [[self class] bundleForOwner:owner];
//        bundle_ = newBundle;
        bundle_ = [LanguageUtil getCurrentBundle];
        [self localizeObject:self.owner recursively:YES];
        [self localizeObject:self.otherObjectToLocalize recursively:YES];
        [self localizeObject:self.yetAnotherObjectToLocalize recursively:YES];
    } else {
        _GTMDevLog(@"Expected an owner set for %@", self);
    }
    // Clear the outlets.
//    self.owner = nil;
//    self.otherObjectToLocalize = nil;
//    self.yetAnotherObjectToLocalize = nil;
}

#pragma mark - Implement Methods
-(void)changeLocalizableLanguage
{
//    NSLog(@"Change language to: %@", lang);
//    NSString *path = [[ NSBundle mainBundle ] pathForResource:lang ofType:@"lproj" ];
//    bundle_ = [NSBundle bundleWithPath:path];
    bundle_ = [LanguageUtil getCurrentBundle];
    [self localizeObject:self.owner recursively:YES];
    [self localizeObject:self.otherObjectToLocalize recursively:YES];
    [self localizeObject:self.yetAnotherObjectToLocalize recursively:YES];
}

+ (NSBundle *)bundleForOwner:(id)owner {
    NSBundle *newBundle = nil;
    if (owner) {
        if ([owner isKindOfClass:[UIViewController class]]) {
            newBundle = [(UIViewController *)owner nibBundle];
        }
        if (!newBundle) {
            newBundle = [NSBundle mainBundle];
        }
    }
    return newBundle;
}

- (void)registerLocalizedView:(UIView *)view withText:(NSString *)label property:(NSString *)prop{
     if ([label respondsToSelector:@selector(hasPrefix:)] && [label hasPrefix:@"^"]) {
        if (view.tag < TAG_START) {
            tagNum++;
            view.tag = tagNum;
        }
        NSString *key = [label substringFromIndex:1];
        NSMutableDictionary *i18KeyMap = [propKeyMap objectForKey:prop];
        if (i18KeyMap == nil) {
            i18KeyMap = [NSMutableDictionary dictionary];
        }
        [i18KeyMap setObject:key forKey:[NSString stringWithFormat:@"%d", tagNum]];
        [propKeyMap setObject:i18KeyMap forKey:prop];
    }
}

- (NSString *)localizedStringForView:(UIView *)view property:(NSString *)prop{
    NSString *localized = nil;
    
    if (bundle_ && (view.tag >= TAG_START)) {
        NSMutableDictionary *i18KeyMap = [propKeyMap objectForKey:prop];
        NSString *key = [i18KeyMap objectForKey:[NSString stringWithFormat:@"%d", view.tag]];
        NSString *notFoundValue = @"__TTS_NOT_FOUND__";
        localized = [bundle_ localizedStringForKey:key
                                             value:notFoundValue
                                             table:nil];
        if ([localized isEqualToString:notFoundValue]) {
            localized = nil;
        }
    }
    return localized;
}
                
- (void)localizeObject:(id)object recursively:(BOOL)recursive {
    if (object) {
        if ([object isKindOfClass:[UIViewController class]]) {
            UIView *view = [object view];
            [self localizeView:view recursively:recursive];
        } else if ([object isKindOfClass:[UIView class]]) {
            [self localizeView:(UIView *)object recursively:recursive];
        }
    }
}

- (void)localizeView:(UIView *)view recursively:(BOOL)recursive {
    if (view) {
        // Do accessibility on views.
        [self localizeAccessibility:view];
        
        if (recursive) {
            for (UIView *subview in [view subviews]) {
                [self localizeObject:subview recursively:recursive];
            }
        }
        
        // Specific types
        if ([view isKindOfClass:[UIButton class]]) {
            [self localizeButton:(UIButton *)view];
        }
        
        // Then do all possible strings.
        if ([view respondsToSelector:@selector(title)]
            && [view respondsToSelector:@selector(setTitle:)]) {
            NSString *title = [view performSelector:@selector(title)];
            if (title) {
                [self registerLocalizedView:view withText:title property:@"title"];
                NSString *localizedTitle = [self localizedStringForView:view property:@"title"];
                if (localizedTitle) {
                    [view performSelector:@selector(setTitle:) withObject:localizedTitle];
                }
            }
        }
        
        if ([view respondsToSelector:@selector(text)]
            && [view respondsToSelector:@selector(setText:)]) {
            NSString *text = [view performSelector:@selector(text)];
            if (text) {
                [self registerLocalizedView:view withText:text property:@"text"];
                NSString *localizedText = [self localizedStringForView:view property:@"text"];
                if (localizedText) {
                    [view performSelector:@selector(setText:) withObject:localizedText];
                }
            }
        }
        
        if ([view respondsToSelector:@selector(placeholder)]
            && [view respondsToSelector:@selector(setPlaceholder:)]) {
            NSString *placeholder = [view performSelector:@selector(placeholder)];
            if (placeholder) {
                [self registerLocalizedView:view withText:placeholder property:@"placeholder"];
                NSString *localizedPlaceholder =
                [self localizedStringForView:view property:@"placeholder"];
                if (localizedPlaceholder) {
                    [view performSelector:@selector(setPlaceholder:)
                               withObject:localizedPlaceholder];
                }
            }
        }
    }
}

- (void)localizeAccessibility:(id)object {
    if ([object respondsToSelector:@selector(accessibilityHint)]
        && [object respondsToSelector:@selector(setAccessibilityHint:)]) {
        NSString *accessibilityHint =
        [object performSelector:@selector(accessibilityHint)];
        if (accessibilityHint) {
            [self registerLocalizedView:object withText:accessibilityHint property:@"accessibilityHint"];
            NSString *localizedAccessibilityHint =
            [self localizedStringForView:object property:@"accessibilityHint"];
            if (localizedAccessibilityHint) {
                [object performSelector:@selector(setAccessibilityHint:)
                             withObject:localizedAccessibilityHint];
            }
        }
    }
    
    if ([object respondsToSelector:@selector(accessibilityLabel)]
        && [object respondsToSelector:@selector(setAccessibilityLabel:)]) {
        NSString *accessibilityLabel =
        [object performSelector:@selector(accessibilityLabel)];
        if (accessibilityLabel) {
            [self registerLocalizedView:object withText:accessibilityLabel property:@"accessibilityLabel"];
            NSString *localizedAccessibilityLabel =
            [self localizedStringForView:object property:@"accessibilityLabel"];
            if (localizedAccessibilityLabel) {
                [object performSelector:@selector(setAccessibilityLabel:)
                             withObject:localizedAccessibilityLabel];
            }
        }
    }
    
    if ([object respondsToSelector:@selector(accessibilityValue)]
        && [object respondsToSelector:@selector(setAccessibilityValue:)]) {
        NSString *accessibilityValue =
        [object performSelector:@selector(accessibilityValue)];
        if (accessibilityValue) {
            [self registerLocalizedView:object withText:accessibilityValue property:@"accessibilityValue"];

            NSString *localizedAccessibilityValue =
            [self localizedStringForView:object property:@"accessibilityValue"];
            if (localizedAccessibilityValue) {
                [object performSelector:@selector(setAccessibilityValue:)
                             withObject:localizedAccessibilityValue];
            }
        }
    }
}

- (void)localizeButton:(UIButton *)button {
    UIControlState allStates[] = { UIControlStateNormal,
        UIControlStateHighlighted,
        UIControlStateDisabled,
        UIControlStateSelected };
    for (size_t idx = 0; idx < (sizeof(allStates)/sizeof(allStates[0])); ++idx) {
        UIControlState state = allStates[idx];
        NSString *value = [button titleForState:state];
        if (value) {
            [self registerLocalizedView:button withText:value property:@"button"];
            NSString* localizedValue = [self localizedStringForView:button property:@"button"];
            if (localizedValue) {
                [button setTitle:localizedValue forState:state];
            }
        }
    }
}

@end
