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

@implementation AGXRandom

+ (bool (^)(void))BOOLEAN {
    return AGX_BLOCK_AUTORELEASE(^bool (void) {
        return arc4random() % 2;
    });
}

+ (double (^)(void))DOUBLE {
    return AGX_BLOCK_AUTORELEASE(^double (void) {
        return ((double)arc4random()) / UINT32_MAX;
    });
}

+ (float (^)(void))FLOAT {
    return AGX_BLOCK_AUTORELEASE(^float (void) {
        return ((float)arc4random()) / UINT32_MAX;
    });
}

#define CHECK_RANDOM_BOUNDARY(max)              \
if (max <= 0) {                                 \
    AGXLog(@"random boundary must be positive");\
    return 0;                                   \
}

+ (unsigned long (^)(void))LONG {
    return AGX_BLOCK_AUTORELEASE(^unsigned long (void) {
        return ((unsigned long)arc4random()) * ((unsigned long)arc4random());
    });
}

+ (unsigned long (^)(long))LONG_UNDER {
    return AGX_BLOCK_AUTORELEASE(^unsigned long (long max) {
        CHECK_RANDOM_BOUNDARY(max)
        return AGXRandom.LONG() % max;
    });
}

+ (unsigned int (^)(void))INT {
    return AGX_BLOCK_AUTORELEASE(^unsigned int (void) {
        return arc4random();
    });
}

+ (unsigned int (^)(int))INT_UNDER {
    return AGX_BLOCK_AUTORELEASE(^unsigned int (int max) {
        CHECK_RANDOM_BOUNDARY(max)
        return AGXRandom.INT() % max;
    });
}

+ (NSUInteger (^)(void))UINTEGER {
    return AGX_BLOCK_AUTORELEASE(^NSUInteger (void) {
#if defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
        return AGXRandom.LONG();
#else
        return AGXRandom.INT();
#endif
    });
}

+ (NSUInteger (^)(NSInteger))UINTEGER_UNDER {
    return AGX_BLOCK_AUTORELEASE(^NSUInteger (NSInteger max) {
        CHECK_RANDOM_BOUNDARY(max)
        return AGXRandom.UINTEGER() % max;
    });
}

#undef CHECK_RANDOM_BOUNDARY

+ (NSString *(^)(int))NUM {
    return AGX_BLOCK_AUTORELEASE((^NSString *(int count) {
        return randomString(count, 0, 0, false, true, nil);
    }));
}

+ (NSString *(^)(int))ASCII {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count) {
        return randomString(count, 37, 127, false, false, nil);
    });
}

+ (NSString *(^)(int))LETTERS {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count) {
        return randomString(count, 0, 0, true, false, nil);
    });
}

+ (NSString *(^)(int))ALPHANUMERIC {
    return AGX_BLOCK_AUTORELEASE(^NSString *(int count) {
        return randomString(count, 0, 0, true, true, nil);
    });
}

AGX_STATIC NSString *randomString(int count, int start, int end,
                                  bool letters, bool numbers, NSString *chars) {
    if (count <= 0) {
        AGXLog(@"random count must be positive");
        return @"";
    }

    if ([chars isEmpty]) {
        AGXLog(@"character set must not be empty");
        return @"";
    }

    if (start == 0 && end == 0) {
        if (chars) {
            end = (int)chars.length;
        } else {
            if (!letters && !numbers) {
                end = INT_MAX;
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
                if(count == 0) {
                    count++;
                } else {
                    // low surrogate, insert high surrogate after putting it in
                    [ms appendFormat:@"%C%C", ch, (unichar) (55296 + AGXRandom.INT_UNDER(128))];
                    count--;
                }
            } else if(ch >= 55296 && ch <= 56191) {
                if(count == 0) {
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

@end
