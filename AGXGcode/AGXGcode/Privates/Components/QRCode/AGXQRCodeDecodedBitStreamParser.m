//
//  AGXQRCodeDecodedBitStreamParser.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/8.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXQRCodeDecodedBitStreamParser.h"
#import "AGXGcodeError.h"
#import "AGXBitSource.h"
#import "AGXCharacterSetECI.h"
#import "AGXQRCodeMode.h"

/**
 * See ISO 18004:2006, 6.4.4 Table 5
 */
const unichar AGX_ALPHANUMERIC_CHARS[45] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B',
    'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ' ', '$', '%', '*', '+', '-', '.', '/', ':'
};

const int AGX_GB2312_SUBSET = 1;

@implementation AGXQRCodeDecodedBitStreamParser

+ (AGXDecoderResult *)decode:(AGXByteArray *)bytes version:(AGXQRCodeVersion *)version ecLevel:(AGXQRCodeErrorCorrectionLevel *)ecLevel hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXBitSource *bits = [AGXBitSource bitSourceWithBytes:bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:50];
    NSMutableArray *byteSegments = [NSMutableArray arrayWithCapacity:1];

    AGXCharacterSetECI *currentCharacterSetECI = nil;
    AGXQRCodeMode *mode;
    BOOL fc1InEffect = NO;

    do {
        // While still another segment to read...
        if ([bits available] < 4) {
            // OK, assume we're done. Really, a TERMINATOR mode should have been recorded here
            mode = [AGXQRCodeMode terminatorMode];
        } else {
            mode = [AGXQRCodeMode forBits:[bits readBits:4]]; // mode is encoded by 4 bits
            if AGX_EXPECT_F(!mode) {
                if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                return nil;
            }
        }
        if (![mode isEqual:[AGXQRCodeMode terminatorMode]]) {
            if ([mode isEqual:[AGXQRCodeMode fnc1FirstPositionMode]] || [mode isEqual:[AGXQRCodeMode fnc1SecondPositionMode]]) {
                // We do little with FNC1 except alter the parsed result a bit according to the spec
                fc1InEffect = YES;
            } else if ([mode isEqual:[AGXQRCodeMode structuredAppendMode]]) {
                if AGX_EXPECT_F(bits.available < 16) {
                    if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                    return nil;
                }
                // sequence number and parity is added later to the result metadata
                // Read next 8 bits (symbol sequence #) and 8 bits (parity data), then continue
                [bits readBits:8];
                [bits readBits:8];
            } else if ([mode isEqual:[AGXQRCodeMode eciMode]]) {
                // Count doesn't apply to ECI
                int value = [self parseECIValue:bits];
                currentCharacterSetECI = [AGXCharacterSetECI characterSetECIByValue:value];
                if AGX_EXPECT_F(currentCharacterSetECI == nil) {
                    if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                    return nil;
                }
            } else {
                // First handle Hanzi mode which does not start with character count
                if ([mode isEqual:[AGXQRCodeMode hanziMode]]) {
                    //chinese mode contains a sub set indicator right after mode indicator
                    int subset = [bits readBits:4];
                    int countHanzi = [bits readBits:[mode characterCountBits:version]];
                    if (subset == AGX_GB2312_SUBSET) {
                        if AGX_EXPECT_F(![self decodeHanziSegment:bits result:result count:countHanzi]) {
                            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                            return nil;
                        }
                    }
                } else {
                    // "Normal" QR code modes:
                    // How many characters will follow, encoded in this mode?
                    int count = [bits readBits:[mode characterCountBits:version]];
                    if ([mode isEqual:[AGXQRCodeMode numericMode]]) {
                        if AGX_EXPECT_F(![self decodeNumericSegment:bits result:result count:count]) {
                            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                            return nil;
                        }
                    } else if ([mode isEqual:[AGXQRCodeMode alphanumericMode]]) {
                        if AGX_EXPECT_F(![self decodeAlphanumericSegment:bits result:result count:count fc1InEffect:fc1InEffect]) {
                            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                            return nil;
                        }
                    } else if ([mode isEqual:[AGXQRCodeMode byteMode]]) {
                        if AGX_EXPECT_F(![self decodeByteSegment:bits result:result count:count currentCharacterSetECI:currentCharacterSetECI byteSegments:byteSegments hints:hints]) {
                            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                            return nil;
                        }
                    } else if ([mode isEqual:[AGXQRCodeMode kanjiMode]]) {
                        if AGX_EXPECT_F(![self decodeKanjiSegment:bits result:result count:count]) {
                            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                            return nil;
                        }
                    } else {
                        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                        return nil;
                    }
                }
            }
        }
    } while (![mode isEqual:[AGXQRCodeMode terminatorMode]]);

    return [AGXDecoderResult resultWithText:result.description ecLevel:ecLevel ? ecLevel.description : nil];
}

+ (int)parseECIValue:(AGXBitSource *)bits {
    int firstByte = [bits readBits:8];
    if ((firstByte & 0x80) == 0) {
        return firstByte & 0x7F;
    }
    if ((firstByte & 0xC0) == 0x80) {
        int secondByte = [bits readBits:8];
        return ((firstByte & 0x3F) << 8) | secondByte;
    }
    if ((firstByte & 0xE0) == 0xC0) {
        int secondThirdBytes = [bits readBits:16];
        return ((firstByte & 0x1F) << 16) | secondThirdBytes;
    }
    return -1;
}

+ (BOOL)decodeHanziSegment:(AGXBitSource *)bits result:(NSMutableString *)result count:(int)count {
    if (count * 13 > bits.available) return NO;

    NSMutableData *buffer = [NSMutableData dataWithCapacity:2 * count];
    while (count > 0) {
        int twoBytes = [bits readBits:13];
        int assembledTwoBytes = ((twoBytes / 0x060) << 8) | (twoBytes % 0x060);
        if (assembledTwoBytes < 0x003BF) {
            assembledTwoBytes += 0x0A1A1;
        } else {
            assembledTwoBytes += 0x0A6A1;
        }
        int8_t bytes[2];
        bytes[0] = (int8_t)((assembledTwoBytes >> 8) & 0xFF);
        bytes[1] = (int8_t)(assembledTwoBytes & 0xFF);
        [buffer appendBytes:bytes length:2];

        count--;
    }

    NSString *string = [NSString stringWithData:buffer encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    if (string) [result appendString:string];
    return YES;
}

+ (BOOL)decodeNumericSegment:(AGXBitSource *)bits result:(NSMutableString *)result count:(int)count {
    // Read three digits at a time
    while (count >= 3) {
        // Each 10 bits encodes three digits
        if (bits.available < 10) {
            return NO;
        }
        int threeDigitsBits = [bits readBits:10];
        if (threeDigitsBits >= 1000) {
            return NO;
        }
        unichar next1 = [self toAlphaNumericChar:threeDigitsBits / 100];
        unichar next2 = [self toAlphaNumericChar:(threeDigitsBits / 10) % 10];
        unichar next3 = [self toAlphaNumericChar:threeDigitsBits % 10];

        [result appendFormat:@"%C%C%C", next1, next2, next3];
        count -= 3;
    }

    if (count == 2) {
        // Two digits left over to read, encoded in 7 bits
        if (bits.available < 7) {
            return NO;
        }
        int twoDigitsBits = [bits readBits:7];
        if (twoDigitsBits >= 100) {
            return NO;
        }
        unichar next1 = [self toAlphaNumericChar:twoDigitsBits / 10];
        unichar next2 = [self toAlphaNumericChar:twoDigitsBits % 10];
        [result appendFormat:@"%C%C", next1, next2];
    } else if (count == 1) {
        // One digit left over to read
        if (bits.available < 4) {
            return NO;
        }
        int digitBits = [bits readBits:4];
        if (digitBits >= 10) {
            return NO;
        }
        unichar next1 = [self toAlphaNumericChar:digitBits];
        [result appendFormat:@"%C", next1];
    }
    return YES;
}

+ (BOOL)decodeAlphanumericSegment:(AGXBitSource *)bits result:(NSMutableString *)result count:(int)count fc1InEffect:(BOOL)fc1InEffect {
    int start = (int)result.length;

    while (count > 1) {
        if (bits.available < 11) {
            return NO;
        }
        int nextTwoCharsBits = [bits readBits:11];
        unichar next1 = [self toAlphaNumericChar:nextTwoCharsBits / 45];
        unichar next2 = [self toAlphaNumericChar:nextTwoCharsBits % 45];

        [result appendFormat:@"%C%C", next1, next2];
        count -= 2;
    }

    if (count == 1) {
        if (bits.available < 6) {
            return NO;
        }
        unichar next1 = [self toAlphaNumericChar:[bits readBits:6]];
        [result appendFormat:@"%C", next1];
    }
    if (fc1InEffect) {
        for (int i = start; i < [result length]; i++) {
            if ([result characterAtIndex:i] == '%') {
                if (i < [result length] - 1 && [result characterAtIndex:i + 1] == '%') {
                    [result deleteCharactersInRange:NSMakeRange(i + 1, 1)];
                } else {
                    [result insertString:[NSString stringWithFormat:@"%C", (unichar)0x1D]
                                 atIndex:i];
                }
            }
        }
    }
    return YES;
}

+ (BOOL)decodeByteSegment:(AGXBitSource *)bits result:(NSMutableString *)result count:(int)count currentCharacterSetECI:(AGXCharacterSetECI *)currentCharacterSetECI byteSegments:(NSMutableArray *)byteSegments hints:(AGXDecodeHints *)hints {
    if (8 * count > bits.available) return NO;

    AGXByteArray *readBytes = [AGXByteArray byteArrayWithLength:count];
    for (int i = 0; i < count; i++) {
        readBytes.array[i] = (int8_t)[bits readBits:8];
    }
    NSStringEncoding encoding;
    if (currentCharacterSetECI == nil) {
        encoding = [self guessEncoding:readBytes hints:hints];
    } else {
        encoding = [currentCharacterSetECI encoding];
    }

    NSString *string = [NSString stringWithBytes:readBytes.array length:readBytes.length encoding:encoding];
    if (string) [result appendString:string];

    [byteSegments addObject:readBytes];
    return YES;
}

+ (BOOL)decodeKanjiSegment:(AGXBitSource *)bits result:(NSMutableString *)result count:(int)count {
    if (count * 13 > bits.available) return NO;

    NSMutableData *buffer = [NSMutableData dataWithCapacity:2 * count];
    while (count > 0) {
        int twoBytes = [bits readBits:13];
        int assembledTwoBytes = ((twoBytes / 0x0C0) << 8) | (twoBytes % 0x0C0);
        if (assembledTwoBytes < 0x01F00) {
            assembledTwoBytes += 0x08140;
        } else {
            assembledTwoBytes += 0x0C140;
        }
        int8_t bytes[2];
        bytes[0] = (int8_t)(assembledTwoBytes >> 8);
        bytes[1] = (int8_t)assembledTwoBytes;
        [buffer appendBytes:bytes length:2];

        count--;
    }

    NSString *string = [NSString stringWithData:buffer encoding:NSShiftJISStringEncoding];
    if (string) [result appendString:string];
    return YES;
}

+ (unichar)toAlphaNumericChar:(int)value {
    if (value >= 45) return -1;
    return AGX_ALPHANUMERIC_CHARS[value];
}

+ (NSStringEncoding)guessEncoding:(AGXByteArray *)bytes hints:(AGXDecodeHints *)hints {
    NSStringEncoding systemEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringGetSystemEncoding());
    BOOL assumeShiftJIS = systemEncoding == NSShiftJISStringEncoding || systemEncoding == NSJapaneseEUCStringEncoding;

    if (hints != nil) {
        NSStringEncoding encoding = hints.encoding;
        if (encoding > 0) return encoding;
    }
    // For now, merely tries to distinguish ISO-8859-1, UTF-8 and Shift_JIS,
    // which should be by far the most common encodings.
    int length = bytes.length;
    BOOL canBeISO88591 = YES;
    BOOL canBeShiftJIS = YES;
    BOOL canBeUTF8 = YES;
    int utf8BytesLeft = 0;
    //int utf8LowChars = 0;
    int utf2BytesChars = 0;
    int utf3BytesChars = 0;
    int utf4BytesChars = 0;
    int sjisBytesLeft = 0;
    //int sjisLowChars = 0;
    int sjisKatakanaChars = 0;
    //int sjisDoubleBytesChars = 0;
    int sjisCurKatakanaWordLength = 0;
    int sjisCurDoubleBytesWordLength = 0;
    int sjisMaxKatakanaWordLength = 0;
    int sjisMaxDoubleBytesWordLength = 0;
    //int isoLowChars = 0;
    //int isoHighChars = 0;
    int isoHighOther = 0;

    BOOL utf8bom = length > 3 &&
    bytes.array[0] == (int8_t) 0xEF &&
    bytes.array[1] == (int8_t) 0xBB &&
    bytes.array[2] == (int8_t) 0xBF;

    for (int i = 0;
         i < length && (canBeISO88591 || canBeShiftJIS || canBeUTF8);
         i++) {

        int value = bytes.array[i] & 0xFF;

        // UTF-8 stuff
        if (canBeUTF8) {
            if (utf8BytesLeft > 0) {
                if ((value & 0x80) == 0) {
                    canBeUTF8 = NO;
                } else {
                    utf8BytesLeft--;
                }
            } else if ((value & 0x80) != 0) {
                if ((value & 0x40) == 0) {
                    canBeUTF8 = NO;
                } else {
                    utf8BytesLeft++;
                    if ((value & 0x20) == 0) {
                        utf2BytesChars++;
                    } else {
                        utf8BytesLeft++;
                        if ((value & 0x10) == 0) {
                            utf3BytesChars++;
                        } else {
                            utf8BytesLeft++;
                            if ((value & 0x08) == 0) {
                                utf4BytesChars++;
                            } else {
                                canBeUTF8 = NO;
                            }
                        }
                    }
                }
            } //else {
            //utf8LowChars++;
            //}
        }

        // ISO-8859-1 stuff
        if (canBeISO88591) {
            if (value > 0x7F && value < 0xA0) {
                canBeISO88591 = NO;
            } else if (value > 0x9F) {
                if (value < 0xC0 || value == 0xD7 || value == 0xF7) {
                    isoHighOther++;
                } //else {
                //isoHighChars++;
                //}
            } //else {
            //isoLowChars++;
            //}
        }

        // Shift_JIS stuff
        if (canBeShiftJIS) {
            if (sjisBytesLeft > 0) {
                if (value < 0x40 || value == 0x7F || value > 0xFC) {
                    canBeShiftJIS = NO;
                } else {
                    sjisBytesLeft--;
                }
            } else if (value == 0x80 || value == 0xA0 || value > 0xEF) {
                canBeShiftJIS = NO;
            } else if (value > 0xA0 && value < 0xE0) {
                sjisKatakanaChars++;
                sjisCurDoubleBytesWordLength = 0;
                sjisCurKatakanaWordLength++;
                if (sjisCurKatakanaWordLength > sjisMaxKatakanaWordLength) {
                    sjisMaxKatakanaWordLength = sjisCurKatakanaWordLength;
                }
            } else if (value > 0x7F) {
                sjisBytesLeft++;
                //sjisDoubleBytesChars++;
                sjisCurKatakanaWordLength = 0;
                sjisCurDoubleBytesWordLength++;
                if (sjisCurDoubleBytesWordLength > sjisMaxDoubleBytesWordLength) {
                    sjisMaxDoubleBytesWordLength = sjisCurDoubleBytesWordLength;
                }
            } else {
                //sjisLowChars++;
                sjisCurKatakanaWordLength = 0;
                sjisCurDoubleBytesWordLength = 0;
            }
        }
    }

    if (canBeUTF8 && utf8BytesLeft > 0) {
        canBeUTF8 = NO;
    }
    if (canBeShiftJIS && sjisBytesLeft > 0) {
        canBeShiftJIS = NO;
    }

    // Easy -- if there is BOM or at least 1 valid not-single byte character (and no evidence it can't be UTF-8), done
    if (canBeUTF8 && (utf8bom || utf2BytesChars + utf3BytesChars + utf4BytesChars > 0)) {
        return NSUTF8StringEncoding;
    }
    // Easy -- if assuming Shift_JIS or at least 3 valid consecutive not-ascii characters (and no evidence it can't be), done
    if (canBeShiftJIS && (assumeShiftJIS || sjisMaxKatakanaWordLength >= 3 || sjisMaxDoubleBytesWordLength >= 3)) {
        return NSShiftJISStringEncoding;
    }
    // Distinguishing Shift_JIS and ISO-8859-1 can be a little tough for short words. The crude heuristic is:
    // - If we saw
    //   - only two consecutive katakana chars in the whole text, or
    //   - at least 10% of bytes that could be "upper" not-alphanumeric Latin1,
    // - then we conclude Shift_JIS, else ISO-8859-1
    if (canBeISO88591 && canBeShiftJIS) {
        return (sjisMaxKatakanaWordLength == 2 && sjisKatakanaChars == 2) || isoHighOther * 10 >= length
        ? NSShiftJISStringEncoding : NSISOLatin1StringEncoding;
    }
    
    // Otherwise, try in order ISO-8859-1, Shift JIS, UTF-8 and fall back to default platform encoding
    if (canBeISO88591) {
        return NSISOLatin1StringEncoding;
    }
    if (canBeShiftJIS) {
        return NSShiftJISStringEncoding;
    }
    if (canBeUTF8) {
        return NSUTF8StringEncoding;
    }
    // Otherwise, we take a wild guess with platform encoding
    return systemEncoding;
}

@end
