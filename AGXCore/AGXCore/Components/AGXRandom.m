//
//  AGXRandom.m
//  AGXCore
//
//  Created by Char Aznable on 2017/10/30.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "AGXRandom.h"
#import "AGXArc.h"
#import "NSString+AGXCore.h"
#import "UIColor+AGXCore.h"

@implementation AGXRandom

+ (bool)BOOLEAN {
    return arc4random() % 2;
}

#define CHECK_RANDOM_BOUNDARY(condition)\
if (!(condition)) return 0;
#define MOD_BETWEEN(exp, min, max) ((exp) % ((max) - (min)) + (min))

+ (unsigned int)INT {
    return arc4random();
}

+ (unsigned int (^)(unsigned int))INT_UNDER {
    return AGX_BLOCK_AUTORELEASE(^unsigned int (unsigned int max) {
        CHECK_RANDOM_BOUNDARY(0 != max)
        return AGXRandom.INT_BETWEEN(0, max);
    });
}

+ (unsigned int (^)(unsigned int, unsigned int))INT_BETWEEN {
    return AGX_BLOCK_AUTORELEASE(^unsigned int (unsigned int min, unsigned int max) {
        CHECK_RANDOM_BOUNDARY(min < max)
        return MOD_BETWEEN(AGXRandom.INT, min, max);
    });
}

+ (unsigned long)LONG {
    return ((unsigned long)AGXRandom.INT) * ((unsigned long)AGXRandom.INT);
}

+ (unsigned long (^)(unsigned long))LONG_UNDER {
    return AGX_BLOCK_AUTORELEASE(^unsigned long (unsigned long max) {
        CHECK_RANDOM_BOUNDARY(0 != max)
        return AGXRandom.LONG_BETWEEN(0, max);
    });
}

+ (unsigned long (^)(unsigned long, unsigned long))LONG_BETWEEN {
    return AGX_BLOCK_AUTORELEASE(^unsigned long (unsigned long min, unsigned long max) {
        CHECK_RANDOM_BOUNDARY(min < max)
        return MOD_BETWEEN(AGXRandom.LONG, min, max);
    });
}

+ (NSUInteger)UINTEGER {
#if defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
    return AGXRandom.LONG;
#else
    return AGXRandom.INT;
#endif
}

+ (NSUInteger (^)(NSUInteger))UINTEGER_UNDER {
    return AGX_BLOCK_AUTORELEASE(^NSUInteger (NSUInteger max) {
        CHECK_RANDOM_BOUNDARY(0 != max)
        return AGXRandom.UINTEGER_BETWEEN(0, max);
    });
}

+ (NSUInteger (^)(NSUInteger, NSUInteger))UINTEGER_BETWEEN {
    return AGX_BLOCK_AUTORELEASE(^NSUInteger (NSUInteger min, NSUInteger max) {
        CHECK_RANDOM_BOUNDARY(min < max)
        return MOD_BETWEEN(AGXRandom.UINTEGER, min, max);
    });
}

#undef MOD_BETWEEN
#undef CHECK_RANDOM_BOUNDARY
#define MUL_BETWEEN(exp, min, max) ((exp) * ((max) - (min)) + (min))

+ (float)FLOAT {
    return ((float)AGXRandom.INT) / UINT32_MAX;
}

+ (float (^)(float))FLOAT_UNDER {
    return AGX_BLOCK_AUTORELEASE(^float (float max) {
        return AGXRandom.FLOAT_BETWEEN(0, max);
    });
}

+ (float (^)(float, float))FLOAT_BETWEEN {
    return AGX_BLOCK_AUTORELEASE(^float (float min, float max) {
        return MUL_BETWEEN(AGXRandom.FLOAT, min, max);
    });
}

+ (double)DOUBLE {
    return ((double)AGXRandom.INT) / UINT32_MAX;
}

+ (double (^)(double))DOUBLE_UNDER {
    return AGX_BLOCK_AUTORELEASE(^double (double max) {
        return AGXRandom.DOUBLE_BETWEEN(0, max);
    });
}

+ (double (^)(double, double))DOUBLE_BETWEEN {
    return AGX_BLOCK_AUTORELEASE(^double (double min, double max) {
        return MUL_BETWEEN(AGXRandom.DOUBLE, min, max);
    });
}

+ (CGFloat)CGFLOAT {
#if defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
    return AGXRandom.DOUBLE;
#else
    return AGXRandom.FLOAT;
#endif
}

+ (CGFloat (^)(CGFloat))CGFLOAT_UNDER {
    return AGX_BLOCK_AUTORELEASE(^CGFloat (CGFloat max) {
        return AGXRandom.CGFLOAT_BETWEEN(0, max);
    });
}

+ (CGFloat (^)(CGFloat, CGFloat))CGFLOAT_BETWEEN {
    return AGX_BLOCK_AUTORELEASE(^CGFloat (CGFloat min, CGFloat max) {
        return MUL_BETWEEN(AGXRandom.CGFLOAT, min, max);
    });
}

#undef MUL_BETWEEN

+ (NSString *(^)(int count))ASCII {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count) {
        return randomString(count, 37, 127, false, false, nil);
    });
}

+ (NSString *(^)(int count))NUM {
    return AGX_BLOCK_AUTORELEASE((^NSString *(int count) {
        return randomString(count, 0, 0, false, true, nil);
    }));
}

+ (NSString *(^)(int count))LETTERS {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count) {
        return randomString(count, 0, 0, true, false, nil);
    });
}

+ (NSString *(^)(int count))ALPHANUMERIC {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count) {
        return randomString(count, 0, 0, true, true, nil);
    });
}

+ (NSString *(^)(int count, NSString *chars))CHARACTERS {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count, NSString *chars) {
        return randomString(count, 0, 0, false, false, chars);
    });
}

AGX_STATIC NSString *randomString(int count, unsigned int start, unsigned int end,
                                  bool letters, bool numbers, NSString *chars) {
    if (count <= 0) {
        AGXLog(@"random count must be positive");
        return @"";
    }

    if (AGXIsEmpty(chars)) {
        AGXLog(@"character set must not be empty");
        return @"";
    }

    if (0 == start && 0 == end) {
        if (chars) {
            end = (unsigned int)chars.length;
        } else {
            if (!letters && !numbers) {
                end = UINT32_MAX;
            } else {
                end = 'z' + 1;
                start = ' ';
            }
        }
    } else {
        if (end <= start) {
            AGXLog(@"parameter end (%d) must be greater than start (%d)", end, start);
            return nil;
        }
    }

    NSMutableString *ms = [NSMutableString stringWithCapacity:count];
    int gap = end - start;

    while (count-- != 0) {
        int pos = AGXRandom.INT_UNDER(gap) + start;
        unichar ch  = chars ? [chars characterAtIndex:pos] : (unichar)pos;
        if ((letters && [NSCharacterSet.letterCharacterSet characterIsMember:ch])
            || (numbers && [NSCharacterSet.decimalDigitCharacterSet characterIsMember:ch])
            || (!letters && !numbers)) {
            if (ch >= 56320 && ch <= 57343) {
                if(0 == count) {
                    count++;
                } else {
                    // low surrogate, insert high surrogate after putting it in
                    [ms appendFormat:@"%C%C", ch, (unichar) (55296 + AGXRandom.INT_UNDER(128))];
                    count--;
                }
            } else if(ch >= 55296 && ch <= 56191) {
                if(0 == count) {
                    count++;
                } else {
                    // high surrogate, insert low surrogate before putting it in
                    [ms appendFormat:@"%C%C", (unichar) (56320 + AGXRandom.INT_UNDER(128)), ch];
                    count--;
                }
            } else if(ch >= 56192 && ch <= 56319) {
                // private high surrogate, no effing clue, so skip it
                count++;
            } else {
                [ms appendFormat:@"%C", ch];
            }
        } else {
            count++;
        }
    }
    return AGX_AUTORELEASE([ms copy]);
}

+ (CGPoint)CGPOINT {
    return CGPointMake(AGXRandom.CGFLOAT, AGXRandom.CGFLOAT);
}

+ (CGPoint (^)(CGRect))CGPOINT_IN {
    return AGX_BLOCK_AUTORELEASE(^CGPoint (CGRect rect) {
        return CGPointMake(AGXRandom.CGFLOAT * rect.size.width + rect.origin.x,
                           AGXRandom.CGFLOAT * rect.size.height + rect.origin.y);
    });
}

+ (UIColor *)UICOLOR_RGB {
    return AGXRandom.UICOLOR_RGB_ALL_LIMITIN(0, 1);
}

+ (UIColor *(^)(CGFloat, CGFloat))UICOLOR_RGB_ALL_LIMITIN {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(CGFloat min, CGFloat max) {
        return AGXRandom.UICOLOR_RGB_LIMITIN(min, max, min, max, min, max);
    });
}

+ (UIColor *(^)(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat))UICOLOR_RGB_LIMITIN {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(CGFloat minRed, CGFloat maxRed,
                                            CGFloat minGreen, CGFloat maxGreen,
                                            CGFloat minBlue, CGFloat maxBlue) {
        return AGX_UIColor(AGXRandom.CGFLOAT_BETWEEN(minRed, maxRed),
                           AGXRandom.CGFLOAT_BETWEEN(minGreen, maxGreen),
                           AGXRandom.CGFLOAT_BETWEEN(minBlue, maxBlue));
    });
}

+ (UIColor *)UICOLOR_RGBA {
    return AGXRandom.UICOLOR_RGBA_ALL_LIMITIN(0, 1);
}

+ (UIColor *(^)(CGFloat, CGFloat))UICOLOR_RGBA_ALL_LIMITIN {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(CGFloat min, CGFloat max) {
        return AGXRandom.UICOLOR_RGBA_LIMITIN(min, max, min, max, min, max, min, max);
    });
}

+ (UIColor *(^)(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat))UICOLOR_RGBA_LIMITIN {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(CGFloat minRed, CGFloat maxRed,
                                            CGFloat minGreen, CGFloat maxGreen,
                                            CGFloat minBlue, CGFloat maxBlue,
                                            CGFloat minAlpha, CGFloat maxAlpha) {
        return AGX_UIColor(AGXRandom.CGFLOAT_BETWEEN(minRed, maxRed),
                           AGXRandom.CGFLOAT_BETWEEN(minGreen, maxGreen),
                           AGXRandom.CGFLOAT_BETWEEN(minBlue, maxBlue),
                           AGXRandom.CGFLOAT_BETWEEN(minAlpha, maxAlpha));
    });
}

+ (NSArray *)FONT_NAMES {
    static NSMutableArray *FONT_NAMES;

    agx_once
    (if AGX_EXPECT_F(FONT_NAMES) return;
     NSArray *familyNames = [UIFont familyNames];
     FONT_NAMES = [[NSMutableArray alloc] init];
     for (NSString *familyName in familyNames) {
         if ([@"Bodoni Ornaments" isEqualToString:familyName]) continue; // ignore font
         NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
         if (fontNames.count != 0) [FONT_NAMES addObject:fontNames];
     })
    return FONT_NAMES;
}

+ (NSString *)UIFONT_NAME {
    NSArray *fontNames = AGXRandom.FONT_NAMES[AGXRandom.UINTEGER_UNDER
                                              (AGXRandom.FONT_NAMES.count)];
    return fontNames[AGXRandom.UINTEGER_UNDER(fontNames.count)];
}

+ (UIFont *)UIFONT {
    return AGXRandom.UIFONT_LIMITIN(10, 20);
}

+ (UIFont *(^)(CGFloat, CGFloat))UIFONT_LIMITIN {
    return AGX_BLOCK_AUTORELEASE(^UIFont *(CGFloat minSize, CGFloat maxSize) {
        return [UIFont fontWithName:AGXRandom.UIFONT_NAME size:
                AGXRandom.CGFLOAT_BETWEEN(minSize, maxSize)];
    });
}

@end
