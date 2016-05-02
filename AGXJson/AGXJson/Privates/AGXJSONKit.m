//
//  JSONKit.m
//  http://github.com/johnezang/JSONKit
//  Dual licensed under either the terms of the BSD License, or alternatively
//  under the terms of the Apache License, Version 2.0, as specified below.
//

/*
 Copyright (c) 2011, John Engelhart
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of the Zang Industries nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 Copyright 2011 John Engelhart
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/*
 Acknowledgments:
 
 The bulk of the UTF8 / UTF32 conversion and verification comes
 from ConvertUTF.[hc].  It has been modified from the original sources.
 
 The original sources were obtained from http://www.unicode.org/.
 However, the web site no longer seems to host the files.  Instead,
 the Unicode FAQ http://www.unicode.org/faq//utf_bom.html#gen4
 points to International Components for Unicode (ICU)
 http://site.icu-project.org/ as an example of how to write a UTF
 converter.
 
 The decision to use the ConvertUTF.[ch] code was made to leverage
 "proven" code.  Hopefully the local modifications are bug free.
 
 The code in isValidCodePoint() is derived from the ICU code in
 utf.h for the macros U_IS_UNICODE_NONCHAR and U_IS_UNICODE_CHAR.
 
 From the original ConvertUTF.[ch]:
 
 * Copyright 2001-2004 Unicode, Inc.
 *
 * Disclaimer
 *
 * This source code is provided as is by Unicode, Inc. No claims are
 * made as to fitness for any particular purpose. No warranties of any
 * kind are expressed or implied. The recipient agrees to determine
 * applicability of information provided. If this file has been
 * purchased on magnetic or optical media from Unicode, Inc., the
 * sole remedy for any claim will be exchange of defective media
 * within 90 days of receipt.
 *
 * Limitations on Rights to Redistribute This Code
 *
 * Unicode, Inc. hereby grants the right to freely use the information
 * supplied in this file in the creation of products supporting the
 * Unicode Standard, and to make copies of this file in any form
 * for internal or external distribution as long as this notice
 * remains attached.
 
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <sys/errno.h>
#include <math.h>
#include <limits.h>
#include <objc/runtime.h>

#import "AGXJSONKit.h"

//#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFNumber.h>

//#import <Foundation/Foundation.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSObjCRuntime.h>

#import <AGXCore/AGXCore/AGXArc.h>

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#ifdef JK_ENABLE_CF_TRANSFER_OWNERSHIP_CALLBACKS
#warning As of JSONKit v1.4, JK_ENABLE_CF_TRANSFER_OWNERSHIP_CALLBACKS is no longer required.  It is no longer a valid option.
#endif

#ifdef __OBJC_GC__
#error JSONKit does not support Objective-C Garbage Collection
#endif

// The following checks are really nothing more than sanity checks.
// JSONKit technically has a few problems from a "strictly C99 conforming" standpoint, though they are of the pedantic nitpicking variety.
// In practice, though, for the compilers and architectures we can reasonably expect this code to be compiled for, these pedantic nitpicks aren't really a problem.
// Since we're limited as to what we can do with pre-processor #if checks, these checks are not nearly as through as they should be.

#if (UINT_MAX != 0xffffffffU) || (INT_MIN != (-0x7fffffff-1)) || (ULLONG_MAX != 0xffffffffffffffffULL) || (LLONG_MIN != (-0x7fffffffffffffffLL-1LL))
#error JSONKit requires the C 'int' and 'long long' types to be 32 and 64 bits respectively.
#endif

#if !defined(__LP64__) && ((UINT_MAX != ULONG_MAX) || (INT_MAX != LONG_MAX) || (INT_MIN != LONG_MIN) || (WORD_BIT != LONG_BIT))
#error JSONKit requires the C 'int' and 'long' types to be the same on 32-bit architectures.
#endif

// Cocoa / Foundation uses NS*Integer as the type for a lot of arguments.  We make sure that NS*Integer is something we are expecting and is reasonably compatible with size_t / ssize_t

#if (NSUIntegerMax != ULONG_MAX) || (NSIntegerMax != LONG_MAX) || (NSIntegerMin != LONG_MIN)
#error JSONKit requires NSInteger and NSUInteger to be the same size as the C 'long' type.
#endif

#if (NSUIntegerMax != SIZE_MAX) || (NSIntegerMax != SSIZE_MAX)
#error JSONKit requires NSInteger and NSUInteger to be the same size as the C 'size_t' type.
#endif

// For DJB hash.
#define AGXJK_HASH_INIT           (1402737925UL)

// Use __builtin_clz() instead of trailingBytesForUTF8[] table lookup.
#define AGXJK_FAST_TRAILING_BYTES

// AGXJK_CACHE_SLOTS must be a power of 2.  Default size is 1024 slots.
#define AGXJK_CACHE_SLOTS_BITS    (10)
#define AGXJK_CACHE_SLOTS         (1UL << AGXJK_CACHE_SLOTS_BITS)
// AGXJK_CACHE_PROBES is the number of probe attempts.
#define AGXJK_CACHE_PROBES        (4UL)
// AGXJK_INIT_CACHE_AGE must be < (1 << AGE) - 1, where AGE is sizeof(typeof(AGE)) * 8.
#define AGXJK_INIT_CACHE_AGE      (0)

// AGXJK_TOKENBUFFER_SIZE is the default stack size for the temporary buffer used to hold "non-simple" strings (i.e., contains \ escapes)
#define AGXJK_TOKENBUFFER_SIZE    (1024UL * 2UL)

// AGXJK_STACK_OBJS is the default number of spaces reserved on the stack for temporarily storing pointers to Obj-C objects before they can be transferred to a NSArray / NSDictionary.
#define AGXJK_STACK_OBJS          (1024UL * 1UL)

#define AGXJK_JSONBUFFER_SIZE     (1024UL * 4UL)
#define AGXJK_UTF8BUFFER_SIZE     (1024UL * 16UL)

#define AGXJK_ENCODE_CACHE_SLOTS  (1024UL)

#if defined (__GNUC__) && (__GNUC__ >= 4)
#define AGXJK_ATTRIBUTES(attr, ...)        __attribute__((attr, ##__VA_ARGS__))
#define AGXJK_EXPECTED(cond, expect)       __builtin_expect((long)(cond), (expect))
#define AGXJK_EXPECT_T(cond)               AGXJK_EXPECTED(cond, 1U)
#define AGXJK_EXPECT_F(cond)               AGXJK_EXPECTED(cond, 0U)
#define AGXJK_PREFETCH(ptr)                __builtin_prefetch(ptr)
#else  // defined (__GNUC__) && (__GNUC__ >= 4)
#define AGXJK_ATTRIBUTES(attr, ...)
#define AGXJK_EXPECTED(cond, expect)       (cond)
#define AGXJK_EXPECT_T(cond)               (cond)
#define AGXJK_EXPECT_F(cond)               (cond)
#define AGXJK_PREFETCH(ptr)
#endif // defined (__GNUC__) && (__GNUC__ >= 4)

#define AGXJK_STATIC_INLINE            static __inline__ AGXJK_ATTRIBUTES(always_inline)
#define AGXJK_ALIGNED(arg)                               AGXJK_ATTRIBUTES(aligned(arg))
#define AGXJK_UNUSED_ARG                                 AGXJK_ATTRIBUTES(unused)
#define AGXJK_WARN_UNUSED                                AGXJK_ATTRIBUTES(warn_unused_result)
#define AGXJK_WARN_UNUSED_CONST                          AGXJK_ATTRIBUTES(warn_unused_result, const)
#define AGXJK_WARN_UNUSED_PURE                           AGXJK_ATTRIBUTES(warn_unused_result, pure)
#define AGXJK_WARN_UNUSED_SENTINEL                       AGXJK_ATTRIBUTES(warn_unused_result, sentinel)
#define AGXJK_NONNULL_ARGS(arg, ...)                     AGXJK_ATTRIBUTES(nonnull(arg, ##__VA_ARGS__))
#define AGXJK_WARN_UNUSED_NONNULL_ARGS(arg, ...)         AGXJK_ATTRIBUTES(warn_unused_result, nonnull(arg, ##__VA_ARGS__))
#define AGXJK_WARN_UNUSED_CONST_NONNULL_ARGS(arg, ...)   AGXJK_ATTRIBUTES(warn_unused_result, const, nonnull(arg, ##__VA_ARGS__))
#define AGXJK_WARN_UNUSED_PURE_NONNULL_ARGS(arg, ...)    AGXJK_ATTRIBUTES(warn_unused_result, pure, nonnull(arg, ##__VA_ARGS__))

#if defined (__GNUC__) && (__GNUC__ >= 4) && (__GNUC_MINOR__ >= 3)
#define AGXJK_ALLOC_SIZE_NON_NULL_ARGS_WARN_UNUSED(as, nn, ...) AGXJK_ATTRIBUTES(warn_unused_result, nonnull(nn, ##__VA_ARGS__), alloc_size(as))
#else
#define AGXJK_ALLOC_SIZE_NON_NULL_ARGS_WARN_UNUSED(as, nn, ...) AGXJK_ATTRIBUTES(warn_unused_result, nonnull(nn, ##__VA_ARGS__))
#endif

#if !(__OBJC2__ && __LP64__)
#define AGXJK_SUPPORT_TAGGED_POINTERS 0
#else
#define AGXJK_SUPPORT_TAGGED_POINTERS 1
#endif

#if !AGXJK_SUPPORT_TAGGED_POINTERS || !TARGET_OS_IPHONE
#define AGXJK_SUPPORT_MSB_TAGGED_POINTERS 0
#else
#define AGXJK_SUPPORT_MSB_TAGGED_POINTERS 1
#endif

@class AGXJKArray, AGXJKDictionaryEnumerator, AGXJKDictionary;

enum {
    AGXJSONNumberStateStart                 = 0,
    AGXJSONNumberStateFinished              = 1,
    AGXJSONNumberStateError                 = 2,
    AGXJSONNumberStateWholeNumberStart      = 3,
    AGXJSONNumberStateWholeNumberMinus      = 4,
    AGXJSONNumberStateWholeNumberZero       = 5,
    AGXJSONNumberStateWholeNumber           = 6,
    AGXJSONNumberStatePeriod                = 7,
    AGXJSONNumberStateFractionalNumberStart = 8,
    AGXJSONNumberStateFractionalNumber      = 9,
    AGXJSONNumberStateExponentStart         = 10,
    AGXJSONNumberStateExponentPlusMinus     = 11,
    AGXJSONNumberStateExponent              = 12,
};

enum {
    AGXJSONStringStateStart                           = 0,
    AGXJSONStringStateParsing                         = 1,
    AGXJSONStringStateFinished                        = 2,
    AGXJSONStringStateError                           = 3,
    AGXJSONStringStateEscape                          = 4,
    AGXJSONStringStateEscapedUnicode1                 = 5,
    AGXJSONStringStateEscapedUnicode2                 = 6,
    AGXJSONStringStateEscapedUnicode3                 = 7,
    AGXJSONStringStateEscapedUnicode4                 = 8,
    AGXJSONStringStateEscapedUnicodeSurrogate1        = 9,
    AGXJSONStringStateEscapedUnicodeSurrogate2        = 10,
    AGXJSONStringStateEscapedUnicodeSurrogate3        = 11,
    AGXJSONStringStateEscapedUnicodeSurrogate4        = 12,
    AGXJSONStringStateEscapedNeedEscapeForSurrogate   = 13,
    AGXJSONStringStateEscapedNeedEscapedUForSurrogate = 14,
};

enum {
    AGXJKParseAcceptValue      = (1 << 0),
    AGXJKParseAcceptComma      = (1 << 1),
    AGXJKParseAcceptEnd        = (1 << 2),
    AGXJKParseAcceptValueOrEnd = (AGXJKParseAcceptValue | AGXJKParseAcceptEnd),
    AGXJKParseAcceptCommaOrEnd = (AGXJKParseAcceptComma | AGXJKParseAcceptEnd),
};

enum {
    AGXJKClassUnknown    = 0,
    AGXJKClassString     = 1,
    AGXJKClassNumber     = 2,
    AGXJKClassArray      = 3,
    AGXJKClassDictionary = 4,
    AGXJKClassNull       = 5,
};

typedef NS_ENUM(AGXJKFlags, AGXJKManagedBufferFlags) {
    AGXJKManagedBufferOnStack        = 1,
    AGXJKManagedBufferOnHeap         = 2,
    AGXJKManagedBufferLocationMask   = (0x3),
    AGXJKManagedBufferLocationShift  = (0),

    AGXJKManagedBufferMustFree       = (1 << 2),
};

typedef NS_ENUM(AGXJKFlags, AGXJKObjectStackFlags) {
    AGXJKObjectStackOnStack        = 1,
    AGXJKObjectStackOnHeap         = 2,
    AGXJKObjectStackLocationMask   = (0x3),
    AGXJKObjectStackLocationShift  = (0),

    AGXJKObjectStackMustFree       = (1 << 2),
};

typedef NS_ENUM(NSUInteger, AGXJKTokenType) {
    AGXJKTokenTypeInvalid     = 0,
    AGXJKTokenTypeNumber      = 1,
    AGXJKTokenTypeString      = 2,
    AGXJKTokenTypeObjectBegin = 3,
    AGXJKTokenTypeObjectEnd   = 4,
    AGXJKTokenTypeArrayBegin  = 5,
    AGXJKTokenTypeArrayEnd    = 6,
    AGXJKTokenTypeSeparator   = 7,
    AGXJKTokenTypeComma       = 8,
    AGXJKTokenTypeTrue        = 9,
    AGXJKTokenTypeFalse       = 10,
    AGXJKTokenTypeNull        = 11,
    AGXJKTokenTypeWhiteSpace  = 12,
};

// These are prime numbers to assist with hash slot probing.
typedef NS_ENUM(NSUInteger, AGXJKValueType) {
    AGXJKValueTypeNone             = 0,
    AGXJKValueTypeString           = 5,
    AGXJKValueTypeLongLong         = 7,
    AGXJKValueTypeUnsignedLongLong = 11,
    AGXJKValueTypeDouble           = 13,
};

typedef NS_ENUM(NSUInteger, AGXJKEncodeOptionType) {
    AGXJKEncodeOptionAsData              = 1,
    AGXJKEncodeOptionAsString            = 2,
    AGXJKEncodeOptionAsTypeMask          = 0x7,
    AGXJKEncodeOptionCollectionObj       = (1 << 3),
    AGXJKEncodeOptionStringObj           = (1 << 4),
    AGXJKEncodeOptionStringObjTrimQuotes = (1 << 5),

};

typedef NSUInteger AGXJKHash;

#if AGXJK_SUPPORT_TAGGED_POINTERS
typedef struct AGXJKFastTagLookup   AGXJKFastTagLookup;
#endif
typedef struct AGXJKError           AGXJKError;
typedef struct AGXJKTokenCacheItem  AGXJKTokenCacheItem;
typedef struct AGXJKTokenCache      AGXJKTokenCache;
typedef struct AGXJKTokenValue      AGXJKTokenValue;
typedef struct AGXJKParseToken      AGXJKParseToken;
typedef struct AGXJKPtrRange        AGXJKPtrRange;
typedef struct AGXJKObjectStack     AGXJKObjectStack;
typedef struct AGXJKBuffer          AGXJKBuffer;
typedef struct AGXJKConstBuffer     AGXJKConstBuffer;
typedef struct AGXJKConstPtrRange   AGXJKConstPtrRange;
typedef struct AGXJKRange           AGXJKRange;
typedef struct AGXJKManagedBuffer   AGXJKManagedBuffer;
typedef struct AGXJKFastClassLookup AGXJKFastClassLookup;
typedef struct AGXJKEncodeCache     AGXJKEncodeCache;
typedef struct AGXJKEncodeState     AGXJKEncodeState;
typedef struct AGXJKObjCImpCache    AGXJKObjCImpCache;
typedef struct AGXJKHashTableEntry  AGXJKHashTableEntry;

typedef id (*AGXNSNumberAllocImp)(id receiver, SEL selector);
typedef id (*AGXNSNumberInitWithUnsignedLongLongImp)(id receiver, SEL selector, unsigned long long value);
typedef id (*AGXJKClassFormatterIMP)(id receiver, SEL selector, id object);
#ifdef __BLOCKS__
typedef id (^AGXJKClassFormatterBlock)(id formatObject);
#endif

#if AGXJK_SUPPORT_TAGGED_POINTERS
struct AGXJKFastTagLookup {
    uintptr_t stringClass;
    uintptr_t numberClass;
    uintptr_t arrayClass;
    uintptr_t dictionaryClass;
    uintptr_t nullClass;
};
#endif

struct AGXJKError {
    CFStringRef domain;
    NSInteger   code;
    CFStringRef desc;
};

struct AGXJKPtrRange {
    unsigned char *ptr;
    size_t         length;
};

struct AGXJKConstPtrRange {
    const unsigned char *ptr;
    size_t               length;
};

struct AGXJKRange {
    size_t location, length;
};

struct AGXJKManagedBuffer {
    AGXJKPtrRange           bytes;
    AGXJKManagedBufferFlags flags;
    size_t                  roundSizeUpToMultipleOf;
};

struct AGXJKObjectStack {
    void                  **objects, **keys;
    CFHashCode             *cfHashes;
    size_t                  count, index, roundSizeUpToMultipleOf;
    AGXJKObjectStackFlags   flags;
};

struct AGXJKBuffer {
    AGXJKPtrRange bytes;
};

struct AGXJKConstBuffer {
    AGXJKConstPtrRange bytes;
};

struct AGXJKTokenValue {
    AGXJKConstPtrRange   ptrRange;
    AGXJKValueType       type;
    AGXJKHash            hash;
    union {
        long long          longLongValue;
        unsigned long long unsignedLongLongValue;
        double             doubleValue;
    } number;
    AGXJKTokenCacheItem *cacheItem;
};

struct AGXJKParseToken {
    AGXJKConstPtrRange tokenPtrRange;
    AGXJKTokenType     type;
    AGXJKTokenValue    value;
    AGXJKManagedBuffer tokenBuffer;
};

struct AGXJKTokenCacheItem {
    void           *object;
    AGXJKHash       hash;
    CFHashCode      cfHash;
    size_t          size;
    unsigned char  *bytes;
    AGXJKValueType  type;
};

struct AGXJKTokenCache {
    AGXJKTokenCacheItem *items;
    size_t               count;
    unsigned int         prng_lfsr;
    unsigned char        age[AGXJK_CACHE_SLOTS];
};

struct AGXJKObjCImpCache {
    Class                                   NSNumberClass;
    AGXNSNumberAllocImp                     NSNumberAlloc;
    AGXNSNumberInitWithUnsignedLongLongImp  NSNumberInitWithUnsignedLongLong;
};

struct AGXJKParseState {
    AGXJKParseOptionFlags   parseOptionFlags;
    AGXJKConstBuffer        stringBuffer;
    size_t                  atIndex, lineNumber, lineStartIndex;
    size_t                  prev_atIndex, prev_lineNumber, prev_lineStartIndex;
    AGXJKParseToken         token;
    AGXJKObjectStack        objectStack;
    AGXJKTokenCache         cache;
    AGXJKObjCImpCache       objCImpCache;
    AGXJKError              error;
    int                     errorIsPrev;
    BOOL                    mutableCollections;
};

struct AGXJKFastClassLookup {
    void *stringClass;
    void *numberClass;
    void *arrayClass;
    void *dictionaryClass;
    void *nullClass;
};

struct AGXJKEncodeCache {
    void *object;
    size_t offset;
    size_t length;
};

struct AGXJKEncodeState {
    AGXJKManagedBuffer          utf8ConversionBuffer;
    AGXJKManagedBuffer          stringBuffer;
    size_t                      atIndex;
    AGXJKFastClassLookup        fastClassLookup;
#if AGXJK_SUPPORT_TAGGED_POINTERS
    AGXJKFastTagLookup          fastTagLookup;
#endif
    AGXJKEncodeCache            cache[AGXJK_ENCODE_CACHE_SLOTS];
    AGXJKSerializeOptionFlags   serializeOptionFlags;
    AGXJKEncodeOptionType       encodeOption;
    size_t                      depth;
    AGXJKError                  error;
    void                       *classFormatterDelegate;
    SEL                         classFormatterSelector;
    AGXJKClassFormatterIMP      classFormatterIMP;
#ifdef __BLOCKS__
    void                       *classFormatterBlock; // AGXJKClassFormatterBlock
#endif
};

// This is a JSONKit private class.
@interface AGXJKSerializer : NSObject {
    AGXJKEncodeState *encodeState;
}

#ifdef __BLOCKS__
#define AGXJKSERIALIZER_BLOCKS_PROTO id(^)(id object)
#else
#define AGXJKSERIALIZER_BLOCKS_PROTO id
#endif

+ (id)serializeObject:(id)object options:(AGXJKSerializeOptionFlags)optionFlags encodeOption:(AGXJKEncodeOptionType)encodeOption block:(AGXJKSERIALIZER_BLOCKS_PROTO)block delegate:(id)delegate selector:(SEL)selector error:(NSError **)error;
- (id)serializeObject:(id)object options:(AGXJKSerializeOptionFlags)optionFlags encodeOption:(AGXJKEncodeOptionType)encodeOption block:(AGXJKSERIALIZER_BLOCKS_PROTO)block delegate:(id)delegate selector:(SEL)selector error:(NSError **)error;
- (void)releaseState;

@end

struct AGXJKHashTableEntry {
    NSUInteger keyHash;
    void *key;
    void *object;
};

typedef uint32_t UTF32; /* at least 32 bits */
typedef uint16_t UTF16; /* at least 16 bits */
typedef uint8_t  UTF8;  /* typically 8 bits */

typedef NS_ENUM(NSUInteger, AGXConversionResult) {
    conversionOK,           /* conversion successful */
    sourceExhausted,        /* partial character in source, but hit end */
    targetExhausted,        /* insuff. room in target for conversion */
    sourceIllegal           /* source sequence is illegal/malformed */
};

#define UNI_REPLACEMENT_CHAR (UTF32)0x0000FFFD
#define UNI_MAX_BMP          (UTF32)0x0000FFFF
#define UNI_MAX_UTF16        (UTF32)0x0010FFFF
#define UNI_MAX_UTF32        (UTF32)0x7FFFFFFF
#define UNI_MAX_LEGAL_UTF32  (UTF32)0x0010FFFF
#define UNI_SUR_HIGH_START   (UTF32)0xD800
#define UNI_SUR_HIGH_END     (UTF32)0xDBFF
#define UNI_SUR_LOW_START    (UTF32)0xDC00
#define UNI_SUR_LOW_END      (UTF32)0xDFFF

#if !defined(AGXJK_FAST_TRAILING_BYTES)
static const char trailingBytesForUTF8[256] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
};
#endif

static const UTF32 offsetsFromUTF8[6] = { 0x00000000UL, 0x00003080UL, 0x000E2080UL, 0x03C82080UL, 0xFA082080UL, 0x82082080UL };
static const UTF8  firstByteMark[7]   = { 0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC };

#define AGXJK_AT_STRING_PTR(x)  (&((x)->stringBuffer.bytes.ptr[(x)->atIndex]))
#define AGXJK_END_STRING_PTR(x) (&((x)->stringBuffer.bytes.ptr[(x)->stringBuffer.bytes.length]))

static AGXJKArray          *_AGXJKArrayCreate(void **objects, NSUInteger count, BOOL mutableCollection);
static void                 _AGXJKArrayInsertObjectAtIndex(AGXJKArray *array, id newObject, NSUInteger objectIndex);
static void                 _AGXJKArrayReplaceObjectAtIndexWithObject(AGXJKArray *array, NSUInteger objectIndex, id newObject);
static void                 _AGXJKArrayRemoveObjectAtIndex(AGXJKArray *array, NSUInteger objectIndex);

static NSUInteger           _AGXJKDictionaryCapacityForCount(NSUInteger count);
static AGXJKDictionary     *_AGXJKDictionaryCreate(void **keys, NSUInteger *keyHashes, void **objects, NSUInteger count, BOOL mutableCollection);
static AGXJKHashTableEntry *_AGXJKDictionaryHashEntry(AGXJKDictionary *dictionary);
static NSUInteger           _AGXJKDictionaryCapacity(AGXJKDictionary *dictionary);
static void                 _AGXJKDictionaryResizeIfNeccessary(AGXJKDictionary *dictionary);
static void                 _AGXJKDictionaryRemoveObjectWithEntry(AGXJKDictionary *dictionary, AGXJKHashTableEntry *entry);
static void                 _AGXJKDictionaryAddObject(AGXJKDictionary *dictionary, NSUInteger keyHash, void *key, void *object);
static AGXJKHashTableEntry *_AGXJKDictionaryHashTableEntryForKey(AGXJKDictionary *dictionary, void *aKey);

static void _AGXJSONDecoderCleanup(AGXJSONDecoder *decoder);

static id _NSStringObjectFromAGXJSONString(NSString *jsonString, AGXJKParseOptionFlags parseOptionFlags, NSError **error, BOOL mutableCollection);

static void AGXjk_managedBuffer_release(AGXJKManagedBuffer *managedBuffer);
static void AGXjk_managedBuffer_setToStackBuffer(AGXJKManagedBuffer *managedBuffer, unsigned char *ptr, size_t length);
static unsigned char *AGXjk_managedBuffer_resize(AGXJKManagedBuffer *managedBuffer, size_t newSize);
static void AGXjk_objectStack_release(AGXJKObjectStack *objectStack);
static void AGXjk_objectStack_setToStackBuffer(AGXJKObjectStack *objectStack, void **objects, void **keys, CFHashCode *cfHashes, size_t count);
static int  AGXjk_objectStack_resize(AGXJKObjectStack *objectStack, size_t newCount);

static void AGXjk_error_set(AGXJKError *error, NSString *domain, NSInteger code, NSString *desc);
static void AGXjk_build_ns_error_from_jk_error(NSError **nsError, AGXJKError jkError);
static void AGXjk_build_ns_error_from_jk_error_and_location(NSError **nsError, AGXJKError jkError, size_t atIndex, size_t lineNumber);
static void AGXjk_error_release(AGXJKError *error);

static void   AGXjk_error(AGXJKParseState *parseState, NSString *format, ...);
static int    AGXjk_parse_string(AGXJKParseState *parseState);
static int    AGXjk_parse_number(AGXJKParseState *parseState);
static size_t AGXjk_parse_is_newline(AGXJKParseState *parseState, const unsigned char *atCharacterPtr);
AGXJK_STATIC_INLINE int AGXjk_parse_skip_newline(AGXJKParseState *parseState);
AGXJK_STATIC_INLINE void AGXjk_parse_skip_whitespace(AGXJKParseState *parseState);
static int    AGXjk_parse_next_token(AGXJKParseState *parseState);
static void   AGXjk_error_parse_accept_or3(AGXJKParseState *parseState, int state, NSString *or1String, NSString *or2String, NSString *or3String);
static void  *AGXjk_create_dictionary(AGXJKParseState *parseState, size_t startingObjectIndex);
static void  *AGXjk_parse_dictionary(AGXJKParseState *parseState);
static void  *AGXjk_parse_array(AGXJKParseState *parseState);
static void  *AGXjk_object_for_token(AGXJKParseState *parseState);
static void  *AGXjk_cachedObjects(AGXJKParseState *parseState);
AGXJK_STATIC_INLINE void AGXjk_cache_age(AGXJKParseState *parseState);
AGXJK_STATIC_INLINE void AGXjk_set_parsed_token(AGXJKParseState *parseState, const unsigned char *ptr, size_t length, AGXJKTokenType type, size_t advanceBy);

static void AGXjk_encode_error(AGXJKEncodeState *encodeState, NSString *format, ...);
static int AGXjk_encode_printf(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object, const char *format, ...);
static int AGXjk_encode_write(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object, const char *format);
static int AGXjk_encode_writePrettyPrintWhiteSpace(AGXJKEncodeState *encodeState);
static int AGXjk_encode_write1slow(AGXJKEncodeState *encodeState, ssize_t depthChange, const char *format);
static int AGXjk_encode_write1fast(AGXJKEncodeState *encodeState, ssize_t depthChange AGXJK_UNUSED_ARG, const char *format);
static int AGXjk_encode_writen(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object, const char *format, size_t length);
AGXJK_STATIC_INLINE AGXJKHash AGXjk_encode_object_hash(const void *objectPtr);
AGXJK_STATIC_INLINE void AGXjk_encode_updateCache(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object);
static int AGXjk_encode_add_atom_to_buffer(AGXJKEncodeState *encodeState, const void *objectPtr);

#define AGXjk_encode_write1(es, dc, f)  (AGXJK_EXPECT_F(_AGXjk_encode_prettyPrint) ? AGXjk_encode_write1slow(es, dc, f) : AGXjk_encode_write1fast(es, dc, f))

AGXJK_STATIC_INLINE size_t AGXjk_min(size_t a, size_t b);
AGXJK_STATIC_INLINE size_t AGXjk_max(size_t a, size_t b);
AGXJK_STATIC_INLINE AGXJKHash AGXjk_calculateHash(AGXJKHash currentHash, unsigned char c);

// JSONKit v1.4 used both a JKArray : NSArray and JKMutableArray : NSMutableArray, and the same for the dictionary collection type.
// However, Louis Gerbarg (via cocoa-dev) pointed out that Cocoa / Core Foundation actually implements only a single class that inherits from the
// mutable version, and keeps an ivar bit for whether or not that instance is mutable.  This means that the immutable versions of the collection
// classes receive the mutating methods, but this is handled by having those methods throw an exception when the ivar bit is set to immutable.
// We adopt the same strategy here.  It's both cleaner and gets rid of the method swizzling hackery used in JSONKit v1.4.

// This is a workaround for issue #23 https://github.com/johnezang/JSONKit/pull/23
// Basically, there seem to be a problem with using +load in static libraries on iOS.  However, __attribute__ ((constructor)) does work correctly.
// Since we do not require anything "special" that +load provides, and we can accomplish the same thing using __attribute__ ((constructor)), the +load logic was moved here.

static Class                                    _AGXJKArrayClass                           = NULL;
static size_t                                   _AGXJKArrayInstanceSize                    = 0UL;
static Class                                    _AGXJKDictionaryClass                      = NULL;
static size_t                                   _AGXJKDictionaryInstanceSize               = 0UL;

// For JSONDecoder...
static Class                                    _AGXjk_NSNumberClass                       = NULL;
static AGXNSNumberAllocImp                      _AGXjk_NSNumberAllocImp                    = NULL;
static AGXNSNumberInitWithUnsignedLongLongImp   _AGXjk_NSNumberInitWithUnsignedLongLongImp = NULL;

extern void AGXjk_collectionClassLoadTimeInitialization(void) __attribute__ ((constructor));

void AGXjk_collectionClassLoadTimeInitialization(void) {
    @autoreleasepool {
        _AGXJKArrayClass             = objc_getClass("AGXJKArray");
        _AGXJKArrayInstanceSize      = AGXjk_max(16UL, class_getInstanceSize(_AGXJKArrayClass));

        _AGXJKDictionaryClass        = objc_getClass("AGXJKDictionary");
        _AGXJKDictionaryInstanceSize = AGXjk_max(16UL, class_getInstanceSize(_AGXJKDictionaryClass));

        // For JSONDecoder...
        _AGXjk_NSNumberClass = [NSNumber class];
        _AGXjk_NSNumberAllocImp = (AGXNSNumberAllocImp)[NSNumber methodForSelector:@selector(alloc)];

        // Hacktacular.  Need to do it this way due to the nature of class clusters.
        id temp_NSNumber = [NSNumber alloc];
        _AGXjk_NSNumberInitWithUnsignedLongLongImp = (AGXNSNumberInitWithUnsignedLongLongImp)[temp_NSNumber methodForSelector:@selector(initWithUnsignedLongLong:)];
        AGX_RELEASE([temp_NSNumber init]);
        temp_NSNumber = NULL;
    }
}

#pragma mark -

@interface AGXJKArray : NSMutableArray <NSCopying, NSMutableCopying, NSFastEnumeration> {
    id __AGX_STRONG *   objects;
    NSUInteger          count, capacity, mutations;
}
@end

@implementation AGXJKArray

+ (id)allocWithZone:(NSZone *)zone {
#pragma unused(zone)
    [NSException raise:NSInvalidArgumentException format:@"*** - [%@ %@]: The %@ class is private to JSONKit and should not be used in this fashion.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSStringFromClass([self class])];
    return(NULL);
}

static AGXJKArray *_AGXJKArrayCreate(void **objects, NSUInteger count, BOOL mutableCollection) {
    NSCParameterAssert((objects != NULL) && (_AGXJKArrayClass != NULL) && (_AGXJKArrayInstanceSize > 0UL));
    AGXJKArray *array = NULL;
    if (AGXJK_EXPECT_T((array = (AGX_BRIDGE_TRANSFER AGXJKArray *)calloc(1UL, _AGXJKArrayInstanceSize)) != NULL)) { // Directly allocate the AGXJKArray instance via calloc.
        object_setClass(array, _AGXJKArrayClass);
        if ((array = [array init]) == NULL) { return(NULL); }
        array->capacity = count;
        array->count    = count;
        if (AGXJK_EXPECT_F((array->objects = (id __AGX_STRONG *)malloc(sizeof(id) * array->capacity)) == NULL))
        { AGX_JUST_AUTORELEASE(array); return(NULL); }
        memcpy((void*)array->objects, objects, array->capacity * sizeof(id));
        array->mutations = (mutableCollection == NO) ? 0UL : 1UL;
    }
    return(array);
}

// Note: The caller is responsible for -retaining the object that is to be added.
static void _AGXJKArrayInsertObjectAtIndex(AGXJKArray *array, id newObject, NSUInteger objectIndex) {
    NSCParameterAssert((array != NULL) && (array->objects != NULL) && (array->count <= array->capacity) && (objectIndex <= array->count) && (newObject != NULL));
    if (!((array != NULL) && (array->objects != NULL) && (objectIndex <= array->count) && (newObject != NULL)))
    { AGX_JUST_AUTORELEASE(newObject); return; }
    if ((array->count + 1UL) >= array->capacity) {
        id __AGX_STRONG *newObjects = NULL;
        if ((newObjects = (id __AGX_STRONG *)realloc(array->objects, sizeof(id) * (array->capacity + 16UL))) == NULL) { [NSException raise:NSMallocException format:@"Unable to resize objects array."]; }
        array->objects = newObjects;
        array->capacity += 16UL;
        memset(&array->objects[array->count], 0, sizeof(id) * (array->capacity - array->count));
    }
    array->count++;
    if ((objectIndex + 1UL) < array->count) { memmove((void*)&array->objects[objectIndex + 1UL], (void*)&array->objects[objectIndex], sizeof(id) * ((array->count - 1UL) - objectIndex)); array->objects[objectIndex] = NULL; }
    array->objects[objectIndex] = newObject;
}

// Note: The caller is responsible for -retaining the object that is to be added.
static void _AGXJKArrayReplaceObjectAtIndexWithObject(AGXJKArray *array, NSUInteger objectIndex, id newObject) {
    NSCParameterAssert((array != NULL) && (array->objects != NULL) && (array->count <= array->capacity) && (objectIndex < array->count) && (array->objects[objectIndex] != NULL) && (newObject != NULL));
    if (!((array != NULL) && (array->objects != NULL) && (objectIndex < array->count) && (array->objects[objectIndex] != NULL) && (newObject != NULL))) { AGX_JUST_AUTORELEASE(newObject); return; }
    CFRelease((AGX_BRIDGE CFTypeRef)array->objects[objectIndex]);
    array->objects[objectIndex] = NULL;
    array->objects[objectIndex] = newObject;
}

static void _AGXJKArrayRemoveObjectAtIndex(AGXJKArray *array, NSUInteger objectIndex) {
    NSCParameterAssert((array != NULL) && (array->objects != NULL) && (array->count > 0UL) && (array->count <= array->capacity) && (objectIndex < array->count) && (array->objects[objectIndex] != NULL));
    if (!((array != NULL) && (array->objects != NULL) && (array->count > 0UL) && (array->count <= array->capacity) && (objectIndex < array->count) && (array->objects[objectIndex] != NULL))) { return; }
    CFRelease((AGX_BRIDGE CFTypeRef)array->objects[objectIndex]);
    array->objects[objectIndex] = NULL;
    if ((objectIndex + 1UL) < array->count) { memmove((void*)&array->objects[objectIndex], (void*)&array->objects[objectIndex + 1UL], sizeof(id) * ((array->count - 1UL) - objectIndex)); array->objects[array->count - 1UL] = NULL; }
    array->count--;
}

- (void)dealloc {
    if (AGXJK_EXPECT_T(objects != NULL)) {
        NSUInteger atObject = 0UL;
        for(atObject = 0UL; atObject < count; atObject++) { if (AGXJK_EXPECT_T(objects[atObject] != NULL))
        { CFRelease((AGX_BRIDGE CFTypeRef)objects[atObject]); objects[atObject] = NULL; } }
        free(objects); objects = NULL;
    }
    AGX_SUPER_DEALLOC;
}

- (NSUInteger)count {
    NSParameterAssert((objects != NULL) && (count <= capacity));
    return(count);
}

- (void)getObjects:(id __unsafe_unretained [])objectsPtr range:(NSRange)range {
    NSParameterAssert((objects != NULL) && (count <= capacity));
    if ((objectsPtr     == NULL)  && (NSMaxRange(range) > 0UL))   { [NSException raise:NSRangeException format:@"*** -[%@ %@]: pointer to objects array is NULL but range length is %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)NSMaxRange(range)];        }
    if ((range.location >  count) || (NSMaxRange(range) > count)) { [NSException raise:NSRangeException format:@"*** -[%@ %@]: index (%lu) beyond bounds (%lu)",                          NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)NSMaxRange(range), (unsigned long)count]; }
#ifndef __clang_analyzer__
    memcpy(objectsPtr, (void*)objects + range.location, range.length * sizeof(id));
#endif
}

- (id)objectAtIndex:(NSUInteger)objectIndex {
    if (objectIndex >= count) { [NSException raise:NSRangeException format:@"*** -[%@ %@]: index (%lu) beyond bounds (%lu)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)objectIndex, (unsigned long)count]; }
    NSParameterAssert((objects != NULL) && (count <= capacity) && (objects[objectIndex] != NULL));
    return(objects[objectIndex]);
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    NSParameterAssert((state != NULL) && (stackbuf != NULL) && (len > 0UL) && (objects != NULL) && (count <= capacity));
    if (AGXJK_EXPECT_F(state->state == 0UL)) { state->mutationsPtr = (unsigned long *)&mutations; state->itemsPtr = stackbuf; }
    if (AGXJK_EXPECT_F(state->state >= count)) { return(0UL); }

    NSUInteger enumeratedCount  = 0UL;
    while(AGXJK_EXPECT_T(enumeratedCount < len) && AGXJK_EXPECT_T(state->state < count))
    { NSParameterAssert(objects[state->state] != NULL);
        stackbuf[enumeratedCount++] = objects[state->state++]; }
    return(enumeratedCount);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)objectIndex {
    if (mutations   == 0UL)   { [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: mutating method sent to immutable object", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    if (anObject    == NULL)  { [NSException raise:NSInvalidArgumentException       format:@"*** -[%@ %@]: attempt to insert nil",                    NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    if (objectIndex >  count) { [NSException raise:NSRangeException                 format:@"*** -[%@ %@]: index (%lu) beyond bounds (%lu)",          NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)objectIndex, (unsigned long)(count + 1UL)]; }
#ifdef __clang_analyzer__
    AGX_RETAIN(anObject); // Stupid clang analyzer...  Issue #19.
#else
    anObject = AGX_RETAIN(anObject);
#endif
    _AGXJKArrayInsertObjectAtIndex(self, anObject, objectIndex);
    mutations = (mutations == NSUIntegerMax) ? 1UL : mutations + 1UL;
}

- (void)removeObjectAtIndex:(NSUInteger)objectIndex {
    if (mutations   == 0UL)   { [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: mutating method sent to immutable object", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    if (objectIndex >= count) { [NSException raise:NSRangeException                 format:@"*** -[%@ %@]: index (%lu) beyond bounds (%lu)",          NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)objectIndex, (unsigned long)count]; }
    _AGXJKArrayRemoveObjectAtIndex(self, objectIndex);
    mutations = (mutations == NSUIntegerMax) ? 1UL : mutations + 1UL;
}

- (void)replaceObjectAtIndex:(NSUInteger)objectIndex withObject:(id)anObject {
    if (mutations   == 0UL)   { [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: mutating method sent to immutable object", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    if (anObject    == NULL)  { [NSException raise:NSInvalidArgumentException       format:@"*** -[%@ %@]: attempt to insert nil",                    NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    if (objectIndex >= count) { [NSException raise:NSRangeException                 format:@"*** -[%@ %@]: index (%lu) beyond bounds (%lu)",          NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)objectIndex, (unsigned long)count]; }
#ifdef __clang_analyzer__
    AGX_RETAIN(anObject); // Stupid clang analyzer...  Issue #19.
#else
    anObject = AGX_RETAIN(anObject);
#endif
    _AGXJKArrayReplaceObjectAtIndexWithObject(self, objectIndex, anObject);
    mutations = (mutations == NSUIntegerMax) ? 1UL : mutations + 1UL;
}

- (id)copyWithZone:(NSZone *)zone {
    NSParameterAssert((objects != NULL) && (count <= capacity));
    return((mutations == 0UL) ? AGX_RETAIN(self) : [(NSArray *)[NSArray allocWithZone:zone] initWithObjects:objects count:count]);
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSParameterAssert((objects != NULL) && (count <= capacity));
    return([(NSMutableArray *)[NSMutableArray allocWithZone:zone] initWithObjects:objects count:count]);
}

@end

#pragma mark -

@interface AGXJKDictionaryEnumerator : NSEnumerator {
    id         collection;
    NSUInteger nextObject;
}

- (id)initWithJKDictionary:(AGXJKDictionary *)initDictionary;
- (NSArray *)allObjects;
- (id)nextObject;

@end

@implementation AGXJKDictionaryEnumerator

- (id)initWithJKDictionary:(AGXJKDictionary *)initDictionary {
    NSParameterAssert(initDictionary != NULL);
    if ((self = [super init]) == NULL) { return(NULL); }
    if ((collection = AGX_RETAIN(initDictionary)) == NULL)
    { AGX_JUST_AUTORELEASE(self); return(NULL); }
    return(self);
}

- (void)dealloc {
    if (collection != NULL) { AGX_RELEASE(collection); collection = NULL; }
    AGX_SUPER_DEALLOC;
}

- (NSArray *)allObjects {
    NSParameterAssert(collection != NULL);
    NSUInteger count = [(NSDictionary *)collection count], atObject = 0UL;
    id         objects[count];

    while((objects[atObject] = [self nextObject]) != NULL)
    { NSParameterAssert(atObject < count); atObject++; }

    return([NSArray arrayWithObjects:objects count:atObject]);
}

- (id)nextObject {
    NSParameterAssert((collection != NULL) && (_AGXJKDictionaryHashEntry(collection) != NULL));
    AGXJKHashTableEntry *entry     = _AGXJKDictionaryHashEntry(collection);
    NSUInteger        capacity     = _AGXJKDictionaryCapacity(collection);
    id                returnObject = NULL;

    if (entry != NULL) { while((nextObject < capacity) && ((returnObject = (AGX_BRIDGE id)(entry[nextObject++].key))
                                                           == NULL)) { /* ... */ } }
    return(returnObject);
}

@end

#pragma mark -
@interface AGXJKDictionary : NSMutableDictionary <NSCopying, NSMutableCopying, NSFastEnumeration> {
    NSUInteger count, capacity, mutations;
    AGXJKHashTableEntry *entry;
}
@end

@implementation AGXJKDictionary

+ (id)allocWithZone:(NSZone *)zone {
#pragma unused(zone)
    [NSException raise:NSInvalidArgumentException format:@"*** - [%@ %@]: The %@ class is private to JSONKit and should not be used in this fashion.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSStringFromClass([self class])];
    return(NULL);
}

// These values are taken from Core Foundation CF-550 CFBasicHash.m.  As a bonus, they align very well with our JKHashTableEntry struct too.
static const NSUInteger AGXjk_dictionaryCapacities[] = {
    0UL, 3UL, 7UL, 13UL, 23UL, 41UL, 71UL, 127UL, 191UL, 251UL, 383UL, 631UL, 1087UL, 1723UL,
    2803UL, 4523UL, 7351UL, 11959UL, 19447UL, 31231UL, 50683UL, 81919UL, 132607UL,
    214519UL, 346607UL, 561109UL, 907759UL, 1468927UL, 2376191UL, 3845119UL,
    6221311UL, 10066421UL, 16287743UL, 26354171UL, 42641881UL, 68996069UL,
    111638519UL, 180634607UL, 292272623UL, 472907251UL
};

static NSUInteger _AGXJKDictionaryCapacityForCount(NSUInteger count) {
    NSUInteger bottom = 0UL, top = sizeof(AGXjk_dictionaryCapacities) / sizeof(NSUInteger), mid = 0UL, tableSize = (NSUInteger)lround(floor(((double)count) * 1.33));
    while(top > bottom) { mid = (top + bottom) / 2UL; if (AGXjk_dictionaryCapacities[mid] < tableSize) { bottom = mid + 1UL; } else { top = mid; } }
    return(AGXjk_dictionaryCapacities[bottom]);
}

static void _AGXJKDictionaryResizeIfNeccessary(AGXJKDictionary *dictionary) {
    NSCParameterAssert((dictionary != NULL) && (dictionary->entry != NULL) && (dictionary->count <= dictionary->capacity));

    NSUInteger capacityForCount = 0UL;
    if (dictionary->capacity < (capacityForCount = _AGXJKDictionaryCapacityForCount(dictionary->count + 1UL))) { // resize
        NSUInteger        oldCapacity = dictionary->capacity;
#ifndef NS_BLOCK_ASSERTIONS
        NSUInteger oldCount = dictionary->count;
#endif
        AGXJKHashTableEntry *oldEntry    = dictionary->entry;
        if (AGXJK_EXPECT_F((dictionary->entry = (AGXJKHashTableEntry *)calloc(1UL, sizeof(AGXJKHashTableEntry) * capacityForCount)) == NULL)) { [NSException raise:NSMallocException format:@"Unable to allocate memory for hash table."]; }
        dictionary->capacity = capacityForCount;
        dictionary->count    = 0UL;

        NSUInteger idx = 0UL;
        for(idx = 0UL; idx < oldCapacity; idx++) { if (oldEntry[idx].key != NULL) { _AGXJKDictionaryAddObject(dictionary, oldEntry[idx].keyHash, oldEntry[idx].key, oldEntry[idx].object); oldEntry[idx].keyHash = 0UL; oldEntry[idx].key = NULL; oldEntry[idx].object = NULL; } }
        NSCParameterAssert((oldCount == dictionary->count));
        free(oldEntry); oldEntry = NULL;
    }
}

static AGXJKDictionary *_AGXJKDictionaryCreate(void **keys, NSUInteger *keyHashes, void **objects, NSUInteger count, BOOL mutableCollection) {
    NSCParameterAssert((keys != NULL) && (keyHashes != NULL) && (objects != NULL) && (_AGXJKDictionaryClass != NULL) && (_AGXJKDictionaryInstanceSize > 0UL));
    AGXJKDictionary *dictionary = NULL;
    if (AGXJK_EXPECT_T((dictionary = (AGX_BRIDGE_TRANSFER AGXJKDictionary *)calloc(1UL, _AGXJKDictionaryInstanceSize)) != NULL)) { // Directly allocate the JKDictionary instance via calloc.
        object_setClass(dictionary, _AGXJKDictionaryClass);
        if ((dictionary = [dictionary init]) == NULL) { return(NULL); }
        dictionary->capacity = _AGXJKDictionaryCapacityForCount(count);
        dictionary->count    = 0UL;

        if (AGXJK_EXPECT_F((dictionary->entry = (AGXJKHashTableEntry *)calloc(1UL, sizeof(AGXJKHashTableEntry) * dictionary->capacity)) == NULL)) { AGX_JUST_AUTORELEASE(dictionary); return(NULL); }

        NSUInteger idx = 0UL;
        for(idx = 0UL; idx < count; idx++) { _AGXJKDictionaryAddObject(dictionary, keyHashes[idx], keys[idx], objects[idx]); }

        dictionary->mutations = (mutableCollection == NO) ? 0UL : 1UL;
    }
    return(dictionary);
}

- (void)dealloc {
    if (AGXJK_EXPECT_T(entry != NULL)) {
        NSUInteger atEntry = 0UL;
        for(atEntry = 0UL; atEntry < capacity; atEntry++) {
            if (AGXJK_EXPECT_T(entry[atEntry].key    != NULL)) { CFRelease(entry[atEntry].key);    entry[atEntry].key    = NULL; }
            if (AGXJK_EXPECT_T(entry[atEntry].object != NULL)) { CFRelease(entry[atEntry].object); entry[atEntry].object = NULL; }
        }

        free(entry); entry = NULL;
    }
    AGX_SUPER_DEALLOC;
}

static AGXJKHashTableEntry *_AGXJKDictionaryHashEntry(AGXJKDictionary *dictionary) {
    NSCParameterAssert(dictionary != NULL);
    return(dictionary->entry);
}

static NSUInteger _AGXJKDictionaryCapacity(AGXJKDictionary *dictionary) {
    NSCParameterAssert(dictionary != NULL);
    return(dictionary->capacity);
}

static void _AGXJKDictionaryRemoveObjectWithEntry(AGXJKDictionary *dictionary, AGXJKHashTableEntry *entry) {
    NSCParameterAssert((dictionary != NULL) && (entry != NULL) && (entry->key != NULL) && (entry->object != NULL) && (dictionary->count > 0UL) && (dictionary->count <= dictionary->capacity));
    CFRelease(entry->key);    entry->key    = NULL;
    CFRelease(entry->object); entry->object = NULL;
    entry->keyHash = 0UL;
    dictionary->count--;
    // In order for certain invariants that are used to speed up the search for a particular key, we need to "re-add" all the entries in the hash table following this entry until we hit a NULL entry.
    NSUInteger removeIdx = entry - dictionary->entry, idx = 0UL;
    NSCParameterAssert((removeIdx < dictionary->capacity));
    for(idx = 0UL; idx < dictionary->capacity; idx++) {
        NSUInteger entryIdx = (removeIdx + idx + 1UL) % dictionary->capacity;
        AGXJKHashTableEntry *atEntry = &dictionary->entry[entryIdx];
        if (atEntry->key == NULL) { break; }
        NSUInteger keyHash = atEntry->keyHash;
        void *key = atEntry->key, *object = atEntry->object;
        NSCParameterAssert(object != NULL);
        atEntry->keyHash = 0UL;
        atEntry->key     = NULL;
        atEntry->object  = NULL;
        NSUInteger addKeyEntry = keyHash % dictionary->capacity, addIdx = 0UL;
        for(addIdx = 0UL; addIdx < dictionary->capacity; addIdx++) {
            AGXJKHashTableEntry *atAddEntry = &dictionary->entry[((addKeyEntry + addIdx) % dictionary->capacity)];
            if (AGXJK_EXPECT_T(atAddEntry->key == NULL)) { NSCParameterAssert((atAddEntry->keyHash == 0UL) && (atAddEntry->object == NULL)); atAddEntry->key = key; atAddEntry->object = object; atAddEntry->keyHash = keyHash; break; }
        }
    }
}

static void _AGXJKDictionaryAddObject(AGXJKDictionary *dictionary, NSUInteger keyHash, void *key, void *object) {
    NSCParameterAssert((dictionary != NULL) && (key != NULL) && (object != NULL) && (dictionary->count < dictionary->capacity) && (dictionary->entry != NULL));
    NSUInteger keyEntry = keyHash % dictionary->capacity, idx = 0UL;
    for(idx = 0UL; idx < dictionary->capacity; idx++) {
        NSUInteger entryIdx = (keyEntry + idx) % dictionary->capacity;
        AGXJKHashTableEntry *atEntry = &dictionary->entry[entryIdx];
        if (AGXJK_EXPECT_F(atEntry->keyHash == keyHash) && AGXJK_EXPECT_T(atEntry->key != NULL) && (AGXJK_EXPECT_F(key == atEntry->key) || AGXJK_EXPECT_F(CFEqual(atEntry->key, key)))) { _AGXJKDictionaryRemoveObjectWithEntry(dictionary, atEntry); }
        if (AGXJK_EXPECT_T(atEntry->key == NULL)) { NSCParameterAssert((atEntry->keyHash == 0UL) && (atEntry->object == NULL)); atEntry->key = key; atEntry->object = object; atEntry->keyHash = keyHash; dictionary->count++; return; }
    }

    // We should never get here.  If we do, we -release the key / object because it's our responsibility.
    CFRelease(key);
    CFRelease(object);
}

- (NSUInteger)count {
    return(count);
}

static AGXJKHashTableEntry *_AGXJKDictionaryHashTableEntryForKey(AGXJKDictionary *dictionary, void *aKey) {
    NSCParameterAssert((dictionary != NULL) && (dictionary->entry != NULL) && (dictionary->count <= dictionary->capacity));
    if ((aKey == NULL) || (dictionary->capacity == 0UL)) { return(NULL); }
    NSUInteger        keyHash = CFHash(aKey), keyEntry = (keyHash % dictionary->capacity), idx = 0UL;
    AGXJKHashTableEntry *atEntry = NULL;
    for(idx = 0UL; idx < dictionary->capacity; idx++) {
        atEntry = &dictionary->entry[(keyEntry + idx) % dictionary->capacity];
        if (AGXJK_EXPECT_T(atEntry->keyHash == keyHash) && AGXJK_EXPECT_T(atEntry->key != NULL) && ((atEntry->key == aKey) || CFEqual(atEntry->key, aKey))) { NSCParameterAssert(atEntry->object != NULL); return(atEntry); break; }
        if (AGXJK_EXPECT_F(atEntry->key == NULL)) { NSCParameterAssert(atEntry->object == NULL); return(NULL); break; } // If the key was in the table, we would have found it by now.
    }
    return(NULL);
}

- (id)objectForKey:(id)aKey {
    NSParameterAssert((entry != NULL) && (count <= capacity));
    AGXJKHashTableEntry *entryForKey = _AGXJKDictionaryHashTableEntryForKey(self, (AGX_BRIDGE void *)aKey);
    return(AGX_BRIDGE id _Nullable)((entryForKey != NULL) ? entryForKey->object : NULL);
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys {
    NSParameterAssert((entry != NULL) && (count <= capacity));
    NSUInteger atEntry = 0UL; NSUInteger arrayIdx = 0UL;
    for(atEntry = 0UL; atEntry < capacity; atEntry++) {
        if (AGXJK_EXPECT_T(entry[atEntry].key != NULL)) {
            NSCParameterAssert((entry[atEntry].object != NULL) && (arrayIdx < count));
            if (AGXJK_EXPECT_T(keys    != NULL)) { keys[arrayIdx]    = (AGX_BRIDGE id)entry[atEntry].key;    }
            if (AGXJK_EXPECT_T(objects != NULL)) { objects[arrayIdx] = (AGX_BRIDGE id)entry[atEntry].object; }
            arrayIdx++;
        }
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    NSParameterAssert((state != NULL) && (stackbuf != NULL) && (len > 0UL) && (entry != NULL) && (count <= capacity));
    if (AGXJK_EXPECT_F(state->state == 0UL))      { state->mutationsPtr = (unsigned long *)&mutations; state->itemsPtr = stackbuf; }
    if (AGXJK_EXPECT_F(state->state >= capacity)) { return(0UL); }

    NSUInteger enumeratedCount  = 0UL;
    while(AGXJK_EXPECT_T(enumeratedCount < len) && AGXJK_EXPECT_T(state->state < capacity)) { if (AGXJK_EXPECT_T(entry[state->state].key != NULL)) { stackbuf[enumeratedCount++] = (AGX_BRIDGE id)entry[state->state].key; } state->state++; }
    return(enumeratedCount);
}

- (NSEnumerator *)keyEnumerator {
    return(AGX_AUTORELEASE([[AGXJKDictionaryEnumerator alloc] initWithJKDictionary:self]));
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    if (mutations == 0UL)  { [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: mutating method sent to immutable object", NSStringFromClass([self class]), NSStringFromSelector(_cmd)];       }
    if (aKey      == NULL) { [NSException raise:NSInvalidArgumentException       format:@"*** -[%@ %@]: attempt to insert nil key",                NSStringFromClass([self class]), NSStringFromSelector(_cmd)];       }
    if (anObject  == NULL) { [NSException raise:NSInvalidArgumentException       format:@"*** -[%@ %@]: attempt to insert nil value (key: %@)",    NSStringFromClass([self class]), NSStringFromSelector(_cmd), aKey]; }

    _AGXJKDictionaryResizeIfNeccessary(self);
#ifndef __clang_analyzer__
    aKey     = [aKey     copy];      // Why on earth would clang complain that this -copy "might leak",
    anObject = AGX_RETAIN(anObject); // but this -retain doesn't!?
#endif
    _AGXJKDictionaryAddObject(self, CFHash((AGX_BRIDGE CFTypeRef)(aKey)),
                              (AGX_BRIDGE void *)aKey, (AGX_BRIDGE void *)anObject);
    mutations = (mutations == NSUIntegerMax) ? 1UL : mutations + 1UL;
}

- (void)removeObjectForKey:(id)aKey {
    if (mutations == 0UL)  { [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: mutating method sent to immutable object", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    if (aKey      == NULL) { [NSException raise:NSInvalidArgumentException       format:@"*** -[%@ %@]: attempt to remove nil key",                NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; }
    AGXJKHashTableEntry *entryForKey = _AGXJKDictionaryHashTableEntryForKey(self, (AGX_BRIDGE void *)aKey);
    if (entryForKey != NULL) {
        _AGXJKDictionaryRemoveObjectWithEntry(self, entryForKey);
        mutations = (mutations == NSUIntegerMax) ? 1UL : mutations + 1UL;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    NSParameterAssert((entry != NULL) && (count <= capacity));
    return((mutations == 0UL) ? AGX_RETAIN(self) : [[NSDictionary allocWithZone:zone] initWithDictionary:self]);
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSParameterAssert((entry != NULL) && (count <= capacity));
    return([[NSMutableDictionary allocWithZone:zone] initWithDictionary:self]);
}

@end

#pragma mark -

AGXJK_STATIC_INLINE size_t      AGXjk_min(size_t a, size_t b) { return((a < b) ? a : b); }
AGXJK_STATIC_INLINE size_t      AGXjk_max(size_t a, size_t b) { return((a > b) ? a : b); }
AGXJK_STATIC_INLINE AGXJKHash   AGXjk_calculateHash(AGXJKHash currentHash, unsigned char c)
{ return((((currentHash << 5) + currentHash) + (c - 29)) ^ (currentHash >> 19)); }

static void AGXjk_error_set(AGXJKError *error, NSString *domain, NSInteger code, NSString *desc) {
    if (error->domain != NULL) return;
    error->domain = (AGX_BRIDGE_RETAIN CFStringRef)domain;
    error->code = code;
    error->desc = (AGX_BRIDGE_RETAIN CFStringRef)desc;
}

static void AGXjk_build_ns_error_from_jk_error(NSError **nsError, AGXJKError jkError) {
    if ((nsError == NULL) || (jkError.domain == NULL)) return;
    *nsError = [NSError errorWithDomain:(AGX_BRIDGE NSString *)(jkError.domain) code:jkError.code                               userInfo:@{NSLocalizedDescriptionKey:(AGX_BRIDGE NSString *)(jkError.desc)}];
}

static void AGXjk_build_ns_error_from_jk_error_and_location(NSError **nsError, AGXJKError jkError, size_t atIndex, size_t lineNumber) {
    if ((nsError == NULL) || (jkError.domain == NULL)) return;
    *nsError = [NSError errorWithDomain:(AGX_BRIDGE NSString *)(jkError.domain) code:jkError.code
                               userInfo:@{NSLocalizedDescriptionKey:(AGX_BRIDGE NSString *)(jkError.desc),
                                          @"JKAtIndexKey":@(atIndex), @"JKLineNumberKey":@(lineNumber)}];
}

static void AGXjk_error_release(AGXJKError *error) {
    if (error->domain != NULL) { AGX_CFRelease(error->domain); error->domain = NULL; }
    error->code = 0L;
    if (error->desc != NULL) { AGX_CFRelease(error->desc); error->desc = NULL; }
}

static void AGXjk_error(AGXJKParseState *parseState, NSString *format, ...) {
    NSCParameterAssert((parseState != NULL) && (format != NULL));

    va_list varArgsList;
    va_start(varArgsList, format);
    NSString *formatString = AGX_AUTORELEASE([[NSString alloc] initWithFormat:format arguments:varArgsList]);
    va_end(varArgsList);

    AGXjk_error_set(&parseState->error, @"JKErrorDomain", -1L, formatString);
}

#pragma mark -
#pragma mark Buffer and Object Stack management functions

static void AGXjk_managedBuffer_release(AGXJKManagedBuffer *managedBuffer) {
    if ((managedBuffer->flags & AGXJKManagedBufferMustFree)) {
        if (managedBuffer->bytes.ptr != NULL) { free(managedBuffer->bytes.ptr); managedBuffer->bytes.ptr = NULL; }
        managedBuffer->flags &= ~AGXJKManagedBufferMustFree;
    }

    managedBuffer->bytes.ptr     = NULL;
    managedBuffer->bytes.length  = 0UL;
    managedBuffer->flags        &= ~AGXJKManagedBufferLocationMask;
}

static void AGXjk_managedBuffer_setToStackBuffer(AGXJKManagedBuffer *managedBuffer, unsigned char *ptr, size_t length) {
    AGXjk_managedBuffer_release(managedBuffer);
    managedBuffer->bytes.ptr     = ptr;
    managedBuffer->bytes.length  = length;
    managedBuffer->flags         = (managedBuffer->flags & ~AGXJKManagedBufferLocationMask) | AGXJKManagedBufferOnStack;
}

static unsigned char *AGXjk_managedBuffer_resize(AGXJKManagedBuffer *managedBuffer, size_t newSize) {
    size_t roundedUpNewSize = newSize;

    if (managedBuffer->roundSizeUpToMultipleOf > 0UL) { roundedUpNewSize = newSize + ((managedBuffer->roundSizeUpToMultipleOf - (newSize % managedBuffer->roundSizeUpToMultipleOf)) % managedBuffer->roundSizeUpToMultipleOf); }

    if ((roundedUpNewSize != managedBuffer->bytes.length) && (roundedUpNewSize > managedBuffer->bytes.length)) {
        if ((managedBuffer->flags & AGXJKManagedBufferLocationMask) == AGXJKManagedBufferOnStack) {
            NSCParameterAssert((managedBuffer->flags & AGXJKManagedBufferMustFree) == 0);
            unsigned char *newBuffer = NULL, *oldBuffer = managedBuffer->bytes.ptr;

            if ((newBuffer = (unsigned char *)malloc(roundedUpNewSize)) == NULL) { return(NULL); }
            memcpy(newBuffer, oldBuffer, AGXjk_min(managedBuffer->bytes.length, roundedUpNewSize));
            managedBuffer->flags        = (managedBuffer->flags & ~AGXJKManagedBufferLocationMask) | (AGXJKManagedBufferOnHeap | AGXJKManagedBufferMustFree);
            managedBuffer->bytes.ptr    = newBuffer;
            managedBuffer->bytes.length = roundedUpNewSize;
        } else {
            NSCParameterAssert(((managedBuffer->flags & AGXJKManagedBufferMustFree) != 0) && ((managedBuffer->flags & AGXJKManagedBufferLocationMask) == AGXJKManagedBufferOnHeap));
            if ((managedBuffer->bytes.ptr = (unsigned char *)reallocf(managedBuffer->bytes.ptr, roundedUpNewSize)) == NULL) { return(NULL); }
            managedBuffer->bytes.length = roundedUpNewSize;
        }
    }
    return(managedBuffer->bytes.ptr);
}

static void AGXjk_objectStack_release(AGXJKObjectStack *objectStack) {
    NSCParameterAssert(objectStack != NULL);

    NSCParameterAssert(objectStack->index <= objectStack->count);
    size_t atIndex = 0UL;
    for(atIndex = 0UL; atIndex < objectStack->index; atIndex++) {
        if (objectStack->objects[atIndex] != NULL) { CFRelease(objectStack->objects[atIndex]); objectStack->objects[atIndex] = NULL; }
        if (objectStack->keys[atIndex]    != NULL) { CFRelease(objectStack->keys[atIndex]);    objectStack->keys[atIndex]    = NULL; }
    }
    objectStack->index = 0UL;

    if (objectStack->flags & AGXJKObjectStackMustFree) {
        NSCParameterAssert((objectStack->flags & AGXJKObjectStackLocationMask) == AGXJKObjectStackOnHeap);
        if (objectStack->objects  != NULL) { free(objectStack->objects);  objectStack->objects  = NULL; }
        if (objectStack->keys     != NULL) { free(objectStack->keys);     objectStack->keys     = NULL; }
        if (objectStack->cfHashes != NULL) { free(objectStack->cfHashes); objectStack->cfHashes = NULL; }
        objectStack->flags &= ~AGXJKObjectStackMustFree;
    }

    objectStack->objects  = NULL;
    objectStack->keys     = NULL;
    objectStack->cfHashes = NULL;

    objectStack->count    = 0UL;
    objectStack->flags   &= ~AGXJKObjectStackLocationMask;
}

static void AGXjk_objectStack_setToStackBuffer(AGXJKObjectStack *objectStack, void **objects, void **keys, CFHashCode *cfHashes, size_t count) {
    NSCParameterAssert((objectStack != NULL) && (objects != NULL) && (keys != NULL) && (cfHashes != NULL) && (count > 0UL));
    AGXjk_objectStack_release(objectStack);
    objectStack->objects  = objects;
    objectStack->keys     = keys;
    objectStack->cfHashes = cfHashes;
    objectStack->count    = count;
    objectStack->flags    = (objectStack->flags & ~AGXJKObjectStackLocationMask) | AGXJKObjectStackOnStack;
#ifndef NS_BLOCK_ASSERTIONS
    size_t idx;
    for(idx = 0UL; idx < objectStack->count; idx++) { objectStack->objects[idx] = NULL; objectStack->keys[idx] = NULL; objectStack->cfHashes[idx] = 0UL; }
#endif
}

static int AGXjk_objectStack_resize(AGXJKObjectStack *objectStack, size_t newCount) {
    size_t roundedUpNewCount = newCount;
    int    returnCode = 0;

    void       **newObjects  = NULL, **newKeys = NULL;
    CFHashCode  *newCFHashes = NULL;

    if (objectStack->roundSizeUpToMultipleOf > 0UL) { roundedUpNewCount = newCount + ((objectStack->roundSizeUpToMultipleOf - (newCount % objectStack->roundSizeUpToMultipleOf)) % objectStack->roundSizeUpToMultipleOf); }

    if ((roundedUpNewCount != objectStack->count) && (roundedUpNewCount > objectStack->count)) {
        if ((objectStack->flags & AGXJKObjectStackLocationMask) == AGXJKObjectStackOnStack) {
            NSCParameterAssert((objectStack->flags & AGXJKObjectStackMustFree) == 0);

            if ((newObjects  = (void **     )calloc(1UL, roundedUpNewCount * sizeof(void *    ))) == NULL) { returnCode = 1; goto errorExit; }
            memcpy(newObjects, objectStack->objects,   AGXjk_min(objectStack->count, roundedUpNewCount) * sizeof(void *));
            if ((newKeys     = (void **     )calloc(1UL, roundedUpNewCount * sizeof(void *    ))) == NULL) { returnCode = 1; goto errorExit; }
            memcpy(newKeys,     objectStack->keys,     AGXjk_min(objectStack->count, roundedUpNewCount) * sizeof(void *));

            if ((newCFHashes = (CFHashCode *)calloc(1UL, roundedUpNewCount * sizeof(CFHashCode))) == NULL) { returnCode = 1; goto errorExit; }
            memcpy(newCFHashes, objectStack->cfHashes, AGXjk_min(objectStack->count, roundedUpNewCount) * sizeof(CFHashCode));

            objectStack->flags    = (objectStack->flags & ~AGXJKObjectStackLocationMask) | (AGXJKObjectStackOnHeap | AGXJKObjectStackMustFree);
            objectStack->objects  = newObjects;  newObjects  = NULL;
            objectStack->keys     = newKeys;     newKeys     = NULL;
            objectStack->cfHashes = newCFHashes; newCFHashes = NULL;
            objectStack->count    = roundedUpNewCount;
        } else {
            NSCParameterAssert(((objectStack->flags & AGXJKObjectStackMustFree) != 0) && ((objectStack->flags & AGXJKObjectStackLocationMask) == AGXJKObjectStackOnHeap));
            if ((newObjects  = (void  **    )realloc(objectStack->objects,  roundedUpNewCount * sizeof(void *    ))) != NULL) { objectStack->objects  = newObjects;  newObjects  = NULL; } else { returnCode = 1; goto errorExit; }
            if ((newKeys     = (void  **    )realloc(objectStack->keys,     roundedUpNewCount * sizeof(void *    ))) != NULL) { objectStack->keys     = newKeys;     newKeys     = NULL; } else { returnCode = 1; goto errorExit; }
            if ((newCFHashes = (CFHashCode *)realloc(objectStack->cfHashes, roundedUpNewCount * sizeof(CFHashCode))) != NULL) { objectStack->cfHashes = newCFHashes; newCFHashes = NULL; } else { returnCode = 1; goto errorExit; }

#ifndef NS_BLOCK_ASSERTIONS
            size_t idx;
            for(idx = objectStack->count; idx < roundedUpNewCount; idx++) { objectStack->objects[idx] = NULL; objectStack->keys[idx] = NULL; objectStack->cfHashes[idx] = 0UL; }
#endif
            objectStack->count = roundedUpNewCount;
        }
    }

errorExit:
    if (newObjects  != NULL) { free(newObjects);  newObjects  = NULL; }
    if (newKeys     != NULL) { free(newKeys);     newKeys     = NULL; }
    if (newCFHashes != NULL) { free(newCFHashes); newCFHashes = NULL; }
    return(returnCode);
}

////////////
#pragma mark -
#pragma mark Unicode related functions

AGXJK_STATIC_INLINE AGXConversionResult isAGXValidCodePoint(UTF32 *u32CodePoint) {
    AGXConversionResult result = conversionOK;
    UTF32               ch     = *u32CodePoint;

    if (AGXJK_EXPECT_F(ch >= UNI_SUR_HIGH_START) && (AGXJK_EXPECT_T(ch <= UNI_SUR_LOW_END)))                                                        { result = sourceIllegal; ch = UNI_REPLACEMENT_CHAR; goto finished; }
    if (AGXJK_EXPECT_F(ch >= 0xFDD0U) && (AGXJK_EXPECT_F(ch <= 0xFDEFU) || AGXJK_EXPECT_F((ch & 0xFFFEU) == 0xFFFEU)) && AGXJK_EXPECT_T(ch <= 0x10FFFFU)) { result = sourceIllegal; ch = UNI_REPLACEMENT_CHAR; goto finished; }
    if (AGXJK_EXPECT_F(ch == 0U))                                                                                                                { result = sourceIllegal; ch = UNI_REPLACEMENT_CHAR; goto finished; }

finished:
    *u32CodePoint = ch;
    return(result);
}

static int isAGXLegalUTF8(const UTF8 *source, size_t length) {
    const UTF8 *srcptr = source + length;
    UTF8 a;

    switch(length) {
        default: return(0); // Everything else falls through when "true"...
        case 4: if (AGXJK_EXPECT_F(((a = (*--srcptr)) < 0x80) || (a > 0xBF))) { return(0); }
        case 3: if (AGXJK_EXPECT_F(((a = (*--srcptr)) < 0x80) || (a > 0xBF))) { return(0); }
        case 2: if (AGXJK_EXPECT_F( (a = (*--srcptr)) > 0xBF               )) { return(0); }

            switch(*source) { // no fall-through in this inner switch
                case 0xE0: if (AGXJK_EXPECT_F(a < 0xA0)) { return(0); } break;
                case 0xED: if (AGXJK_EXPECT_F(a > 0x9F)) { return(0); } break;
                case 0xF0: if (AGXJK_EXPECT_F(a < 0x90)) { return(0); } break;
                case 0xF4: if (AGXJK_EXPECT_F(a > 0x8F)) { return(0); } break;
                default:   if (AGXJK_EXPECT_F(a < 0x80)) { return(0); }
            }

        case 1: if (AGXJK_EXPECT_F((AGXJK_EXPECT_T(*source < 0xC2)) && AGXJK_EXPECT_F(*source >= 0x80))) { return(0); }
    }

    if (AGXJK_EXPECT_F(*source > 0xF4)) { return(0); }
    return(1);
}

static AGXConversionResult AGXConvertSingleCodePointInUTF8(const UTF8 *sourceStart, const UTF8 *sourceEnd, UTF8 const **nextUTF8, UTF32 *convertedUTF32) {
    AGXConversionResult result = conversionOK;
    const UTF8 *source = sourceStart;
    UTF32 ch = 0UL;

#if !defined(AGXJK_FAST_TRAILING_BYTES)
    unsigned short extraBytesToRead = trailingBytesForUTF8[*source];
#else
    unsigned short extraBytesToRead = __builtin_clz(((*source)^0xff) << 25);
#endif

    if (AGXJK_EXPECT_F((source + extraBytesToRead + 1) > sourceEnd) || AGXJK_EXPECT_F(!isAGXLegalUTF8(source, extraBytesToRead + 1))) {
        source++;
        while((source < sourceEnd) && (((*source) & 0xc0) == 0x80) && ((source - sourceStart) < (extraBytesToRead + 1))) { source++; }
        NSCParameterAssert(source <= sourceEnd);
        result = ((source < sourceEnd) && (((*source) & 0xc0) != 0x80)) ? sourceIllegal : ((sourceStart + extraBytesToRead + 1) > sourceEnd) ? sourceExhausted : sourceIllegal;
        ch = UNI_REPLACEMENT_CHAR;
        goto finished;
    }

    switch(extraBytesToRead) { // The cases all fall through.
        case 5: ch += *source++; ch <<= 6;
        case 4: ch += *source++; ch <<= 6;
        case 3: ch += *source++; ch <<= 6;
        case 2: ch += *source++; ch <<= 6;
        case 1: ch += *source++; ch <<= 6;
        case 0: ch += *source++;
    }
    ch -= offsetsFromUTF8[extraBytesToRead];

    result = isAGXValidCodePoint(&ch);

finished:
    *nextUTF8       = source;
    *convertedUTF32 = ch;
    return(result);
}

static AGXConversionResult AGXConvertUTF32toUTF8 (UTF32 u32CodePoint, UTF8 **targetStart, UTF8 *targetEnd) {
    const UTF32         byteMask     = 0xBF, byteMark = 0x80;
    AGXConversionResult result       = conversionOK;
    UTF8               *target       = *targetStart;
    UTF32               ch           = u32CodePoint;
    unsigned short      bytesToWrite = 0;

    result = isAGXValidCodePoint(&ch);

    // Figure out how many bytes the result will require. Turn any illegally large UTF32 things (> Plane 17) into replacement chars.
    if (ch < (UTF32)0x80)          { bytesToWrite = 1; }
    else if (ch < (UTF32)0x800)         { bytesToWrite = 2; }
    else if (ch < (UTF32)0x10000)       { bytesToWrite = 3; }
    else if (ch <= UNI_MAX_LEGAL_UTF32) { bytesToWrite = 4; }
    else {                               bytesToWrite = 3; ch = UNI_REPLACEMENT_CHAR; result = sourceIllegal; }

    target += bytesToWrite;
    if (target > targetEnd) { target -= bytesToWrite; result = targetExhausted; goto finished; }

    switch (bytesToWrite) { // note: everything falls through.
        case 4: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
        case 3: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
        case 2: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
        case 1: *--target = (UTF8) (ch | firstByteMark[bytesToWrite]);
    }

    target += bytesToWrite;

finished:
    *targetStart = target;
    return(result);
}

AGXJK_STATIC_INLINE int AGXjk_string_add_unicodeCodePoint(AGXJKParseState *parseState, uint32_t unicodeCodePoint, size_t *tokenBufferIdx, AGXJKHash *stringHash) {
    UTF8                *u8s = &parseState->token.tokenBuffer.bytes.ptr[*tokenBufferIdx];
    AGXConversionResult  result;

    if ((result = AGXConvertUTF32toUTF8(unicodeCodePoint, &u8s, (parseState->token.tokenBuffer.bytes.ptr + parseState->token.tokenBuffer.bytes.length))) != conversionOK) { if (result == targetExhausted) { return(1); } }
    size_t utf8len = u8s - &parseState->token.tokenBuffer.bytes.ptr[*tokenBufferIdx], nextIdx = (*tokenBufferIdx) + utf8len;

    while(*tokenBufferIdx < nextIdx) { *stringHash = AGXjk_calculateHash(*stringHash, parseState->token.tokenBuffer.bytes.ptr[(*tokenBufferIdx)++]); }
    return(0);
}

////////////
#pragma mark -
#pragma mark Decoding / parsing / deserializing functions

static int AGXjk_parse_string(AGXJKParseState *parseState) {
    NSCParameterAssert((parseState != NULL) && (AGXJK_AT_STRING_PTR(parseState) <= AGXJK_END_STRING_PTR(parseState)));
    const unsigned char *stringStart       = AGXJK_AT_STRING_PTR(parseState) + 1;
    const unsigned char *endOfBuffer       = AGXJK_END_STRING_PTR(parseState);
    const unsigned char *atStringCharacter = stringStart;
    unsigned char       *tokenBuffer       = parseState->token.tokenBuffer.bytes.ptr;
    size_t               tokenStartIndex   = parseState->atIndex;
    size_t               tokenBufferIdx    = 0UL;

    int      onlySimpleString        = 1,  stringState     = AGXJSONStringStateStart;
    uint16_t escapedUnicode1         = 0U, escapedUnicode2 = 0U;
    uint32_t escapedUnicodeCodePoint = 0U;
    AGXJKHash stringHash             = AGXJK_HASH_INIT;

    while(1) {
        unsigned long currentChar;

        if (AGXJK_EXPECT_F(atStringCharacter == endOfBuffer)) { /* XXX Add error message */ stringState = AGXJSONStringStateError; goto finishedParsing; }

        if (AGXJK_EXPECT_F((currentChar = *atStringCharacter++) >= 0x80UL)) {
            const unsigned char *nextValidCharacter = NULL;
            UTF32                u32ch              = 0U;
            AGXConversionResult  result;

            if (AGXJK_EXPECT_F((result = AGXConvertSingleCodePointInUTF8(atStringCharacter - 1, endOfBuffer, (UTF8 const **)&nextValidCharacter, &u32ch)) != conversionOK)) { goto switchToSlowPath; }
            stringHash = AGXjk_calculateHash(stringHash, currentChar);
            while(atStringCharacter < nextValidCharacter) { NSCParameterAssert(AGXJK_AT_STRING_PTR(parseState) <= AGXJK_END_STRING_PTR(parseState)); stringHash = AGXjk_calculateHash(stringHash, *atStringCharacter++); }
            continue;
        } else {
            if (AGXJK_EXPECT_F(currentChar == (unsigned long)'"')) { stringState = AGXJSONStringStateFinished; goto finishedParsing; }

            if (AGXJK_EXPECT_F(currentChar == (unsigned long)'\\')) {
            switchToSlowPath:
                onlySimpleString = 0;
                stringState      = AGXJSONStringStateParsing;
                tokenBufferIdx   = (atStringCharacter - stringStart) - 1L;
                if (AGXJK_EXPECT_F((tokenBufferIdx + 16UL) > parseState->token.tokenBuffer.bytes.length)) { if ((tokenBuffer = AGXjk_managedBuffer_resize(&parseState->token.tokenBuffer, tokenBufferIdx + 1024UL)) == NULL) { AGXjk_error(parseState, @"Internal error: Unable to resize temporary buffer. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; } }
                memcpy(tokenBuffer, stringStart, tokenBufferIdx);
                goto slowMatch;
            }

            if (AGXJK_EXPECT_F(currentChar < 0x20UL)) { AGXjk_error(parseState, @"Invalid character < 0x20 found in string: 0x%2.2x.", currentChar); stringState = AGXJSONStringStateError; goto finishedParsing; }

            stringHash = AGXjk_calculateHash(stringHash, currentChar);
        }
    }

slowMatch:

    for(atStringCharacter = (stringStart + ((atStringCharacter - stringStart) - 1L)); (atStringCharacter < endOfBuffer) && (tokenBufferIdx < parseState->token.tokenBuffer.bytes.length); atStringCharacter++) {
        if ((tokenBufferIdx + 16UL) > parseState->token.tokenBuffer.bytes.length) { if ((tokenBuffer = AGXjk_managedBuffer_resize(&parseState->token.tokenBuffer, tokenBufferIdx + 1024UL)) == NULL) { AGXjk_error(parseState, @"Internal error: Unable to resize temporary buffer. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; } }

        NSCParameterAssert(tokenBufferIdx < parseState->token.tokenBuffer.bytes.length);

        unsigned long currentChar = (*atStringCharacter), escapedChar;

        if (AGXJK_EXPECT_T(stringState == AGXJSONStringStateParsing)) {
            if (AGXJK_EXPECT_T(currentChar >= 0x20UL)) {
                if (AGXJK_EXPECT_T(currentChar < (unsigned long)0x80)) { // Not a UTF8 sequence
                    if (AGXJK_EXPECT_F(currentChar == (unsigned long)'"'))  { stringState = AGXJSONStringStateFinished; atStringCharacter++; goto finishedParsing; }
                    if (AGXJK_EXPECT_F(currentChar == (unsigned long)'\\')) { stringState = AGXJSONStringStateEscape; continue; }
                    stringHash = AGXjk_calculateHash(stringHash, currentChar);
                    tokenBuffer[tokenBufferIdx++] = currentChar;
                    continue;
                } else { // UTF8 sequence
                    const unsigned char *nextValidCharacter = NULL;
                    UTF32                u32ch              = 0U;
                    AGXConversionResult  result;

                    if (AGXJK_EXPECT_F((result = AGXConvertSingleCodePointInUTF8(atStringCharacter, endOfBuffer, (UTF8 const **)&nextValidCharacter, &u32ch)) != conversionOK)) {
                        if ((result == sourceIllegal) && ((parseState->parseOptionFlags & AGXJKParseOptionLooseUnicode) == 0)) { AGXjk_error(parseState, @"Illegal UTF8 sequence found in \"\" string.");              stringState = AGXJSONStringStateError; goto finishedParsing; }
                        if (result == sourceExhausted)                                                                      { AGXjk_error(parseState, @"End of buffer reached while parsing UTF8 in \"\" string."); stringState = AGXJSONStringStateError; goto finishedParsing; }
                        if (AGXjk_string_add_unicodeCodePoint(parseState, u32ch, &tokenBufferIdx, &stringHash))                { AGXjk_error(parseState, @"Internal error: Unable to add UTF8 sequence to internal string buffer. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; }
                        atStringCharacter = nextValidCharacter - 1;
                        continue;
                    } else {
                        while(atStringCharacter < nextValidCharacter) { tokenBuffer[tokenBufferIdx++] = *atStringCharacter; stringHash = AGXjk_calculateHash(stringHash, *atStringCharacter++); }
                        atStringCharacter--;
                        continue;
                    }
                }
            } else { // currentChar < 0x20
                AGXjk_error(parseState, @"Invalid character < 0x20 found in string: 0x%2.2x.", currentChar); stringState = AGXJSONStringStateError; goto finishedParsing;
            }

        } else { // stringState != JSONStringStateParsing
            int isSurrogate = 1;

            switch(stringState) {
                case AGXJSONStringStateEscape:
                    switch(currentChar) {
                        case 'u': escapedUnicode1 = 0U; escapedUnicode2 = 0U; escapedUnicodeCodePoint = 0U; stringState = AGXJSONStringStateEscapedUnicode1; break;

                        case 'b':  escapedChar = '\b'; goto parsedEscapedChar;
                        case 'f':  escapedChar = '\f'; goto parsedEscapedChar;
                        case 'n':  escapedChar = '\n'; goto parsedEscapedChar;
                        case 'r':  escapedChar = '\r'; goto parsedEscapedChar;
                        case 't':  escapedChar = '\t'; goto parsedEscapedChar;
                        case '\\': escapedChar = '\\'; goto parsedEscapedChar;
                        case '/':  escapedChar = '/';  goto parsedEscapedChar;
                        case '"':  escapedChar = '"';  goto parsedEscapedChar;

                        parsedEscapedChar:
                            stringState = AGXJSONStringStateParsing;
                            stringHash  = AGXjk_calculateHash(stringHash, escapedChar);
                            tokenBuffer[tokenBufferIdx++] = escapedChar;
                            break;

                        default: AGXjk_error(parseState, @"Invalid escape sequence found in \"\" string."); stringState = AGXJSONStringStateError; goto finishedParsing; break;
                    }
                    break;

                case AGXJSONStringStateEscapedUnicode1:
                case AGXJSONStringStateEscapedUnicode2:
                case AGXJSONStringStateEscapedUnicode3:
                case AGXJSONStringStateEscapedUnicode4:           isSurrogate = 0;
                case AGXJSONStringStateEscapedUnicodeSurrogate1:
                case AGXJSONStringStateEscapedUnicodeSurrogate2:
                case AGXJSONStringStateEscapedUnicodeSurrogate3:
                case AGXJSONStringStateEscapedUnicodeSurrogate4:
                {
                    uint16_t hexValue = 0U;

                    switch(currentChar) {
                        case '0' ... '9': hexValue =  currentChar - '0';        goto parsedHex;
                        case 'a' ... 'f': hexValue = (currentChar - 'a') + 10U; goto parsedHex;
                        case 'A' ... 'F': hexValue = (currentChar - 'A') + 10U; goto parsedHex;

                        parsedHex:
                            if (!isSurrogate) { escapedUnicode1 = (escapedUnicode1 << 4) | hexValue; } else { escapedUnicode2 = (escapedUnicode2 << 4) | hexValue; }

                            if (stringState == AGXJSONStringStateEscapedUnicode4) {
                                if (((escapedUnicode1 >= 0xD800U) && (escapedUnicode1 < 0xE000U))) {
                                    if ((escapedUnicode1 >= 0xD800U) && (escapedUnicode1 < 0xDC00U)) { stringState = AGXJSONStringStateEscapedNeedEscapeForSurrogate; }
                                    else if ((escapedUnicode1 >= 0xDC00U) && (escapedUnicode1 < 0xE000U)) {
                                        if ((parseState->parseOptionFlags & AGXJKParseOptionLooseUnicode)) { escapedUnicodeCodePoint = UNI_REPLACEMENT_CHAR; }
                                        else { AGXjk_error(parseState, @"Illegal \\u Unicode escape sequence."); stringState = AGXJSONStringStateError; goto finishedParsing; }
                                    }
                                }
                                else { escapedUnicodeCodePoint = escapedUnicode1; }
                            }

                            if (stringState == AGXJSONStringStateEscapedUnicodeSurrogate4) {
                                if ((escapedUnicode2 < 0xdc00) || (escapedUnicode2 > 0xdfff)) {
                                    if ((parseState->parseOptionFlags & AGXJKParseOptionLooseUnicode)) { escapedUnicodeCodePoint = UNI_REPLACEMENT_CHAR; }
                                    else { AGXjk_error(parseState, @"Illegal \\u Unicode escape sequence."); stringState = AGXJSONStringStateError; goto finishedParsing; }
                                }
                                else { escapedUnicodeCodePoint = ((escapedUnicode1 - 0xd800) * 0x400) + (escapedUnicode2 - 0xdc00) + 0x10000; }
                            }

                            if ((stringState == AGXJSONStringStateEscapedUnicode4) || (stringState == AGXJSONStringStateEscapedUnicodeSurrogate4)) {
                                if ((isAGXValidCodePoint(&escapedUnicodeCodePoint) == sourceIllegal) && ((parseState->parseOptionFlags & AGXJKParseOptionLooseUnicode) == 0)) { AGXjk_error(parseState, @"Illegal \\u Unicode escape sequence."); stringState = AGXJSONStringStateError; goto finishedParsing; }
                                stringState = AGXJSONStringStateParsing;
                                if (AGXjk_string_add_unicodeCodePoint(parseState, escapedUnicodeCodePoint, &tokenBufferIdx, &stringHash)) { AGXjk_error(parseState, @"Internal error: Unable to add UTF8 sequence to internal string buffer. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; }
                            }
                            else if ((stringState >= AGXJSONStringStateEscapedUnicode1) && (stringState <= AGXJSONStringStateEscapedUnicodeSurrogate4)) { stringState++; }
                            break;

                        default: AGXjk_error(parseState, @"Unexpected character found in \\u Unicode escape sequence.  Found '%c', expected [0-9a-fA-F].", currentChar); stringState = AGXJSONStringStateError; goto finishedParsing; break;
                    }
                }
                    break;

                case AGXJSONStringStateEscapedNeedEscapeForSurrogate:
                    if (currentChar == '\\') { stringState = AGXJSONStringStateEscapedNeedEscapedUForSurrogate; }
                    else {
                        if ((parseState->parseOptionFlags & AGXJKParseOptionLooseUnicode) == 0) { AGXjk_error(parseState, @"Required a second \\u Unicode escape sequence following a surrogate \\u Unicode escape sequence."); stringState = AGXJSONStringStateError; goto finishedParsing; }
                        else { stringState = AGXJSONStringStateParsing; atStringCharacter--;    if (AGXjk_string_add_unicodeCodePoint(parseState, UNI_REPLACEMENT_CHAR, &tokenBufferIdx, &stringHash)) { AGXjk_error(parseState, @"Internal error: Unable to add UTF8 sequence to internal string buffer. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; } }
                    }
                    break;

                case AGXJSONStringStateEscapedNeedEscapedUForSurrogate:
                    if (currentChar == 'u') { stringState = AGXJSONStringStateEscapedUnicodeSurrogate1; }
                    else {
                        if ((parseState->parseOptionFlags & AGXJKParseOptionLooseUnicode) == 0) { AGXjk_error(parseState, @"Required a second \\u Unicode escape sequence following a surrogate \\u Unicode escape sequence."); stringState = AGXJSONStringStateError; goto finishedParsing; }
                        else { stringState = AGXJSONStringStateParsing; atStringCharacter -= 2; if (AGXjk_string_add_unicodeCodePoint(parseState, UNI_REPLACEMENT_CHAR, &tokenBufferIdx, &stringHash)) { AGXjk_error(parseState, @"Internal error: Unable to add UTF8 sequence to internal string buffer. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; } }
                    }
                    break;

                default: AGXjk_error(parseState, @"Internal error: Unknown stringState. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); stringState = AGXJSONStringStateError; goto finishedParsing; break;
            }
        }
    }

finishedParsing:

    if (AGXJK_EXPECT_T(stringState == AGXJSONStringStateFinished)) {
        NSCParameterAssert((parseState->stringBuffer.bytes.ptr + tokenStartIndex) < atStringCharacter);

        parseState->token.tokenPtrRange.ptr    = parseState->stringBuffer.bytes.ptr + tokenStartIndex;
        parseState->token.tokenPtrRange.length = (atStringCharacter - parseState->token.tokenPtrRange.ptr);

        if (AGXJK_EXPECT_T(onlySimpleString)) {
            NSCParameterAssert(((parseState->token.tokenPtrRange.ptr + 1) < endOfBuffer) && (parseState->token.tokenPtrRange.length >= 2UL) && (((parseState->token.tokenPtrRange.ptr + 1) + (parseState->token.tokenPtrRange.length - 2)) < endOfBuffer));
            parseState->token.value.ptrRange.ptr    = parseState->token.tokenPtrRange.ptr    + 1;
            parseState->token.value.ptrRange.length = parseState->token.tokenPtrRange.length - 2UL;
        } else {
            parseState->token.value.ptrRange.ptr    = parseState->token.tokenBuffer.bytes.ptr;
            parseState->token.value.ptrRange.length = tokenBufferIdx;
        }

        parseState->token.value.hash = stringHash;
        parseState->token.value.type = AGXJKValueTypeString;
        parseState->atIndex          = (atStringCharacter - parseState->stringBuffer.bytes.ptr);
    }

    if (AGXJK_EXPECT_F(stringState != AGXJSONStringStateFinished)) { AGXjk_error(parseState, @"Invalid string."); }
    return(AGXJK_EXPECT_T(stringState == AGXJSONStringStateFinished) ? 0 : 1);
}

static int AGXjk_parse_number(AGXJKParseState *parseState) {
    NSCParameterAssert((parseState != NULL) && (AGXJK_AT_STRING_PTR(parseState) <= AGXJK_END_STRING_PTR(parseState)));
    const unsigned char *numberStart       = AGXJK_AT_STRING_PTR(parseState);
    const unsigned char *endOfBuffer       = AGXJK_END_STRING_PTR(parseState);
    const unsigned char *atNumberCharacter = NULL;
    int                  numberState       = AGXJSONNumberStateWholeNumberStart, isFloatingPoint = 0, isNegative = 0, backup = 0;
    size_t               startingIndex     = parseState->atIndex;

    for(atNumberCharacter = numberStart; (AGXJK_EXPECT_T(atNumberCharacter < endOfBuffer)) && (AGXJK_EXPECT_T(!(AGXJK_EXPECT_F(numberState == AGXJSONNumberStateFinished) || AGXJK_EXPECT_F(numberState == AGXJSONNumberStateError)))); atNumberCharacter++) {
        unsigned long currentChar = (unsigned long)(*atNumberCharacter), lowerCaseCC = currentChar | 0x20UL;

        switch(numberState) {
            case AGXJSONNumberStateWholeNumberStart: if   (currentChar == '-')                                                                              { numberState = AGXJSONNumberStateWholeNumberMinus;      isNegative      = 1; break; }
            case AGXJSONNumberStateWholeNumberMinus: if   (currentChar == '0')                                                                              { numberState = AGXJSONNumberStateWholeNumberZero;                            break; }
            else if (  (currentChar >= '1') && (currentChar <= '9'))                                                     { numberState = AGXJSONNumberStateWholeNumber;                                break; }
            else                                                     { /* XXX Add error message */                        numberState = AGXJSONNumberStateError;                                      break; }
            case AGXJSONNumberStateExponentStart:    if (  (currentChar == '+') || (currentChar == '-'))                                                     { numberState = AGXJSONNumberStateExponentPlusMinus;                          break; }
            case AGXJSONNumberStateFractionalNumberStart:
            case AGXJSONNumberStateExponentPlusMinus:if (!((currentChar >= '0') && (currentChar <= '9'))) { /* XXX Add error message */                        numberState = AGXJSONNumberStateError;                                      break; }
            else {                                              if (numberState == AGXJSONNumberStateFractionalNumberStart) { numberState = AGXJSONNumberStateFractionalNumber; }
                else                                                    { numberState = AGXJSONNumberStateExponent;         }                         break; }
            case AGXJSONNumberStateWholeNumberZero:
            case AGXJSONNumberStateWholeNumber:      if   (currentChar == '.')                                                                              { numberState = AGXJSONNumberStateFractionalNumberStart; isFloatingPoint = 1; break; }
            case AGXJSONNumberStateFractionalNumber: if   (lowerCaseCC == 'e')                                                                              { numberState = AGXJSONNumberStateExponentStart;         isFloatingPoint = 1; break; }
            case AGXJSONNumberStateExponent:         if (!((currentChar >= '0') && (currentChar <= '9')) || (numberState == AGXJSONNumberStateWholeNumberZero)) { numberState = AGXJSONNumberStateFinished;              backup          = 1; break; }
                break;
            default:                                                                                    /* XXX Add error message */                        numberState = AGXJSONNumberStateError;                                      break;
        }
    }

    parseState->token.tokenPtrRange.ptr    = parseState->stringBuffer.bytes.ptr + startingIndex;
    parseState->token.tokenPtrRange.length = (atNumberCharacter - parseState->token.tokenPtrRange.ptr) - backup;
    parseState->atIndex                    = (parseState->token.tokenPtrRange.ptr + parseState->token.tokenPtrRange.length) - parseState->stringBuffer.bytes.ptr;

    if (AGXJK_EXPECT_T(numberState == AGXJSONNumberStateFinished)) {
        unsigned char  numberTempBuf[parseState->token.tokenPtrRange.length + 4UL];
        unsigned char *endOfNumber = NULL;

        memcpy(numberTempBuf, parseState->token.tokenPtrRange.ptr, parseState->token.tokenPtrRange.length);
        numberTempBuf[parseState->token.tokenPtrRange.length] = 0;

        errno = 0;

        // Treat "-0" as a floating point number, which is capable of representing negative zeros.
        if (AGXJK_EXPECT_F(parseState->token.tokenPtrRange.length == 2UL) && AGXJK_EXPECT_F(numberTempBuf[1] == '0') && AGXJK_EXPECT_F(isNegative)) { isFloatingPoint = 1; }

        if (isFloatingPoint) {
            parseState->token.value.number.doubleValue = strtod((const char *)numberTempBuf, (char **)&endOfNumber); // strtod is documented to return U+2261 (identical to) 0.0 on an underflow error (along with setting errno to ERANGE).
            parseState->token.value.type               = AGXJKValueTypeDouble;
            parseState->token.value.ptrRange.ptr       = (const unsigned char *)&parseState->token.value.number.doubleValue;
            parseState->token.value.ptrRange.length    = sizeof(double);
            parseState->token.value.hash               = (AGXJK_HASH_INIT + parseState->token.value.type);
        } else {
            if (isNegative) {
                parseState->token.value.number.longLongValue = strtoll((const char *)numberTempBuf, (char **)&endOfNumber, 10);
                parseState->token.value.type                 = AGXJKValueTypeLongLong;
                parseState->token.value.ptrRange.ptr         = (const unsigned char *)&parseState->token.value.number.longLongValue;
                parseState->token.value.ptrRange.length      = sizeof(long long);
                parseState->token.value.hash                 = (AGXJK_HASH_INIT + parseState->token.value.type) + (AGXJKHash)parseState->token.value.number.longLongValue;
            } else {
                parseState->token.value.number.unsignedLongLongValue = strtoull((const char *)numberTempBuf, (char **)&endOfNumber, 10);
                parseState->token.value.type                         = AGXJKValueTypeUnsignedLongLong;
                parseState->token.value.ptrRange.ptr                 = (const unsigned char *)&parseState->token.value.number.unsignedLongLongValue;
                parseState->token.value.ptrRange.length              = sizeof(unsigned long long);
                parseState->token.value.hash                         = (AGXJK_HASH_INIT + parseState->token.value.type) + (AGXJKHash)parseState->token.value.number.unsignedLongLongValue;
            }
        }

        if (AGXJK_EXPECT_F(errno != 0)) {
            numberState = AGXJSONNumberStateError;
            if (errno == ERANGE) {
                switch(parseState->token.value.type) {
                    case AGXJKValueTypeDouble:           AGXjk_error(parseState, @"The value '%s' could not be represented as a 'double' due to %s.",           numberTempBuf, (parseState->token.value.number.doubleValue == 0.0) ? "underflow" : "overflow"); break; // see above for == 0.0.
                    case AGXJKValueTypeLongLong:         AGXjk_error(parseState, @"The value '%s' exceeded the minimum value that could be represented: %lld.", numberTempBuf, parseState->token.value.number.longLongValue);                                   break;
                    case AGXJKValueTypeUnsignedLongLong: AGXjk_error(parseState, @"The value '%s' exceeded the maximum value that could be represented: %llu.", numberTempBuf, parseState->token.value.number.unsignedLongLongValue);                           break;
                    default:                             AGXjk_error(parseState, @"Internal error: Unknown token value type. %@ line #%ld",                     [NSString stringWithUTF8String:__FILE__], (long)__LINE__);                                      break;
                }
            }
        }
        if (AGXJK_EXPECT_F(endOfNumber != &numberTempBuf[parseState->token.tokenPtrRange.length]) && AGXJK_EXPECT_F(numberState != AGXJSONNumberStateError)) { numberState = AGXJSONNumberStateError; AGXjk_error(parseState, @"The conversion function did not consume all of the number tokens characters."); }

        size_t hashIndex = 0UL;
        for(hashIndex = 0UL; hashIndex < parseState->token.value.ptrRange.length; hashIndex++) { parseState->token.value.hash = AGXjk_calculateHash(parseState->token.value.hash, parseState->token.value.ptrRange.ptr[hashIndex]); }
    }

    if (AGXJK_EXPECT_F(numberState != AGXJSONNumberStateFinished)) { AGXjk_error(parseState, @"Invalid number."); }
    return(AGXJK_EXPECT_T((numberState == AGXJSONNumberStateFinished)) ? 0 : 1);
}

AGXJK_STATIC_INLINE void AGXjk_set_parsed_token(AGXJKParseState *parseState, const unsigned char *ptr, size_t length, AGXJKTokenType type, size_t advanceBy) {
    parseState->token.tokenPtrRange.ptr     = ptr;
    parseState->token.tokenPtrRange.length  = length;
    parseState->token.type                  = type;
    parseState->atIndex                    += advanceBy;
}

static size_t AGXjk_parse_is_newline(AGXJKParseState *parseState, const unsigned char *atCharacterPtr) {
    NSCParameterAssert((parseState != NULL) && (atCharacterPtr != NULL) && (atCharacterPtr >= parseState->stringBuffer.bytes.ptr) && (atCharacterPtr < AGXJK_END_STRING_PTR(parseState)));
    const unsigned char *endOfStringPtr = AGXJK_END_STRING_PTR(parseState);

    if (AGXJK_EXPECT_F(atCharacterPtr >= endOfStringPtr)) { return(0UL); }

    if (AGXJK_EXPECT_F((*(atCharacterPtr + 0)) == '\n')) { return(1UL); }
    if (AGXJK_EXPECT_F((*(atCharacterPtr + 0)) == '\r')) { if ((AGXJK_EXPECT_T((atCharacterPtr + 1) < endOfStringPtr)) && ((*(atCharacterPtr + 1)) == '\n')) { return(2UL); } return(1UL); }
    if (parseState->parseOptionFlags & AGXJKParseOptionUnicodeNewlines) {
        if ((AGXJK_EXPECT_F((*(atCharacterPtr + 0)) == 0xc2)) && (((atCharacterPtr + 1) < endOfStringPtr) && ((*(atCharacterPtr + 1)) == 0x85))) { return(2UL); }
        if ((AGXJK_EXPECT_F((*(atCharacterPtr + 0)) == 0xe2)) && (((atCharacterPtr + 2) < endOfStringPtr) && ((*(atCharacterPtr + 1)) == 0x80) && (((*(atCharacterPtr + 2)) == 0xa8) || ((*(atCharacterPtr + 2)) == 0xa9)))) { return(3UL); }
    }
    return(0UL);
}

AGXJK_STATIC_INLINE int AGXjk_parse_skip_newline(AGXJKParseState *parseState) {
    size_t newlineAdvanceAtIndex = 0UL;
    if (AGXJK_EXPECT_F((newlineAdvanceAtIndex = AGXjk_parse_is_newline(parseState, AGXJK_AT_STRING_PTR(parseState))) > 0UL)) { parseState->lineNumber++; parseState->atIndex += (newlineAdvanceAtIndex - 1UL); parseState->lineStartIndex = parseState->atIndex + 1UL; return(1); }
    return(0);
}

AGXJK_STATIC_INLINE void AGXjk_parse_skip_whitespace(AGXJKParseState *parseState) {
#ifndef __clang_analyzer__
    NSCParameterAssert((parseState != NULL) && (AGXJK_AT_STRING_PTR(parseState) <= AGXJK_END_STRING_PTR(parseState)));
    const unsigned char *atCharacterPtr   = NULL;
    const unsigned char *endOfStringPtr   = AGXJK_END_STRING_PTR(parseState);

    for(atCharacterPtr = AGXJK_AT_STRING_PTR(parseState); (AGXJK_EXPECT_T((atCharacterPtr = AGXJK_AT_STRING_PTR(parseState)) < endOfStringPtr)); parseState->atIndex++) {
        if (((*(atCharacterPtr + 0)) == ' ') || ((*(atCharacterPtr + 0)) == '\t')) { continue; }
        if (AGXjk_parse_skip_newline(parseState)) { continue; }
        if (parseState->parseOptionFlags & AGXJKParseOptionComments) {
            if ((AGXJK_EXPECT_F((*(atCharacterPtr + 0)) == '/')) && (AGXJK_EXPECT_T((atCharacterPtr + 1) < endOfStringPtr))) {
                if ((*(atCharacterPtr + 1)) == '/') {
                    parseState->atIndex++;
                    for(atCharacterPtr = AGXJK_AT_STRING_PTR(parseState); (AGXJK_EXPECT_T((atCharacterPtr = AGXJK_AT_STRING_PTR(parseState)) < endOfStringPtr)); parseState->atIndex++) { if (AGXjk_parse_skip_newline(parseState)) { break; } }
                    continue;
                }
                if ((*(atCharacterPtr + 1)) == '*') {
                    parseState->atIndex++;
                    for(atCharacterPtr = AGXJK_AT_STRING_PTR(parseState); (AGXJK_EXPECT_T((atCharacterPtr = AGXJK_AT_STRING_PTR(parseState)) < endOfStringPtr)); parseState->atIndex++) {
                        if (AGXjk_parse_skip_newline(parseState)) { continue; }
                        if (((*(atCharacterPtr + 0)) == '*') && (((atCharacterPtr + 1) < endOfStringPtr) && ((*(atCharacterPtr + 1)) == '/'))) { parseState->atIndex++; break; }
                    }
                    continue;
                }
            }
        }
        break;
    }
#endif // __clang_analyzer__
}

static int AGXjk_parse_next_token(AGXJKParseState *parseState) {
    NSCParameterAssert((parseState != NULL) && (AGXJK_AT_STRING_PTR(parseState) <= AGXJK_END_STRING_PTR(parseState)));
    const unsigned char *atCharacterPtr   = NULL;
    const unsigned char *endOfStringPtr   = AGXJK_END_STRING_PTR(parseState);
    unsigned char        currentCharacter = 0U;
    int                  stopParsing      = 0;

    parseState->prev_atIndex        = parseState->atIndex;
    parseState->prev_lineNumber     = parseState->lineNumber;
    parseState->prev_lineStartIndex = parseState->lineStartIndex;

    AGXjk_parse_skip_whitespace(parseState);

    if ((AGXJK_AT_STRING_PTR(parseState) == endOfStringPtr)) { stopParsing = 1; }

    if ((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T((atCharacterPtr = AGXJK_AT_STRING_PTR(parseState)) < endOfStringPtr))) {
        currentCharacter = *atCharacterPtr;

        if (AGXJK_EXPECT_T(currentCharacter == '"')) { if (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_string(parseState)) == 0)) { AGXjk_set_parsed_token(parseState, parseState->token.tokenPtrRange.ptr, parseState->token.tokenPtrRange.length, AGXJKTokenTypeString, 0UL); } }
        else if (AGXJK_EXPECT_T(currentCharacter == ':')) { AGXjk_set_parsed_token(parseState, atCharacterPtr, 1UL, AGXJKTokenTypeSeparator,   1UL); }
        else if (AGXJK_EXPECT_T(currentCharacter == ',')) { AGXjk_set_parsed_token(parseState, atCharacterPtr, 1UL, AGXJKTokenTypeComma,       1UL); }
        else if ((AGXJK_EXPECT_T(currentCharacter >= '0') && AGXJK_EXPECT_T(currentCharacter <= '9')) || AGXJK_EXPECT_T(currentCharacter == '-')) { if (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_number(parseState)) == 0)) { AGXjk_set_parsed_token(parseState, parseState->token.tokenPtrRange.ptr, parseState->token.tokenPtrRange.length, AGXJKTokenTypeNumber, 0UL); } }
        else if (AGXJK_EXPECT_T(currentCharacter == '{')) { AGXjk_set_parsed_token(parseState, atCharacterPtr, 1UL, AGXJKTokenTypeObjectBegin, 1UL); }
        else if (AGXJK_EXPECT_T(currentCharacter == '}')) { AGXjk_set_parsed_token(parseState, atCharacterPtr, 1UL, AGXJKTokenTypeObjectEnd,   1UL); }
        else if (AGXJK_EXPECT_T(currentCharacter == '[')) { AGXjk_set_parsed_token(parseState, atCharacterPtr, 1UL, AGXJKTokenTypeArrayBegin,  1UL); }
        else if (AGXJK_EXPECT_T(currentCharacter == ']')) { AGXjk_set_parsed_token(parseState, atCharacterPtr, 1UL, AGXJKTokenTypeArrayEnd,    1UL); }

        else if (AGXJK_EXPECT_T(currentCharacter == 't')) { if (!((AGXJK_EXPECT_T((atCharacterPtr + 4UL) < endOfStringPtr)) && (AGXJK_EXPECT_T(atCharacterPtr[1] == 'r')) && (AGXJK_EXPECT_T(atCharacterPtr[2] == 'u')) && (AGXJK_EXPECT_T(atCharacterPtr[3] == 'e'))))                                            { stopParsing = 1; /* XXX Add error message */ } else { AGXjk_set_parsed_token(parseState, atCharacterPtr, 4UL, AGXJKTokenTypeTrue,  4UL); } }
        else if (AGXJK_EXPECT_T(currentCharacter == 'f')) { if (!((AGXJK_EXPECT_T((atCharacterPtr + 5UL) < endOfStringPtr)) && (AGXJK_EXPECT_T(atCharacterPtr[1] == 'a')) && (AGXJK_EXPECT_T(atCharacterPtr[2] == 'l')) && (AGXJK_EXPECT_T(atCharacterPtr[3] == 's')) && (AGXJK_EXPECT_T(atCharacterPtr[4] == 'e')))) { stopParsing = 1; /* XXX Add error message */ } else { AGXjk_set_parsed_token(parseState, atCharacterPtr, 5UL, AGXJKTokenTypeFalse, 5UL); } }
        else if (AGXJK_EXPECT_T(currentCharacter == 'n')) { if (!((AGXJK_EXPECT_T((atCharacterPtr + 4UL) < endOfStringPtr)) && (AGXJK_EXPECT_T(atCharacterPtr[1] == 'u')) && (AGXJK_EXPECT_T(atCharacterPtr[2] == 'l')) && (AGXJK_EXPECT_T(atCharacterPtr[3] == 'l'))))                                            { stopParsing = 1; /* XXX Add error message */ } else { AGXjk_set_parsed_token(parseState, atCharacterPtr, 4UL, AGXJKTokenTypeNull,  4UL); } }
        else { stopParsing = 1; /* XXX Add error message */ }
    }

    if (AGXJK_EXPECT_F(stopParsing)) { AGXjk_error(parseState, @"Unexpected token, wanted '{', '}', '[', ']', ',', ':', 'true', 'false', 'null', '\"STRING\"', 'NUMBER'."); }
    return(stopParsing);
}

static void AGXjk_error_parse_accept_or3(AGXJKParseState *parseState, int state, NSString *or1String, NSString *or2String, NSString *or3String) {
    NSString *acceptStrings[16];
    int acceptIdx = 0;
    if (state & AGXJKParseAcceptValue) { acceptStrings[acceptIdx++] = or1String; }
    if (state & AGXJKParseAcceptComma) { acceptStrings[acceptIdx++] = or2String; }
    if (state & AGXJKParseAcceptEnd)   { acceptStrings[acceptIdx++] = or3String; }
    if (acceptIdx == 1) { AGXjk_error(parseState, @"Expected %@, not '%*.*s'",           acceptStrings[0],                                     (int)parseState->token.tokenPtrRange.length, (int)parseState->token.tokenPtrRange.length, parseState->token.tokenPtrRange.ptr); }
    else if (acceptIdx == 2) { AGXjk_error(parseState, @"Expected %@ or %@, not '%*.*s'",     acceptStrings[0], acceptStrings[1],                   (int)parseState->token.tokenPtrRange.length, (int)parseState->token.tokenPtrRange.length, parseState->token.tokenPtrRange.ptr); }
    else if (acceptIdx == 3) { AGXjk_error(parseState, @"Expected %@, %@, or %@, not '%*.*s", acceptStrings[0], acceptStrings[1], acceptStrings[2], (int)parseState->token.tokenPtrRange.length, (int)parseState->token.tokenPtrRange.length, parseState->token.tokenPtrRange.ptr); }
}

static void *AGXjk_parse_array(AGXJKParseState *parseState) {
    size_t  startingObjectIndex = parseState->objectStack.index;
    int     arrayState          = AGXJKParseAcceptValueOrEnd, stopParsing = 0;
    void   *parsedArray         = NULL;

    while(AGXJK_EXPECT_T((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T(parseState->atIndex < parseState->stringBuffer.bytes.length)))) {
        if (AGXJK_EXPECT_F(parseState->objectStack.index > (parseState->objectStack.count - 4UL))) { if (AGXjk_objectStack_resize(&parseState->objectStack, parseState->objectStack.count + 128UL)) { AGXjk_error(parseState, @"Internal error: [array] objectsIndex > %zu, resize failed? %@ line %#ld", (parseState->objectStack.count - 4UL), [NSString stringWithUTF8String:__FILE__], (long)__LINE__); break; } }

        if (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_next_token(parseState)) == 0)) {
            void *object = NULL;
#ifndef NS_BLOCK_ASSERTIONS
            parseState->objectStack.objects[parseState->objectStack.index] = NULL;
            parseState->objectStack.keys   [parseState->objectStack.index] = NULL;
#endif
            switch(parseState->token.type) {
                case AGXJKTokenTypeNumber:
                case AGXJKTokenTypeString:
                case AGXJKTokenTypeTrue:
                case AGXJKTokenTypeFalse:
                case AGXJKTokenTypeNull:
                case AGXJKTokenTypeArrayBegin:
                case AGXJKTokenTypeObjectBegin:
                    if (AGXJK_EXPECT_F((arrayState & AGXJKParseAcceptValue)          == 0))    { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected value.");              stopParsing = 1; break; }
                    if (AGXJK_EXPECT_F((object = AGXjk_object_for_token(parseState)) == NULL)) {                              AGXjk_error(parseState, @"Internal error: Object == NULL"); stopParsing = 1; break; } else { parseState->objectStack.objects[parseState->objectStack.index++] = object; arrayState = AGXJKParseAcceptCommaOrEnd; }
                    break;
                case AGXJKTokenTypeArrayEnd: if (AGXJK_EXPECT_T(arrayState & AGXJKParseAcceptEnd)) { NSCParameterAssert(parseState->objectStack.index >= startingObjectIndex); parsedArray = (AGX_BRIDGE void *)_AGXJKArrayCreate(&parseState->objectStack.objects[startingObjectIndex], (parseState->objectStack.index - startingObjectIndex), parseState->mutableCollections); } else { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected ']'."); } stopParsing = 1; break;
                case AGXJKTokenTypeComma:    if (AGXJK_EXPECT_T(arrayState & AGXJKParseAcceptComma)) { arrayState = AGXJKParseAcceptValue; } else { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected ','."); stopParsing = 1; } break;
                default: parseState->errorIsPrev = 1; AGXjk_error_parse_accept_or3(parseState, arrayState, @"a value", @"a comma", @"a ']'"); stopParsing = 1; break;
            }
        }
    }

    if (AGXJK_EXPECT_F(parsedArray == NULL)) { size_t idx = 0UL; for(idx = startingObjectIndex; idx < parseState->objectStack.index; idx++) { if (parseState->objectStack.objects[idx] != NULL) { CFRelease(parseState->objectStack.objects[idx]); parseState->objectStack.objects[idx] = NULL; } } }
#if !defined(NS_BLOCK_ASSERTIONS)
    else { size_t idx = 0UL; for(idx = startingObjectIndex; idx < parseState->objectStack.index; idx++) { parseState->objectStack.objects[idx] = NULL; parseState->objectStack.keys[idx] = NULL; } }
#endif

    parseState->objectStack.index = startingObjectIndex;
    return(parsedArray);
}

static void *AGXjk_create_dictionary(AGXJKParseState *parseState, size_t startingObjectIndex) {
    void *parsedDictionary = NULL;

    parseState->objectStack.index--;

    parsedDictionary = (AGX_BRIDGE void *)_AGXJKDictionaryCreate(&parseState->objectStack.keys[startingObjectIndex], (NSUInteger *)&parseState->objectStack.cfHashes[startingObjectIndex], &parseState->objectStack.objects[startingObjectIndex], (parseState->objectStack.index - startingObjectIndex), parseState->mutableCollections);
    return(parsedDictionary);
}

static void *AGXjk_parse_dictionary(AGXJKParseState *parseState) {
    size_t  startingObjectIndex = parseState->objectStack.index;
    int     dictState           = AGXJKParseAcceptValueOrEnd, stopParsing = 0;
    void   *parsedDictionary    = NULL;

    while(AGXJK_EXPECT_T((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T(parseState->atIndex < parseState->stringBuffer.bytes.length)))) {
        if (AGXJK_EXPECT_F(parseState->objectStack.index > (parseState->objectStack.count - 4UL))) { if (AGXjk_objectStack_resize(&parseState->objectStack, parseState->objectStack.count + 128UL)) { AGXjk_error(parseState, @"Internal error: [dictionary] objectsIndex > %zu, resize failed? %@ line #%ld", (parseState->objectStack.count - 4UL), [NSString stringWithUTF8String:__FILE__], (long)__LINE__); break; } }

        size_t objectStackIndex = parseState->objectStack.index++;
        parseState->objectStack.keys[objectStackIndex]    = NULL;
        parseState->objectStack.objects[objectStackIndex] = NULL;
        void *key = NULL, *object = NULL;

        if (AGXJK_EXPECT_T((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_next_token(parseState)) == 0)))) {
            switch(parseState->token.type) {
                case AGXJKTokenTypeString:
                    if (AGXJK_EXPECT_F((dictState & AGXJKParseAcceptValue)        == 0))    { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected string.");           stopParsing = 1; break; }
                    if (AGXJK_EXPECT_F((key = AGXjk_object_for_token(parseState)) == NULL)) {                              AGXjk_error(parseState, @"Internal error: Key == NULL."); stopParsing = 1; break; }
                    else {
                        parseState->objectStack.keys[objectStackIndex] = key;
                        if (AGXJK_EXPECT_T(parseState->token.value.cacheItem != NULL)) { if (AGXJK_EXPECT_F(parseState->token.value.cacheItem->cfHash == 0UL)) { parseState->token.value.cacheItem->cfHash = CFHash(key); } parseState->objectStack.cfHashes[objectStackIndex] = parseState->token.value.cacheItem->cfHash; }
                        else { parseState->objectStack.cfHashes[objectStackIndex] = CFHash(key); }
                    }
                    break;

                case AGXJKTokenTypeObjectEnd: if ((AGXJK_EXPECT_T(dictState & AGXJKParseAcceptEnd)))   { NSCParameterAssert(parseState->objectStack.index >= startingObjectIndex); parsedDictionary = AGXjk_create_dictionary(parseState, startingObjectIndex); } else { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected '}'."); } stopParsing = 1; break;
                case AGXJKTokenTypeComma:     if ((AGXJK_EXPECT_T(dictState & AGXJKParseAcceptComma))) { dictState = AGXJKParseAcceptValue; parseState->objectStack.index--; continue; } else { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected ','."); stopParsing = 1; } break;

                default: parseState->errorIsPrev = 1; AGXjk_error_parse_accept_or3(parseState, dictState, @"a \"STRING\"", @"a comma", @"a '}'"); stopParsing = 1; break;
            }
        }

        if (AGXJK_EXPECT_T(stopParsing == 0)) {
            if (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_next_token(parseState)) == 0)) { if (AGXJK_EXPECT_F(parseState->token.type != AGXJKTokenTypeSeparator)) { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Expected ':'."); stopParsing = 1; } }
        }

        if ((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_next_token(parseState)) == 0))) {
            switch(parseState->token.type) {
                case AGXJKTokenTypeNumber:
                case AGXJKTokenTypeString:
                case AGXJKTokenTypeTrue:
                case AGXJKTokenTypeFalse:
                case AGXJKTokenTypeNull:
                case AGXJKTokenTypeArrayBegin:
                case AGXJKTokenTypeObjectBegin:
                    if (AGXJK_EXPECT_F((dictState & AGXJKParseAcceptValue)           == 0))    { parseState->errorIsPrev = 1; AGXjk_error(parseState, @"Unexpected value.");               stopParsing = 1; break; }
                    if (AGXJK_EXPECT_F((object = AGXjk_object_for_token(parseState)) == NULL)) {                              AGXjk_error(parseState, @"Internal error: Object == NULL."); stopParsing = 1; break; } else { parseState->objectStack.objects[objectStackIndex] = object; dictState = AGXJKParseAcceptCommaOrEnd; }
                    break;
                default: parseState->errorIsPrev = 1; AGXjk_error_parse_accept_or3(parseState, dictState, @"a value", @"a comma", @"a '}'"); stopParsing = 1; break;
            }
        }
    }

    if (AGXJK_EXPECT_F(parsedDictionary == NULL)) { size_t idx = 0UL; for(idx = startingObjectIndex; idx < parseState->objectStack.index; idx++) { if (parseState->objectStack.keys[idx] != NULL) { CFRelease(parseState->objectStack.keys[idx]); parseState->objectStack.keys[idx] = NULL; } if (parseState->objectStack.objects[idx] != NULL) { CFRelease(parseState->objectStack.objects[idx]); parseState->objectStack.objects[idx] = NULL; } } }
#if !defined(NS_BLOCK_ASSERTIONS)
    else { size_t idx = 0UL; for(idx = startingObjectIndex; idx < parseState->objectStack.index; idx++) { parseState->objectStack.objects[idx] = NULL; parseState->objectStack.keys[idx] = NULL; } }
#endif

    parseState->objectStack.index = startingObjectIndex;
    return(parsedDictionary);
}

static id AGXjson_parse_it(AGXJKParseState *parseState) {
    id  parsedObject = NULL;
    int stopParsing  = 0;

    while((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T(parseState->atIndex < parseState->stringBuffer.bytes.length))) {
        if ((AGXJK_EXPECT_T(stopParsing == 0)) && (AGXJK_EXPECT_T((stopParsing = AGXjk_parse_next_token(parseState)) == 0))) {
            switch(parseState->token.type) {
                case AGXJKTokenTypeArrayBegin:
                case AGXJKTokenTypeObjectBegin: parsedObject = AGX_AUTORELEASE((AGX_BRIDGE id)AGXjk_object_for_token(parseState)); stopParsing = 1; break;
                default:                     AGXjk_error(parseState, @"Expected either '[' or '{'.");             stopParsing = 1; break;
            }
        }
    }

    NSCParameterAssert((parseState->objectStack.index == 0) && (AGXJK_AT_STRING_PTR(parseState) <= AGXJK_END_STRING_PTR(parseState)));

    if ((parsedObject == NULL) && (AGXJK_AT_STRING_PTR(parseState) == AGXJK_END_STRING_PTR(parseState))) { AGXjk_error(parseState, @"Reached the end of the buffer."); }
    if (parsedObject == NULL) { AGXjk_error(parseState, @"Unable to parse JSON."); }

    if ((parsedObject != NULL) && (AGXJK_AT_STRING_PTR(parseState) < AGXJK_END_STRING_PTR(parseState))) {
        AGXjk_parse_skip_whitespace(parseState);
        if ((parsedObject != NULL) && ((parseState->parseOptionFlags & AGXJKParseOptionPermitTextAfterValidJSON) == 0) && (AGXJK_AT_STRING_PTR(parseState) < AGXJK_END_STRING_PTR(parseState))) {
            AGXjk_error(parseState, @"A valid JSON object was parsed but there were additional non-white-space characters remaining.");
            parsedObject = NULL;
        }
    }
    return(parsedObject);
}

////////////
#pragma mark -
#pragma mark Object cache

// This uses a Galois Linear Feedback Shift Register (LFSR) PRNG to pick which item in the cache to age. It has a period of (2^32)-1.
// NOTE: A LFSR *MUST* be initialized to a non-zero value and must always have a non-zero value. The LFSR is initalized to 1 in -initWithParseOptions:
AGXJK_STATIC_INLINE void AGXjk_cache_age(AGXJKParseState *parseState) {
    NSCParameterAssert((parseState != NULL) && (parseState->cache.prng_lfsr != 0U));
    parseState->cache.prng_lfsr = (parseState->cache.prng_lfsr >> 1) ^ ((0U - (parseState->cache.prng_lfsr & 1U)) & 0x80200003U);
    parseState->cache.age[parseState->cache.prng_lfsr & (parseState->cache.count - 1UL)] >>= 1;
}

// The object cache is nothing more than a hash table with open addressing collision resolution that is bounded by JK_CACHE_PROBES attempts.
//
// The hash table is a linear C array of JKTokenCacheItem.  The terms "item" and "bucket" are synonymous with the index in to the cache array, i.e. cache.items[bucket].
//
// Items in the cache have an age associated with them.  An items age is incremented using saturating unsigned arithmetic and decremeted using unsigned right shifts.
// Thus, an items age is managed using an AIMD policy- additive increase, multiplicative decrease.  All age calculations and manipulations are branchless.
// The primitive C type MUST be unsigned.  It is currently a "char", which allows (at a minimum and in practice) 8 bits.
//
// A "useable bucket" is a bucket that is not in use (never populated), or has an age == 0.
//
// When an item is found in the cache, it's age is incremented.
// If a useable bucket hasn't been found, the current item (bucket) is aged along with two random items.
//
// If a value is not found in the cache, and no useable bucket has been found, that value is not added to the cache.

static void *AGXjk_cachedObjects(AGXJKParseState *parseState) {
    unsigned long  bucket     = parseState->token.value.hash & (parseState->cache.count - 1UL), setBucket = 0UL, useableBucket = 0UL, x = 0UL;
    void          *parsedAtom = NULL;

    if (AGXJK_EXPECT_F(parseState->token.value.ptrRange.length == 0UL) && AGXJK_EXPECT_T(parseState->token.value.type == AGXJKValueTypeString)) { return(@""); }

    for(x = 0UL; x < AGXJK_CACHE_PROBES; x++) {
        if (AGXJK_EXPECT_F(parseState->cache.items[bucket].object == NULL)) { setBucket = 1UL; useableBucket = bucket; break; }

        if ((AGXJK_EXPECT_T(parseState->cache.items[bucket].hash == parseState->token.value.hash)) && (AGXJK_EXPECT_T(parseState->cache.items[bucket].size == parseState->token.value.ptrRange.length)) && (AGXJK_EXPECT_T(parseState->cache.items[bucket].type == parseState->token.value.type)) && (AGXJK_EXPECT_T(parseState->cache.items[bucket].bytes != NULL)) && (AGXJK_EXPECT_T(memcmp(parseState->cache.items[bucket].bytes, parseState->token.value.ptrRange.ptr, parseState->token.value.ptrRange.length) == 0U))) {
            parseState->cache.age[bucket]     = (((uint32_t)parseState->cache.age[bucket]) + 1U) - (((((uint32_t)parseState->cache.age[bucket]) + 1U) >> 31) ^ 1U);
            parseState->token.value.cacheItem = &parseState->cache.items[bucket];
            NSCParameterAssert(parseState->cache.items[bucket].object != NULL);
            return((void *)CFRetain(parseState->cache.items[bucket].object));
        } else {
            if (AGXJK_EXPECT_F(setBucket == 0UL) && AGXJK_EXPECT_F(parseState->cache.age[bucket] == 0U)) { setBucket = 1UL; useableBucket = bucket; }
            if (AGXJK_EXPECT_F(setBucket == 0UL))                                                     { parseState->cache.age[bucket] >>= 1; AGXjk_cache_age(parseState); AGXjk_cache_age(parseState); }
            // This is the open addressing function.  The values length and type are used as a form of "double hashing" to distribute values with the same effective value hash across different object cache buckets.
            // The values type is a prime number that is relatively coprime to the other primes in the set of value types and the number of hash table buckets.
            bucket = (parseState->token.value.hash + (parseState->token.value.ptrRange.length * (x + 1UL)) + (parseState->token.value.type * (x + 1UL)) + (3UL * (x + 1UL))) & (parseState->cache.count - 1UL);
        }
    }

    switch(parseState->token.value.type) {
        case AGXJKValueTypeString:           parsedAtom = (void *)CFStringCreateWithBytes(NULL, parseState->token.value.ptrRange.ptr, parseState->token.value.ptrRange.length, kCFStringEncodingUTF8, 0); break;
        case AGXJKValueTypeLongLong:         parsedAtom = (void *)CFNumberCreate(NULL, kCFNumberLongLongType, &parseState->token.value.number.longLongValue);                                             break;
        case AGXJKValueTypeUnsignedLongLong:
            if (parseState->token.value.number.unsignedLongLongValue <= LLONG_MAX) { parsedAtom = (void *)CFNumberCreate(NULL, kCFNumberLongLongType, &parseState->token.value.number.unsignedLongLongValue); }
            else { parsedAtom = (AGX_BRIDGE void *)parseState->objCImpCache.NSNumberInitWithUnsignedLongLong(parseState->objCImpCache.NSNumberAlloc(parseState->objCImpCache.NSNumberClass, @selector(alloc)), @selector(initWithUnsignedLongLong:), parseState->token.value.number.unsignedLongLongValue); }
            break;
        case AGXJKValueTypeDouble:           parsedAtom = (void *)CFNumberCreate(NULL, kCFNumberDoubleType,   &parseState->token.value.number.doubleValue);                                               break;
        default: AGXjk_error(parseState, @"Internal error: Unknown token value type. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); break;
    }

    if (AGXJK_EXPECT_T(setBucket) && (AGXJK_EXPECT_T(parsedAtom != NULL))) {
        bucket = useableBucket;
        if (AGXJK_EXPECT_T((parseState->cache.items[bucket].object != NULL))) { CFRelease(parseState->cache.items[bucket].object); parseState->cache.items[bucket].object = NULL; }

        if (AGXJK_EXPECT_T((parseState->cache.items[bucket].bytes = (unsigned char *)reallocf(parseState->cache.items[bucket].bytes, parseState->token.value.ptrRange.length)) != NULL)) {
            memcpy(parseState->cache.items[bucket].bytes, parseState->token.value.ptrRange.ptr, parseState->token.value.ptrRange.length);
            parseState->cache.items[bucket].object = (void *)CFRetain(parsedAtom);
            parseState->cache.items[bucket].hash   = parseState->token.value.hash;
            parseState->cache.items[bucket].cfHash = 0UL;
            parseState->cache.items[bucket].size   = parseState->token.value.ptrRange.length;
            parseState->cache.items[bucket].type   = parseState->token.value.type;
            parseState->token.value.cacheItem      = &parseState->cache.items[bucket];
            parseState->cache.age[bucket]          = AGXJK_INIT_CACHE_AGE;
        } else { // The realloc failed, so clear the appropriate fields.
            parseState->cache.items[bucket].hash   = 0UL;
            parseState->cache.items[bucket].cfHash = 0UL;
            parseState->cache.items[bucket].size   = 0UL;
            parseState->cache.items[bucket].type   = 0UL;
        }
    }
    return(parsedAtom);
}

static void *AGXjk_object_for_token(AGXJKParseState *parseState) {
    void *parsedAtom = NULL;

    parseState->token.value.cacheItem = NULL;
    switch(parseState->token.type) {
        case AGXJKTokenTypeString:      parsedAtom = AGXjk_cachedObjects(parseState);    break;
        case AGXJKTokenTypeNumber:      parsedAtom = AGXjk_cachedObjects(parseState);    break;
        case AGXJKTokenTypeObjectBegin: parsedAtom = AGXjk_parse_dictionary(parseState); break;
        case AGXJKTokenTypeArrayBegin:  parsedAtom = AGXjk_parse_array(parseState);      break;
        case AGXJKTokenTypeTrue:        parsedAtom = (void *)kCFBooleanTrue;             break;
        case AGXJKTokenTypeFalse:       parsedAtom = (void *)kCFBooleanFalse;            break;
        case AGXJKTokenTypeNull:        parsedAtom = (void *)kCFNull;                    break;
        default: AGXjk_error(parseState, @"Internal error: Unknown token type. %@ line #%ld", [NSString stringWithUTF8String:__FILE__], (long)__LINE__); break;
    }
    return(parsedAtom);
}

#pragma mark -
@implementation AGXJSONDecoder

+ (id)decoder {
    return([self decoderWithParseOptions:AGXJKParseOptionStrict]);
}

+ (id)decoderWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags {
    return(AGX_AUTORELEASE([[self alloc] initWithParseOptions:parseOptionFlags]));
}

- (id)init {
    return([self initWithParseOptions:AGXJKParseOptionStrict]);
}

- (id)initWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags {
    if ((self = [super init]) == NULL) { return(NULL); }

    if (parseOptionFlags & ~AGXJKParseOptionValidFlags) { AGX_JUST_AUTORELEASE(self); [NSException raise:NSInvalidArgumentException format:@"Invalid parse options."]; }

    if ((parseState = (AGXJKParseState *)calloc(1UL, sizeof(AGXJKParseState))) == NULL) { goto errorExit; }

    parseState->parseOptionFlags = parseOptionFlags;

    parseState->token.tokenBuffer.roundSizeUpToMultipleOf = 4096UL;
    parseState->objectStack.roundSizeUpToMultipleOf       = 2048UL;

    parseState->objCImpCache.NSNumberClass                    = _AGXjk_NSNumberClass;
    parseState->objCImpCache.NSNumberAlloc                    = _AGXjk_NSNumberAllocImp;
    parseState->objCImpCache.NSNumberInitWithUnsignedLongLong = _AGXjk_NSNumberInitWithUnsignedLongLongImp;

    parseState->cache.prng_lfsr = 1U;
    parseState->cache.count     = AGXJK_CACHE_SLOTS;
    if ((parseState->cache.items = (AGXJKTokenCacheItem *)calloc(1UL, sizeof(AGXJKTokenCacheItem) * parseState->cache.count)) == NULL) { goto errorExit; }
    return(self);

errorExit:
    if (self) { AGX_JUST_AUTORELEASE(self); self = NULL; }
    return(NULL);
}

// This is here primarily to support the NSString and NSData convenience functions so the autoreleased JSONDecoder can release most of its resources before the pool pops.
static void _AGXJSONDecoderCleanup(AGXJSONDecoder *decoder) {
    if ((decoder != NULL) && (decoder->parseState != NULL)) {
        AGXjk_error_release(&decoder->parseState->error);
        AGXjk_managedBuffer_release(&decoder->parseState->token.tokenBuffer);
        AGXjk_objectStack_release(&decoder->parseState->objectStack);

        [decoder clearCache];
        if (decoder->parseState->cache.items != NULL) { free(decoder->parseState->cache.items); decoder->parseState->cache.items = NULL; }

        free(decoder->parseState); decoder->parseState = NULL;
    }
}

- (void)dealloc {
    _AGXJSONDecoderCleanup(self);
    AGX_SUPER_DEALLOC;
}

- (void)clearCache {
    if (AGXJK_EXPECT_T(parseState != NULL)) {
        if (AGXJK_EXPECT_T(parseState->cache.items != NULL)) {
            size_t idx = 0UL;
            for(idx = 0UL; idx < parseState->cache.count; idx++) {
                if (AGXJK_EXPECT_T(parseState->cache.items[idx].object != NULL)) { CFRelease(parseState->cache.items[idx].object); parseState->cache.items[idx].object = NULL; }
                if (AGXJK_EXPECT_T(parseState->cache.items[idx].bytes  != NULL)) { free(parseState->cache.items[idx].bytes);       parseState->cache.items[idx].bytes  = NULL; }
                memset(&parseState->cache.items[idx], 0, sizeof(AGXJKTokenCacheItem));
                parseState->cache.age[idx] = 0U;
            }
        }
    }
}

// This needs to be completely rewritten.
static id _AGXJKParseUTF8String(AGXJKParseState *parseState, BOOL mutableCollections, const unsigned char *string, size_t length, NSError **error) {
    NSCParameterAssert((parseState != NULL) && (string != NULL) && (parseState->cache.prng_lfsr != 0U));
    parseState->stringBuffer.bytes.ptr    = string;
    parseState->stringBuffer.bytes.length = length;
    parseState->atIndex                   = 0UL;
    parseState->lineNumber                = 1UL;
    parseState->lineStartIndex            = 0UL;
    parseState->prev_atIndex              = 0UL;
    parseState->prev_lineNumber           = 1UL;
    parseState->prev_lineStartIndex       = 0UL;
    parseState->error.domain              = NULL;
    parseState->error.code                = 0L;
    parseState->error.desc                = NULL;
    parseState->errorIsPrev               = 0;
    parseState->mutableCollections        = (mutableCollections == NO) ? NO : YES;

    unsigned char stackTokenBuffer[AGXJK_TOKENBUFFER_SIZE] AGXJK_ALIGNED(64);
    AGXjk_managedBuffer_setToStackBuffer(&parseState->token.tokenBuffer, stackTokenBuffer, sizeof(stackTokenBuffer));

    void       *stackObjects [AGXJK_STACK_OBJS] AGXJK_ALIGNED(64);
    void       *stackKeys    [AGXJK_STACK_OBJS] AGXJK_ALIGNED(64);
    CFHashCode  stackCFHashes[AGXJK_STACK_OBJS] AGXJK_ALIGNED(64);
    AGXjk_objectStack_setToStackBuffer(&parseState->objectStack, stackObjects, stackKeys, stackCFHashes, AGXJK_STACK_OBJS);

    id parsedJSON = AGXjson_parse_it(parseState);

    AGXjk_build_ns_error_from_jk_error_and_location(error, parseState->error, parseState->atIndex, parseState->lineNumber);

    AGXjk_error_release(&parseState->error);
    AGXjk_managedBuffer_release(&parseState->token.tokenBuffer);
    AGXjk_objectStack_release(&parseState->objectStack);

    parseState->stringBuffer.bytes.ptr    = NULL;
    parseState->stringBuffer.bytes.length = 0UL;
    parseState->atIndex                   = 0UL;
    parseState->lineNumber                = 1UL;
    parseState->lineStartIndex            = 0UL;
    parseState->prev_atIndex              = 0UL;
    parseState->prev_lineNumber           = 1UL;
    parseState->prev_lineStartIndex       = 0UL;
    parseState->errorIsPrev               = 0;
    parseState->mutableCollections        = NO;
    return(parsedJSON);
}

////////////
#pragma mark Methods that return immutable collection objects
////////////

- (id)objectWithUTF8String:(const unsigned char *)string length:(NSUInteger)length {
    return([self objectWithUTF8String:string length:length error:NULL]);
}

- (id)objectWithUTF8String:(const unsigned char *)string length:(NSUInteger)length error:(NSError **)error {
    if (parseState == NULL) { [NSException raise:NSInternalInconsistencyException format:@"parseState is NULL."];          }
    if (string     == NULL) { [NSException raise:NSInvalidArgumentException       format:@"The string argument is NULL."]; }

    return(_AGXJKParseUTF8String(parseState, NO, string, (size_t)length, error));
}

- (id)objectWithData:(NSData *)jsonData {
    return([self objectWithData:jsonData error:NULL]);
}

- (id)objectWithData:(NSData *)jsonData error:(NSError **)error {
    if (jsonData == NULL) { [NSException raise:NSInvalidArgumentException format:@"The jsonData argument is NULL."]; }
    return([self objectWithUTF8String:(const unsigned char *)[jsonData bytes] length:[jsonData length] error:error]);
}

////////////
#pragma mark Methods that return mutable collection objects
////////////

- (id)mutableObjectWithUTF8String:(const unsigned char *)string length:(NSUInteger)length {
    return([self mutableObjectWithUTF8String:string length:length error:NULL]);
}

- (id)mutableObjectWithUTF8String:(const unsigned char *)string length:(NSUInteger)length error:(NSError **)error {
    if (parseState == NULL) { [NSException raise:NSInternalInconsistencyException format:@"parseState is NULL."];          }
    if (string     == NULL) { [NSException raise:NSInvalidArgumentException       format:@"The string argument is NULL."]; }

    return(_AGXJKParseUTF8String(parseState, YES, string, (size_t)length, error));
}

- (id)mutableObjectWithData:(NSData *)jsonData {
    return([self mutableObjectWithData:jsonData error:NULL]);
}

- (id)mutableObjectWithData:(NSData *)jsonData error:(NSError **)error {
    if (jsonData == NULL) { [NSException raise:NSInvalidArgumentException format:@"The jsonData argument is NULL."]; }
    return([self mutableObjectWithUTF8String:(const unsigned char *)[jsonData bytes] length:[jsonData length] error:error]);
}

@end

/*
 The NSString and NSData convenience methods need a little bit of explanation.
 
 Prior to JSONKit v1.4, the NSString -objectFromJSONStringWithParseOptions:error: method looked like
 
 const unsigned char *utf8String = (const unsigned char *)[self UTF8String];
 if (utf8String == NULL) { return(NULL); }
 size_t               utf8Length = strlen((const char *)utf8String);
 return([[JSONDecoder decoderWithParseOptions:parseOptionFlags] parseUTF8String:utf8String length:utf8Length error:error]);
 
 This changed with v1.4 to a more complicated method.  The reason for this is to keep the amount of memory that is
 allocated, but not yet freed because it is dependent on the autorelease pool to pop before it can be reclaimed.
 
 In the simpler v1.3 code, this included all the bytes used to store the -UTF8String along with the JSONDecoder and all its overhead.
 
 Now we use an autoreleased CFMutableData that is sized to the UTF8 length of the NSString in question and is used to hold the UTF8
 conversion of said string.
 
 Once parsed, the CFMutableData has its length set to 0.  This should, hopefully, allow the CFMutableData to realloc and/or free
 the buffer.
 
 Another change made was a slight modification to JSONDecoder so that most of the cleanup work that was done in -dealloc was moved
 to a private, internal function.  These convenience routines keep the pointer to the autoreleased JSONDecoder and calls
 _JSONDecoderCleanup() to early release the decoders resources since we already know that particular decoder is not going to be used
 again.
 
 If everything goes smoothly, this will most likely result in perhaps a few hundred bytes that are allocated but waiting for the
 autorelease pool to pop.  This is compared to the thousands and easily hundreds of thousands of bytes that would have been in
 autorelease limbo.  It's more complicated for us, but a win for the user.
 
 Autorelease objects are used in case things don't go smoothly.  By having them autoreleased, we effectively guarantee that our
 requirement to -release the object is always met, not matter what goes wrong.  The downside is having a an object or two in
 autorelease limbo, but we've done our best to minimize that impact, so it all balances out.
 */

@category_implementation(NSString, AGXJSONKitDeserializing)

static id _NSStringObjectFromAGXJSONString(NSString *jsonString, AGXJKParseOptionFlags parseOptionFlags, NSError **error, BOOL mutableCollection) {
    id                returnObject = NULL;
    CFMutableDataRef  mutableData  = NULL;
    AGXJSONDecoder   *decoder      = NULL;

    CFIndex    stringLength     = CFStringGetLength((CFStringRef)jsonString);
    NSUInteger stringUTF8Length = [jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    CFBridgingRelease(@"");
    if ((mutableData = CFDataCreateMutable(NULL, (NSUInteger)stringUTF8Length)) != NULL) {
        UInt8   *utf8String = CFDataGetMutableBytePtr(mutableData);
        CFIndex  usedBytes  = 0L, convertedCount = 0L;

        convertedCount = CFStringGetBytes((CFStringRef)jsonString, CFRangeMake(0L, stringLength), kCFStringEncodingUTF8, '?', NO, utf8String, (NSUInteger)stringUTF8Length, &usedBytes);
        if (AGXJK_EXPECT_F(convertedCount != stringLength) || AGXJK_EXPECT_F(usedBytes < 0L)) { if (error != NULL) { *error = [NSError errorWithDomain:@"JKErrorDomain" code:-1L userInfo:[NSDictionary dictionaryWithObject:@"An error occurred converting the contents of a NSString to UTF8." forKey:NSLocalizedDescriptionKey]]; } goto exitNow; }

        if (mutableCollection == NO) { returnObject = [(decoder = [AGXJSONDecoder decoderWithParseOptions:parseOptionFlags])        objectWithUTF8String:(const unsigned char *)utf8String length:(size_t)usedBytes error:error]; }
        else                        { returnObject = [(decoder = [AGXJSONDecoder decoderWithParseOptions:parseOptionFlags]) mutableObjectWithUTF8String:(const unsigned char *)utf8String length:(size_t)usedBytes error:error]; }
    }

exitNow:
    if (mutableData != NULL) { CFDataSetLength(mutableData, 0L); CFRelease(mutableData); }
    if (decoder     != NULL) { _AGXJSONDecoderCleanup(decoder);                             }
    return(returnObject);
}

- (id)objectFromAGXJSONString {
    return([self objectFromAGXJSONStringWithParseOptions:AGXJKParseOptionStrict error:NULL]);
}

- (id)objectFromAGXJSONStringWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags {
    return([self objectFromAGXJSONStringWithParseOptions:parseOptionFlags error:NULL]);
}

- (id)objectFromAGXJSONStringWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags error:(NSError **)error {
    return(_NSStringObjectFromAGXJSONString(self, parseOptionFlags, error, NO));
}

- (id)mutableObjectFromAGXJSONString {
    return([self mutableObjectFromAGXJSONStringWithParseOptions:AGXJKParseOptionStrict error:NULL]);
}

- (id)mutableObjectFromAGXJSONStringWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags {
    return([self mutableObjectFromAGXJSONStringWithParseOptions:parseOptionFlags error:NULL]);
}

- (id)mutableObjectFromAGXJSONStringWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags error:(NSError **)error {
    return(_NSStringObjectFromAGXJSONString(self, parseOptionFlags, error, YES));
}

@end

@category_implementation(NSData, AGXJSONKitDeserializing)

- (id)objectFromAGXJSONData {
    return([self objectFromAGXJSONDataWithParseOptions:AGXJKParseOptionStrict error:NULL]);
}

- (id)objectFromAGXJSONDataWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags {
    return([self objectFromAGXJSONDataWithParseOptions:parseOptionFlags error:NULL]);
}

- (id)objectFromAGXJSONDataWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags error:(NSError **)error {
    AGXJSONDecoder *decoder = NULL;
    id returnObject = [(decoder = [AGXJSONDecoder decoderWithParseOptions:parseOptionFlags]) objectWithData:self error:error];
    if (decoder != NULL) { _AGXJSONDecoderCleanup(decoder); }
    return(returnObject);
}

- (id)mutableObjectFromAGXJSONData {
    return([self mutableObjectFromAGXJSONDataWithParseOptions:AGXJKParseOptionStrict error:NULL]);
}

- (id)mutableObjectFromAGXJSONDataWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags {
    return([self mutableObjectFromAGXJSONDataWithParseOptions:parseOptionFlags error:NULL]);
}

- (id)mutableObjectFromAGXJSONDataWithParseOptions:(AGXJKParseOptionFlags)parseOptionFlags error:(NSError **)error {
    AGXJSONDecoder *decoder = NULL;
    id returnObject = [(decoder = [AGXJSONDecoder decoderWithParseOptions:parseOptionFlags]) mutableObjectWithData:self error:error];
    if (decoder != NULL) { _AGXJSONDecoderCleanup(decoder); }
    return(returnObject);
}

@end

////////////
#pragma mark -
#pragma mark Encoding / deserializing functions

static void AGXjk_encode_error(AGXJKEncodeState *encodeState, NSString *format, ...) {
    NSCParameterAssert((encodeState != NULL) && (format != NULL));

    va_list varArgsList;
    va_start(varArgsList, format);
    NSString *formatString = AGX_AUTORELEASE([[NSString alloc] initWithFormat:format arguments:varArgsList]);
    va_end(varArgsList);

    AGXjk_error_set(&encodeState->error, @"JKErrorDomain", -1L, formatString);
}

AGXJK_STATIC_INLINE void AGXjk_encode_updateCache(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object) {
    NSCParameterAssert(encodeState != NULL);
    if (AGXJK_EXPECT_T(cacheSlot != NULL)) {
        NSCParameterAssert((object != NULL) && (startingAtIndex <= encodeState->atIndex));
        cacheSlot->object = (AGX_BRIDGE void *)(object);
        cacheSlot->offset = startingAtIndex;
        cacheSlot->length = (size_t)(encodeState->atIndex - startingAtIndex);
    }
}

static int AGXjk_encode_printf(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object, const char *format, ...) {
    va_list varArgsList, varArgsListCopy;
    va_start(varArgsList, format);
    va_copy(varArgsListCopy, varArgsList);

    NSCParameterAssert((encodeState != NULL) && (encodeState->atIndex < encodeState->stringBuffer.bytes.length) && (startingAtIndex <= encodeState->atIndex) && (format != NULL));

    ssize_t  formattedStringLength = 0L;
    int      returnValue           = 0;

    if (AGXJK_EXPECT_T((formattedStringLength = vsnprintf((char *)&encodeState->stringBuffer.bytes.ptr[encodeState->atIndex], (encodeState->stringBuffer.bytes.length - encodeState->atIndex), format, varArgsList)) >= (ssize_t)(encodeState->stringBuffer.bytes.length - encodeState->atIndex))) {
        NSCParameterAssert(((encodeState->atIndex + (formattedStringLength * 2UL) + 256UL) > encodeState->stringBuffer.bytes.length));
        if (AGXJK_EXPECT_F(((encodeState->atIndex + (formattedStringLength * 2UL) + 256UL) > encodeState->stringBuffer.bytes.length)) && AGXJK_EXPECT_F((AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + (formattedStringLength * 2UL)+ 4096UL) == NULL))) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); returnValue = 1; goto exitNow; }
        if (AGXJK_EXPECT_F((formattedStringLength = vsnprintf((char *)&encodeState->stringBuffer.bytes.ptr[encodeState->atIndex], (encodeState->stringBuffer.bytes.length - encodeState->atIndex), format, varArgsListCopy)) >= (ssize_t)(encodeState->stringBuffer.bytes.length - encodeState->atIndex))) { AGXjk_encode_error(encodeState, @"vsnprintf failed unexpectedly."); returnValue = 1; goto exitNow; }
    }

exitNow:
    va_end(varArgsList);
    va_end(varArgsListCopy);
    if (AGXJK_EXPECT_T(returnValue == 0)) { encodeState->atIndex += formattedStringLength; AGXjk_encode_updateCache(encodeState, cacheSlot, startingAtIndex, object); }
    return(returnValue);
}

static int AGXjk_encode_write(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object, const char *format) {
    NSCParameterAssert((encodeState != NULL) && (encodeState->atIndex < encodeState->stringBuffer.bytes.length) && (startingAtIndex <= encodeState->atIndex) && (format != NULL));
    if (AGXJK_EXPECT_F(((encodeState->atIndex + strlen(format) + 256UL) > encodeState->stringBuffer.bytes.length)) && AGXJK_EXPECT_F((AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + strlen(format) + 1024UL) == NULL))) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }

    size_t formatIdx = 0UL;
    for(formatIdx = 0UL; format[formatIdx] != 0; formatIdx++) { NSCParameterAssert(encodeState->atIndex < encodeState->stringBuffer.bytes.length); encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = format[formatIdx]; }
    AGXjk_encode_updateCache(encodeState, cacheSlot, startingAtIndex, object);
    return(0);
}

static int AGXjk_encode_writePrettyPrintWhiteSpace(AGXJKEncodeState *encodeState) {
    NSCParameterAssert((encodeState != NULL) && ((encodeState->serializeOptionFlags & AGXJKSerializeOptionPretty) != 0UL));
    if (AGXJK_EXPECT_F((encodeState->atIndex + ((encodeState->depth + 1UL) * 2UL) + 16UL) > encodeState->stringBuffer.bytes.length) && AGXJK_EXPECT_T(AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + ((encodeState->depth + 1UL) * 2UL) + 4096UL) == NULL)) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }
    encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\n';
    size_t depthWhiteSpace = 0UL;
    for(depthWhiteSpace = 0UL; depthWhiteSpace < (encodeState->depth * 2UL); depthWhiteSpace++) { NSCParameterAssert(encodeState->atIndex < encodeState->stringBuffer.bytes.length); encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = ' '; }
    return(0);
}

static int AGXjk_encode_write1slow(AGXJKEncodeState *encodeState, ssize_t depthChange, const char *format) {
    NSCParameterAssert((encodeState != NULL) && (encodeState->atIndex < encodeState->stringBuffer.bytes.length) && (format != NULL) && ((depthChange >= -1L) && (depthChange <= 1L)) && ((encodeState->depth == 0UL) ? (depthChange >= 0L) : 1) && ((encodeState->serializeOptionFlags & AGXJKSerializeOptionPretty) != 0UL));
    if (AGXJK_EXPECT_F((encodeState->atIndex + ((encodeState->depth + 1UL) * 2UL) + 16UL) > encodeState->stringBuffer.bytes.length) && AGXJK_EXPECT_F(AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + ((encodeState->depth + 1UL) * 2UL) + 4096UL) == NULL)) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }
    encodeState->depth += depthChange;
    if (AGXJK_EXPECT_T(format[0] == ':')) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = format[0]; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = ' '; }
    else {
        if (AGXJK_EXPECT_F(depthChange == -1L)) { if (AGXJK_EXPECT_F(AGXjk_encode_writePrettyPrintWhiteSpace(encodeState))) { return(1); } }
        encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = format[0];
        if (AGXJK_EXPECT_T(depthChange != -1L)) { if (AGXJK_EXPECT_F(AGXjk_encode_writePrettyPrintWhiteSpace(encodeState))) { return(1); } }
    }
    NSCParameterAssert(encodeState->atIndex < encodeState->stringBuffer.bytes.length);
    return(0);
}

static int AGXjk_encode_write1fast(AGXJKEncodeState *encodeState, ssize_t depthChange AGXJK_UNUSED_ARG, const char *format) {
    NSCParameterAssert((encodeState != NULL) && (encodeState->atIndex < encodeState->stringBuffer.bytes.length) && ((encodeState->serializeOptionFlags & AGXJKSerializeOptionPretty) == 0UL));
    if (AGXJK_EXPECT_T((encodeState->atIndex + 4UL) < encodeState->stringBuffer.bytes.length)) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = format[0]; }
    else { return(AGXjk_encode_write(encodeState, NULL, 0UL, NULL, format)); }
    return(0);
}

static int AGXjk_encode_writen(AGXJKEncodeState *encodeState, AGXJKEncodeCache *cacheSlot, size_t startingAtIndex, id object, const char *format, size_t length) {
    NSCParameterAssert((encodeState != NULL) && (encodeState->atIndex < encodeState->stringBuffer.bytes.length) && (startingAtIndex <= encodeState->atIndex));
    if (AGXJK_EXPECT_F((encodeState->stringBuffer.bytes.length - encodeState->atIndex) < (length + 4UL))) { if (AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + 4096UL + length) == NULL) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); } }
    memcpy(encodeState->stringBuffer.bytes.ptr + encodeState->atIndex, format, length);
    encodeState->atIndex += length;
    AGXjk_encode_updateCache(encodeState, cacheSlot, startingAtIndex, object);
    return(0);
}

AGXJK_STATIC_INLINE AGXJKHash AGXjk_encode_object_hash(const void *objectPtr) {
    return( ( (((AGXJKHash)objectPtr) >> 21) ^ (((AGXJKHash)objectPtr) >> 9)   ) + (((AGXJKHash)objectPtr) >> 4) );
}

// XXX XXX XXX XXX
//
//     We need to work around a bug in 10.7, which breaks ABI compatibility with Objective-C going back not just to 10.0, but OpenStep and even NextStep.
//
//     It has long been documented that "the very first thing that a pointer to an Objective-C object "points to" is a pointer to that objects class".
//
//     This is euphemistically called "tagged pointers".  There are a number of highly technical problems with this, most involving long passages from
//     the C standard(s).  In short, one can make a strong case, couched from the perspective of the C standard(s), that that 10.7 "tagged pointers" are
//     fundamentally Wrong and Broken, and should have never been implemented.  Assuming those points are glossed over, because the change is very clearly
//     breaking ABI compatibility, this should have resulted in a minimum of a "minimum version required" bump in various shared libraries to prevent
//     causes code that used to work just fine to suddenly break without warning.
//
//     In fact, the C standard says that the hack below is "undefined behavior"- there is no requirement that the 10.7 tagged pointer hack of setting the
//     "lower, unused bits" must be preserved when casting the result to an integer type, but this "works" because for most architectures
//     `sizeof(long) == sizeof(void *)` and the compiler uses the same representation for both.  (note: this is informal, not meant to be
//     normative or pedantically correct).
//
//     In other words, while this "works" for now, technically the compiler is not obligated to do "what we want", and a later version of the compiler
//     is not required in any way to produce the same results or behavior that earlier versions of the compiler did for the statement below.
//
//     Fan-fucking-tastic.
//
//     Why not just use `object_getClass()`?  Because `object->isa` reduces to (typically) a *single* instruction.  Calling `object_getClass()` requires
//     that the compiler potentially spill registers, establish a function call frame / environment, and finally execute a "jump subroutine" instruction.
//     Then, the called subroutine must spend half a dozen instructions in its prolog, however many instructions doing whatever it does, then half a dozen
//     instructions in its prolog.  One instruction compared to dozens, maybe a hundred instructions.
//
//     Yes, that's one to two orders of magnitude difference.  Which is compelling in its own right.  When going for performance, you're often happy with
//     gains in the two to three percent range.
//
// XXX XXX XXX XXX

#if AGXJK_SUPPORT_TAGGED_POINTERS
AGXJK_STATIC_INLINE BOOL AGXjk_is_tagged_pointer(const void *objectPtr) {
#if AGXJK_SUPPORT_MSB_TAGGED_POINTERS
    return(((intptr_t)objectPtr) < 0);
#else
    return(((uintptr_t)objectPtr) & 0x1);
#endif
}

AGXJK_STATIC_INLINE uintptr_t AGXjk_get_tagged_pointer_tag(const void *objectPtr) {
#if AGXJK_SUPPORT_MSB_TAGGED_POINTERS
    return(((uintptr_t)objectPtr) >> 60);
#else
    return(((uintptr_t)objectPtr) & 0x0F);
#endif
}
#endif // AGXJK_SUPPORT_TAGGED_POINTERS

AGXJK_STATIC_INLINE int AGXjk_object_class(AGXJKEncodeState *encodeState, id object) {
#if AGXJK_SUPPORT_TAGGED_POINTERS
    if (AGXjk_is_tagged_pointer((AGX_BRIDGE const void *)(object))) {
        uintptr_t objectTag = AGXjk_get_tagged_pointer_tag((AGX_BRIDGE const void *)(object));

        if (AGXJK_EXPECT_T(objectTag == encodeState->fastTagLookup.stringClass)) { return(AGXJKClassString); }
        else if (AGXJK_EXPECT_T(objectTag == encodeState->fastTagLookup.numberClass)) { return(AGXJKClassNumber); }
        else if (AGXJK_EXPECT_T(objectTag == encodeState->fastTagLookup.dictionaryClass)) { return(AGXJKClassDictionary); }
        else if (AGXJK_EXPECT_T(objectTag == encodeState->fastTagLookup.arrayClass)) { return(AGXJKClassArray); }
        else if (AGXJK_EXPECT_T(objectTag == encodeState->fastTagLookup.nullClass)) { return(AGXJKClassNull); }
        else {
            if (AGXJK_EXPECT_T([object isKindOfClass:[NSString class]]))
            { encodeState->fastTagLookup.stringClass = objectTag; return(AGXJKClassString); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSNumber class]]))
            { encodeState->fastTagLookup.numberClass = objectTag; return(AGXJKClassNumber); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSDictionary class]]))
            { encodeState->fastTagLookup.dictionaryClass = objectTag; return(AGXJKClassDictionary); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSArray class]]))
            { encodeState->fastTagLookup.arrayClass = objectTag; return(AGXJKClassArray); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSNull class]]))
            { encodeState->fastTagLookup.nullClass = objectTag; return(AGXJKClassNull); }
        }
    }
    else {
#endif // AGXJK_SUPPORT_TAGGED_POINTERS
        void     *objectISA = *((void **)((AGX_BRIDGE void *)object));

        if (AGXJK_EXPECT_T(objectISA == encodeState->fastClassLookup.stringClass)) { return(AGXJKClassString); }
        else if (AGXJK_EXPECT_T(objectISA == encodeState->fastClassLookup.numberClass)) { return(AGXJKClassNumber); }
        else if (AGXJK_EXPECT_T(objectISA == encodeState->fastClassLookup.dictionaryClass)) { return(AGXJKClassDictionary); }
        else if (AGXJK_EXPECT_T(objectISA == encodeState->fastClassLookup.arrayClass)) { return(AGXJKClassArray); }
        else if (AGXJK_EXPECT_T(objectISA == encodeState->fastClassLookup.nullClass)) { return(AGXJKClassNull); }
        else {
            if (AGXJK_EXPECT_T([object isKindOfClass:[NSString class]]))
            { encodeState->fastClassLookup.stringClass = objectISA; return(AGXJKClassString); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSNumber class]]))
            { encodeState->fastClassLookup.numberClass = objectISA; return(AGXJKClassNumber); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSDictionary class]]))
            { encodeState->fastClassLookup.dictionaryClass = objectISA; return(AGXJKClassDictionary); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSArray class]]))
            { encodeState->fastClassLookup.arrayClass = objectISA; return(AGXJKClassArray); }
            else if (AGXJK_EXPECT_T([object isKindOfClass:[NSNull class]]))
            { encodeState->fastClassLookup.nullClass = objectISA; return(AGXJKClassNull); }
        }
#if AGXJK_SUPPORT_TAGGED_POINTERS
    }
#endif
    return(AGXJKClassUnknown);
}

AGXJK_STATIC_INLINE BOOL AGXjk_object_is_string(AGXJKEncodeState *encodeState, id object) {
#if AGXJK_SUPPORT_TAGGED_POINTERS
    if (AGXjk_is_tagged_pointer((AGX_BRIDGE const void *)(object))) {
        uintptr_t objectTag = AGXjk_get_tagged_pointer_tag((AGX_BRIDGE const void *)(object));

        if (AGXJK_EXPECT_T(objectTag == encodeState->fastTagLookup.stringClass))   {                                                       return(YES); }
        else if (AGXJK_EXPECT_T([object isKindOfClass:[NSString class]]))          { encodeState->fastTagLookup.stringClass   = objectTag; return(YES); }
    }
    else {
#endif // AGXJK_SUPPORT_TAGGED_POINTERS
        void     *objectISA = *((void **)((AGX_BRIDGE void *)object));

        if (AGXJK_EXPECT_T(objectISA == encodeState->fastClassLookup.stringClass)) {                                                       return(YES); }
        else if (AGXJK_EXPECT_T([object isKindOfClass:[NSString class]]))          { encodeState->fastClassLookup.stringClass = objectISA; return(YES); }
#if AGXJK_SUPPORT_TAGGED_POINTERS
    }
#endif
    return(NO);
}

static int AGXjk_encode_add_atom_to_buffer(AGXJKEncodeState *encodeState, const void *objectPtr) {
    NSCParameterAssert((encodeState != NULL) && (encodeState->atIndex < encodeState->stringBuffer.bytes.length) && (objectPtr != NULL));

    id     object          = (AGX_BRIDGE id)objectPtr, encodeCacheObject = object;
    int    isClass         = AGXJKClassUnknown;
    size_t startingAtIndex = encodeState->atIndex;

    AGXJKHash         objectHash = AGXjk_encode_object_hash(objectPtr);
    AGXJKEncodeCache *cacheSlot  = &encodeState->cache[objectHash % AGXJK_ENCODE_CACHE_SLOTS];

    if (AGXJK_EXPECT_T(cacheSlot->object == (AGX_BRIDGE void *)object)) {
        NSCParameterAssert((cacheSlot->object != NULL) &&
                           (cacheSlot->offset < encodeState->atIndex)                   && ((cacheSlot->offset + cacheSlot->length) < encodeState->atIndex)                                    &&
                           (cacheSlot->offset < encodeState->stringBuffer.bytes.length) && ((cacheSlot->offset + cacheSlot->length) < encodeState->stringBuffer.bytes.length)                  &&
                           ((encodeState->stringBuffer.bytes.ptr + encodeState->atIndex)                     < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)) &&
                           ((encodeState->stringBuffer.bytes.ptr + cacheSlot->offset)                        < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)) &&
                           ((encodeState->stringBuffer.bytes.ptr + cacheSlot->offset + cacheSlot->length)    < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)));
        if (AGXJK_EXPECT_F(((encodeState->atIndex + cacheSlot->length + 256UL) > encodeState->stringBuffer.bytes.length)) && AGXJK_EXPECT_F((AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + cacheSlot->length + 1024UL) == NULL))) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }
        NSCParameterAssert(((encodeState->atIndex + cacheSlot->length) < encodeState->stringBuffer.bytes.length) &&
                           ((encodeState->stringBuffer.bytes.ptr + encodeState->atIndex)                     < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)) &&
                           ((encodeState->stringBuffer.bytes.ptr + encodeState->atIndex + cacheSlot->length) < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)) &&
                           ((encodeState->stringBuffer.bytes.ptr + cacheSlot->offset)                        < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)) &&
                           ((encodeState->stringBuffer.bytes.ptr + cacheSlot->offset + cacheSlot->length)    < (encodeState->stringBuffer.bytes.ptr + encodeState->stringBuffer.bytes.length)) &&
                           ((encodeState->stringBuffer.bytes.ptr + cacheSlot->offset + cacheSlot->length)    < (encodeState->stringBuffer.bytes.ptr + encodeState->atIndex)));
        memcpy(encodeState->stringBuffer.bytes.ptr + encodeState->atIndex, encodeState->stringBuffer.bytes.ptr + cacheSlot->offset, cacheSlot->length);
        encodeState->atIndex += cacheSlot->length;
        return(0);
    }

    // When we encounter a class that we do not handle, and we have either a delegate or block that the user supplied to format unsupported classes,
    // we "re-run" the object check.  However, we re-run the object check exactly ONCE.  If the user supplies an object that isn't one of the
    // supported classes, we fail the second time (i.e., double fault error).
    BOOL rerunningAfterClassFormatter = NO;
rerunAfterClassFormatter:

    isClass = AGXjk_object_class(encodeState, object);
    if (AGXJK_EXPECT_F(isClass == AGXJKClassUnknown)) {
        if ((rerunningAfterClassFormatter == NO) &&
            (
#ifdef __BLOCKS__
             ((encodeState->classFormatterBlock) && ((object = ((AGX_BRIDGE AGXJKClassFormatterBlock)encodeState->classFormatterBlock)(object)) != nil)) ||
#endif
             ((encodeState->classFormatterIMP) && ((object = encodeState->classFormatterIMP((AGX_BRIDGE id)encodeState->classFormatterDelegate, encodeState->classFormatterSelector, object)) != nil))    )) { rerunningAfterClassFormatter = YES; goto rerunAfterClassFormatter; }

        if (rerunningAfterClassFormatter == NO) { AGXjk_encode_error(encodeState, @"Unable to serialize object class %@.", NSStringFromClass([encodeCacheObject class])); return(1); }
        else { AGXjk_encode_error(encodeState, @"Unable to serialize object class %@ that was returned by the unsupported class formatter.  Original object class was %@.", (object == nil) ? @"NULL" : NSStringFromClass([object class]), NSStringFromClass([encodeCacheObject class])); return(1); }
    }

    // This is here for the benefit of the optimizer.  It allows the optimizer to do loop invariant code motion for the JKClassArray
    // and JKClassDictionary cases when printing simple, single characters via jk_encode_write(), which is actually a macro:
    // #define jk_encode_write1(es, dc, f) (_jk_encode_prettyPrint ? jk_encode_write1slow(es, dc, f) : jk_encode_write1fast(es, dc, f))
    int _AGXjk_encode_prettyPrint = AGXJK_EXPECT_T((encodeState->serializeOptionFlags & AGXJKSerializeOptionPretty) == 0) ? 0 : 1;

    switch(isClass) {
        case AGXJKClassString:
        {
            {
                const unsigned char *cStringPtr = (const unsigned char *)CFStringGetCStringPtr((CFStringRef)object, kCFStringEncodingMacRoman);
                if (cStringPtr != NULL) {
                    const unsigned char *utf8String = cStringPtr;
                    size_t               utf8Idx    = 0UL;

                    CFIndex stringLength = CFStringGetLength((CFStringRef)object);
                    if (AGXJK_EXPECT_F(((encodeState->atIndex + (stringLength * 2UL) + 256UL) > encodeState->stringBuffer.bytes.length)) && AGXJK_EXPECT_F((AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + (stringLength * 2UL) + 1024UL) == NULL))) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }

                    if (AGXJK_EXPECT_T((encodeState->encodeOption & AGXJKEncodeOptionStringObjTrimQuotes) == 0UL)) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\"'; }
                    for(utf8Idx = 0UL; utf8String[utf8Idx] != 0U; utf8Idx++) {
                        NSCParameterAssert(((&encodeState->stringBuffer.bytes.ptr[encodeState->atIndex]) - encodeState->stringBuffer.bytes.ptr) < (ssize_t)encodeState->stringBuffer.bytes.length);
                        NSCParameterAssert(encodeState->atIndex < encodeState->stringBuffer.bytes.length);
                        if (AGXJK_EXPECT_F(utf8String[utf8Idx] >= 0x80U)) { encodeState->atIndex = startingAtIndex; goto slowUTF8Path; }
                        if (AGXJK_EXPECT_F(utf8String[utf8Idx] <  0x20U)) {
                            switch(utf8String[utf8Idx]) {
                                case '\b': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'b'; break;
                                case '\f': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'f'; break;
                                case '\n': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'n'; break;
                                case '\r': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'r'; break;
                                case '\t': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 't'; break;
                                default: if (AGXJK_EXPECT_F(AGXjk_encode_printf(encodeState, NULL, 0UL, NULL, "\\u%4.4x", utf8String[utf8Idx]))) { return(1); } break;
                            }
                        } else {
                            if (AGXJK_EXPECT_F(utf8String[utf8Idx] == '\"') || AGXJK_EXPECT_F(utf8String[utf8Idx] == '\\') || (AGXJK_EXPECT_F(encodeState->serializeOptionFlags & AGXJKSerializeOptionEscapeForwardSlashes) && AGXJK_EXPECT_F(utf8String[utf8Idx] == '/'))) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; }
                            encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = utf8String[utf8Idx];
                        }
                    }
                    NSCParameterAssert((encodeState->atIndex + 1UL) < encodeState->stringBuffer.bytes.length);
                    if (AGXJK_EXPECT_T((encodeState->encodeOption & AGXJKEncodeOptionStringObjTrimQuotes) == 0UL)) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\"'; }
                    AGXjk_encode_updateCache(encodeState, cacheSlot, startingAtIndex, encodeCacheObject);
                    return(0);
                }
            }

        slowUTF8Path:
            {
                CFIndex stringLength        = CFStringGetLength((CFStringRef)object);
                CFIndex maxStringUTF8Length = CFStringGetMaximumSizeForEncoding(stringLength, kCFStringEncodingUTF8) + 32L;

                if (AGXJK_EXPECT_F((size_t)maxStringUTF8Length > encodeState->utf8ConversionBuffer.bytes.length) && AGXJK_EXPECT_F(AGXjk_managedBuffer_resize(&encodeState->utf8ConversionBuffer, maxStringUTF8Length + 1024UL) == NULL)) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }

                CFIndex usedBytes = 0L, convertedCount = 0L;
                convertedCount = CFStringGetBytes((CFStringRef)object, CFRangeMake(0L, stringLength), kCFStringEncodingUTF8, '?', NO, encodeState->utf8ConversionBuffer.bytes.ptr, encodeState->utf8ConversionBuffer.bytes.length - 16L, &usedBytes);
                if (AGXJK_EXPECT_F(convertedCount != stringLength) || AGXJK_EXPECT_F(usedBytes < 0L)) { AGXjk_encode_error(encodeState, @"An error occurred converting the contents of a NSString to UTF8."); return(1); }

                if (AGXJK_EXPECT_F((encodeState->atIndex + (maxStringUTF8Length * 2UL) + 256UL) > encodeState->stringBuffer.bytes.length) && AGXJK_EXPECT_F(AGXjk_managedBuffer_resize(&encodeState->stringBuffer, encodeState->atIndex + (maxStringUTF8Length * 2UL) + 1024UL) == NULL)) { AGXjk_encode_error(encodeState, @"Unable to resize temporary buffer."); return(1); }

                const unsigned char *utf8String = encodeState->utf8ConversionBuffer.bytes.ptr;

                size_t utf8Idx = 0UL;
                if (AGXJK_EXPECT_T((encodeState->encodeOption & AGXJKEncodeOptionStringObjTrimQuotes) == 0UL)) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\"'; }
                for(utf8Idx = 0UL; utf8Idx < (size_t)usedBytes; utf8Idx++) {
                    NSCParameterAssert(((&encodeState->stringBuffer.bytes.ptr[encodeState->atIndex]) - encodeState->stringBuffer.bytes.ptr) < (ssize_t)encodeState->stringBuffer.bytes.length);
                    NSCParameterAssert(encodeState->atIndex < encodeState->stringBuffer.bytes.length);
                    NSCParameterAssert((CFIndex)utf8Idx < usedBytes);
                    if (AGXJK_EXPECT_F(utf8String[utf8Idx] < 0x20U)) {
                        switch(utf8String[utf8Idx]) {
                            case '\b': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'b'; break;
                            case '\f': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'f'; break;
                            case '\n': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'n'; break;
                            case '\r': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 'r'; break;
                            case '\t': encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = 't'; break;
                            default: if (AGXJK_EXPECT_F(AGXjk_encode_printf(encodeState, NULL, 0UL, NULL, "\\u%4.4x", utf8String[utf8Idx]))) { return(1); } break;
                        }
                    } else {
                        if (AGXJK_EXPECT_F(utf8String[utf8Idx] >= 0x80U) && (encodeState->serializeOptionFlags & AGXJKSerializeOptionEscapeUnicode)) {
                            const unsigned char *nextValidCharacter = NULL;
                            UTF32                u32ch              = 0U;
                            AGXConversionResult  result;

                            if (AGXJK_EXPECT_F((result = AGXConvertSingleCodePointInUTF8(&utf8String[utf8Idx], &utf8String[usedBytes], (UTF8 const **)&nextValidCharacter, &u32ch)) != conversionOK)) { AGXjk_encode_error(encodeState, @"Error converting UTF8."); return(1); }
                            else {
                                utf8Idx = (nextValidCharacter - utf8String) - 1UL;
                                if (AGXJK_EXPECT_T(u32ch <= 0xffffU)) { if (AGXJK_EXPECT_F(AGXjk_encode_printf(encodeState, NULL, 0UL, NULL, "\\u%4.4x", u32ch)))                                                           { return(1); } }
                                else                              { if (AGXJK_EXPECT_F(AGXjk_encode_printf(encodeState, NULL, 0UL, NULL, "\\u%4.4x\\u%4.4x", (0xd7c0U + (u32ch >> 10)), (0xdc00U + (u32ch & 0x3ffU))))) { return(1); } }
                            }
                        } else {
                            if (AGXJK_EXPECT_F(utf8String[utf8Idx] == '\"') || AGXJK_EXPECT_F(utf8String[utf8Idx] == '\\') || (AGXJK_EXPECT_F(encodeState->serializeOptionFlags & AGXJKSerializeOptionEscapeForwardSlashes) && AGXJK_EXPECT_F(utf8String[utf8Idx] == '/'))) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\\'; }
                            encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = utf8String[utf8Idx];
                        }
                    }
                }
                NSCParameterAssert((encodeState->atIndex + 1UL) < encodeState->stringBuffer.bytes.length);
                if (AGXJK_EXPECT_T((encodeState->encodeOption & AGXJKEncodeOptionStringObjTrimQuotes) == 0UL)) { encodeState->stringBuffer.bytes.ptr[encodeState->atIndex++] = '\"'; }
                AGXjk_encode_updateCache(encodeState, cacheSlot, startingAtIndex, encodeCacheObject);
                return(0);
            }
        }
            break;

        case AGXJKClassNumber:
        {
            if (object == (id)kCFBooleanTrue)  { return(AGXjk_encode_writen(encodeState, cacheSlot, startingAtIndex, encodeCacheObject, "true",  4UL)); }
            else if (object == (id)kCFBooleanFalse) { return(AGXjk_encode_writen(encodeState, cacheSlot, startingAtIndex, encodeCacheObject, "false", 5UL)); }

            const char         *objCType = [object objCType];
            char                anum[256], *aptr = &anum[255];
            int                 isNegative = 0;
            unsigned long long  ullv;
            long long           llv;

            if (AGXJK_EXPECT_F(objCType == NULL) || AGXJK_EXPECT_F(objCType[0] == 0) || AGXJK_EXPECT_F(objCType[1] != 0)) { AGXjk_encode_error(encodeState, @"NSNumber conversion error, unknown type.  Type: '%s'", (objCType == NULL) ? "<NULL>" : objCType); return(1); }

            switch(objCType[0]) {
                case 'c': case 'i': case 's': case 'l': case 'q':
                    if (AGXJK_EXPECT_T(CFNumberGetValue((CFNumberRef)object, kCFNumberLongLongType, &llv)))  {
                        if (llv < 0LL)  { ullv = -llv; isNegative = 1; } else { ullv = llv; isNegative = 0; }
                        goto convertNumber;
                    } else { AGXjk_encode_error(encodeState, @"Unable to get scalar value from number object."); return(1); }
                    break;
                case 'C': case 'I': case 'S': case 'L': case 'Q': case 'B':
                    if (AGXJK_EXPECT_T(CFNumberGetValue((CFNumberRef)object, kCFNumberLongLongType, &ullv))) {
                    convertNumber:
                        if (AGXJK_EXPECT_F(ullv < 10ULL)) { *--aptr = ullv + '0'; } else { while(AGXJK_EXPECT_T(ullv > 0ULL)) { *--aptr = (ullv % 10ULL) + '0'; ullv /= 10ULL; NSCParameterAssert(aptr > anum); } }
                        if (isNegative) { *--aptr = '-'; }
                        NSCParameterAssert(aptr > anum);
                        return(AGXjk_encode_writen(encodeState, cacheSlot, startingAtIndex, encodeCacheObject, aptr, &anum[255] - aptr));
                    } else { AGXjk_encode_error(encodeState, @"Unable to get scalar value from number object."); return(1); }
                    break;
                case 'f': case 'd':
                {
                    double dv;
                    if (AGXJK_EXPECT_T(CFNumberGetValue((CFNumberRef)object, kCFNumberDoubleType, &dv))) {
                        if (AGXJK_EXPECT_F(!isfinite(dv))) { AGXjk_encode_error(encodeState, @"Floating point values must be finite.  JSON does not support NaN or Infinity."); return(1); }
                        return(AGXjk_encode_printf(encodeState, cacheSlot, startingAtIndex, encodeCacheObject, "%.17g", dv));
                    } else { AGXjk_encode_error(encodeState, @"Unable to get floating point value from number object."); return(1); }
                }
                    break;
                default: AGXjk_encode_error(encodeState, @"NSNumber conversion error, unknown type.  Type: '%c' / 0x%2.2x", objCType[0], objCType[0]); return(1); break;
            }
        }
            break;

        case AGXJKClassArray:
        {
            int     printComma = 0;
            CFIndex arrayCount = CFArrayGetCount((CFArrayRef)object), idx = 0L;
            if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 1L, "["))) { return(1); }
            if (AGXJK_EXPECT_F(arrayCount > 1020L)) {
                for(id arrayObject in object)          { if (AGXJK_EXPECT_T(printComma)) { if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 0L, ","))) { return(1); } } printComma = 1; if (AGXJK_EXPECT_F(AGXjk_encode_add_atom_to_buffer(encodeState, (AGX_BRIDGE void *)arrayObject)))  { return(1); } }
            } else {
                void *objects[1024];
                CFArrayGetValues((CFArrayRef)object, CFRangeMake(0L, arrayCount), (const void **)objects);
                for(idx = 0L; idx < arrayCount; idx++) { if (AGXJK_EXPECT_T(printComma)) { if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 0L, ","))) { return(1); } } printComma = 1; if (AGXJK_EXPECT_F(AGXjk_encode_add_atom_to_buffer(encodeState, objects[idx]))) { return(1); } }
            }
            return(AGXjk_encode_write1(encodeState, -1L, "]"));
        }
            break;

        case AGXJKClassDictionary:
        {
            int     printComma      = 0;
            CFIndex dictionaryCount = CFDictionaryGetCount((CFDictionaryRef)object), idx = 0L;
            id      enumerateObject = AGXJK_EXPECT_F(_AGXjk_encode_prettyPrint) ? [[(NSDictionary*)object allKeys] sortedArrayUsingSelector:@selector(compare:)] : object;

            if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 1L, "{"))) { return(1); }
            if (AGXJK_EXPECT_F(_AGXjk_encode_prettyPrint) || AGXJK_EXPECT_F(dictionaryCount > 1024L)) {
                for(id keyObject in enumerateObject) {
                    if (AGXJK_EXPECT_T(printComma)) { if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 0L, ","))) { return(1); } }
                    printComma = 1;
                    if (AGXJK_EXPECT_F(AGXjk_object_is_string(encodeState, keyObject) == NO)) { AGXjk_encode_error(encodeState, @"Key must be a string object."); return(1); }
                    if (AGXJK_EXPECT_F(AGXjk_encode_add_atom_to_buffer(encodeState, (AGX_BRIDGE void *)keyObject)))                                                             { return(1); }
                    if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 0L, ":")))                                                                           { return(1); }
                    if (AGXJK_EXPECT_F(AGXjk_encode_add_atom_to_buffer(encodeState, (void *)CFDictionaryGetValue((CFDictionaryRef)object, (AGX_BRIDGE void *)keyObject)))) { return(1); }
                }
            } else {
                void *keys[1024], *objects[1024];
                CFDictionaryGetKeysAndValues((CFDictionaryRef)object, (const void **)keys, (const void **)objects);
                for(idx = 0L; idx < dictionaryCount; idx++) {
                    if (AGXJK_EXPECT_T(printComma)) { if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 0L, ","))) { return(1); } }
                    printComma = 1;
                    id keyObject = (AGX_BRIDGE id)keys[idx];
                    if (AGXJK_EXPECT_F(AGXjk_object_is_string(encodeState, keyObject) == NO))
                    { AGXjk_encode_error(encodeState, @"Key must be a string object."); return(1); }
                    if (AGXJK_EXPECT_F(AGXjk_encode_add_atom_to_buffer(encodeState, (AGX_BRIDGE void *)keyObject)))
                    { return(1); }
                    if (AGXJK_EXPECT_F(AGXjk_encode_write1(encodeState, 0L, ":"))) { return(1); }
                    if (AGXJK_EXPECT_F(AGXjk_encode_add_atom_to_buffer(encodeState, objects[idx]))) { return(1); }
                }
            }
            return(AGXjk_encode_write1(encodeState, -1L, "}"));
        }
            break;

        case AGXJKClassNull: return(AGXjk_encode_writen(encodeState, cacheSlot, startingAtIndex, encodeCacheObject, "null", 4UL)); break;

        default: AGXjk_encode_error(encodeState, @"Unable to serialize object class %@.", NSStringFromClass([object class])); return(1); break;
    }

    return(0);
}


@implementation AGXJKSerializer

+ (id)serializeObject:(id)object options:(AGXJKSerializeOptionFlags)optionFlags encodeOption:(AGXJKEncodeOptionType)encodeOption block:(AGXJKSERIALIZER_BLOCKS_PROTO)block delegate:(id)delegate selector:(SEL)selector error:(NSError **)error {
    return([AGX_AUTORELEASE([[self alloc] init]) serializeObject:object options:optionFlags encodeOption:encodeOption block:block delegate:delegate selector:selector error:error]);
}

- (id)serializeObject:(id)object options:(AGXJKSerializeOptionFlags)optionFlags encodeOption:(AGXJKEncodeOptionType)encodeOption block:(AGXJKSERIALIZER_BLOCKS_PROTO)block delegate:(id)delegate selector:(SEL)selector error:(NSError **)error {
#ifndef __BLOCKS__
#pragma unused(block)
#endif
    NSParameterAssert((object != NULL) && (encodeState == NULL) && ((delegate != NULL) ? (block == NULL) : 1) && ((block != NULL) ? (delegate == NULL) : 1) && (((encodeOption & AGXJKEncodeOptionCollectionObj) != 0UL) ? (((encodeOption & AGXJKEncodeOptionStringObj)     == 0UL) && ((encodeOption & AGXJKEncodeOptionStringObjTrimQuotes) == 0UL)) : 1) &&
                      (((encodeOption & AGXJKEncodeOptionStringObj)     != 0UL) ?  ((encodeOption & AGXJKEncodeOptionCollectionObj) == 0UL)                                                                 : 1));

    id returnObject = NULL;

    if (encodeState != NULL) { [self releaseState]; }
    if ((encodeState = (struct AGXJKEncodeState *)calloc(1UL, sizeof(AGXJKEncodeState))) == NULL) { [NSException raise:NSMallocException format:@"Unable to allocate state structure."]; return(NULL); }

    if ((error != NULL) && (*error != NULL)) { *error = NULL; }

    if (delegate != NULL) {
        if (selector                               == NULL) { [NSException raise:NSInvalidArgumentException format:@"The delegate argument is not NULL, but the selector argument is NULL."]; }
        if ([delegate respondsToSelector:selector] == NO)   { [NSException raise:NSInvalidArgumentException format:@"The serializeUnsupportedClassesUsingDelegate: delegate does not respond to the selector argument."]; }
        encodeState->classFormatterDelegate = (AGX_BRIDGE void *)delegate;
        encodeState->classFormatterSelector = selector;
        encodeState->classFormatterIMP      = (AGXJKClassFormatterIMP)[delegate methodForSelector:selector];
        NSCParameterAssert(encodeState->classFormatterIMP != NULL);
    }
#ifdef __BLOCKS__
    encodeState->classFormatterBlock                          = (AGX_BRIDGE void *)(block);
#endif

    encodeState->serializeOptionFlags                         = optionFlags;
    encodeState->encodeOption                                 = encodeOption;
    encodeState->stringBuffer.roundSizeUpToMultipleOf         = (1024UL * 32UL);
    encodeState->utf8ConversionBuffer.roundSizeUpToMultipleOf = 4096UL;

    unsigned char stackJSONBuffer[AGXJK_JSONBUFFER_SIZE] AGXJK_ALIGNED(64);
    AGXjk_managedBuffer_setToStackBuffer(&encodeState->stringBuffer,         stackJSONBuffer, sizeof(stackJSONBuffer));

    unsigned char stackUTF8Buffer[AGXJK_UTF8BUFFER_SIZE] AGXJK_ALIGNED(64);
    AGXjk_managedBuffer_setToStackBuffer(&encodeState->utf8ConversionBuffer, stackUTF8Buffer, sizeof(stackUTF8Buffer));

    if (((encodeOption & AGXJKEncodeOptionCollectionObj) != 0UL) && (([object isKindOfClass:[NSArray  class]] == NO) && ([object isKindOfClass:[NSDictionary class]] == NO))) { AGXjk_encode_error(encodeState, @"Unable to serialize object class %@, expected a NSArray or NSDictionary.", NSStringFromClass([object class])); goto errorExit; }
    if (((encodeOption & AGXJKEncodeOptionStringObj)     != 0UL) &&  ([object isKindOfClass:[NSString class]] == NO))                                                         { AGXjk_encode_error(encodeState, @"Unable to serialize object class %@, expected a NSString.", NSStringFromClass([object class])); goto errorExit; }

    if (AGXjk_encode_add_atom_to_buffer(encodeState, (AGX_BRIDGE void *)object) == 0) {
        BOOL stackBuffer = ((encodeState->stringBuffer.flags & AGXJKManagedBufferMustFree) == 0UL) ? YES : NO;

        if ((encodeState->atIndex < 2UL))
            if ((stackBuffer == NO) && ((encodeState->stringBuffer.bytes.ptr = (unsigned char *)reallocf(encodeState->stringBuffer.bytes.ptr, encodeState->atIndex + 16UL)) == NULL)) { AGXjk_encode_error(encodeState, @"Unable to realloc buffer"); goto errorExit; }

        switch((encodeOption & AGXJKEncodeOptionAsTypeMask)) {
            case AGXJKEncodeOptionAsData:
                if (stackBuffer == YES) { if ((returnObject = AGX_AUTORELEASE((AGX_BRIDGE_TRANSFER id)CFDataCreate(NULL, encodeState->stringBuffer.bytes.ptr, (CFIndex)encodeState->atIndex))) == NULL) { AGXjk_encode_error(encodeState, @"Unable to create NSData object"); } }
                else { if ((returnObject = AGX_AUTORELEASE((AGX_BRIDGE_TRANSFER id)CFDataCreateWithBytesNoCopy(NULL, encodeState->stringBuffer.bytes.ptr, (CFIndex)encodeState->atIndex, NULL))) == NULL) { AGXjk_encode_error(encodeState, @"Unable to create NSData object"); } }
                break;

            case AGXJKEncodeOptionAsString:
                if (stackBuffer == YES) { if ((returnObject = AGX_AUTORELEASE((AGX_BRIDGE_TRANSFER id)CFStringCreateWithBytes(NULL, (const UInt8 *)encodeState->stringBuffer.bytes.ptr, (CFIndex)encodeState->atIndex, kCFStringEncodingUTF8, NO))) == NULL) { AGXjk_encode_error(encodeState, @"Unable to create NSString object"); } }
                else { if ((returnObject = AGX_AUTORELEASE((AGX_BRIDGE_TRANSFER id)CFStringCreateWithBytesNoCopy(NULL, (const UInt8 *)encodeState->stringBuffer.bytes.ptr, (CFIndex)encodeState->atIndex, kCFStringEncodingUTF8, NO, NULL))) == NULL) { AGXjk_encode_error(encodeState, @"Unable to create NSString object"); } }
                break;

            default: AGXjk_encode_error(encodeState, @"Unknown encode as type."); break;
        }

        if ((returnObject != NULL) && (stackBuffer == NO)) { encodeState->stringBuffer.flags &= ~AGXJKManagedBufferMustFree; encodeState->stringBuffer.bytes.ptr = NULL; encodeState->stringBuffer.bytes.length = 0UL; }
    }

errorExit:
    if (encodeState != NULL) {
        AGXjk_build_ns_error_from_jk_error(error, encodeState->error);
        AGXjk_error_release(&encodeState->error);
    }
    [self releaseState];
    return(returnObject);
}

- (void)releaseState {
    if (encodeState != NULL) {
        AGXjk_error_release(&encodeState->error);
        AGXjk_managedBuffer_release(&encodeState->stringBuffer);
        AGXjk_managedBuffer_release(&encodeState->utf8ConversionBuffer);
        free(encodeState); encodeState = NULL;
    }
}

- (void)dealloc {
    [self releaseState];
    AGX_SUPER_DEALLOC;
}

@end

@category_implementation(NSString, AGXJSONKitSerializing)

////////////
#pragma mark Methods for serializing a single NSString.
////////////

// Useful for those who need to serialize just a NSString.  Otherwise you would have to do something like [NSArray arrayWithObject:stringToBeJSONSerialized], serializing the array, and then chopping of the extra ^\[.*\]$ square brackets.

// NSData returning methods...

- (NSData *)AGXJSONData {
    return([self AGXJSONDataWithOptions:AGXJKSerializeOptionNone includeQuotes:YES error:NULL]);
}

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions includeQuotes:(BOOL)includeQuotes error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | ((includeQuotes == NO) ? AGXJKEncodeOptionStringObjTrimQuotes : 0UL) | AGXJKEncodeOptionStringObj) block:NULL delegate:NULL selector:NULL error:error]);
}

// NSString returning methods...

- (NSString *)AGXJSONString {
    return([self AGXJSONStringWithOptions:AGXJKSerializeOptionNone includeQuotes:YES error:NULL]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions includeQuotes:(BOOL)includeQuotes error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | ((includeQuotes == NO) ? AGXJKEncodeOptionStringObjTrimQuotes : 0UL) | AGXJKEncodeOptionStringObj) block:NULL delegate:NULL selector:NULL error:error]);
}

@end

@category_implementation(NSArray, AGXJSONKitSerializing)

// NSData returning methods...

- (NSData *)AGXJSONData {
    return([AGXJKSerializer serializeObject:self options:AGXJKSerializeOptionNone encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:NULL]);
}

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:error]);
}

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingDelegate:(id)delegate selector:(SEL)selector error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:NULL delegate:delegate selector:selector error:error]);
}

// NSString returning methods...

- (NSString *)AGXJSONString {
    return([AGXJKSerializer serializeObject:self options:AGXJKSerializeOptionNone encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:NULL]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:error]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingDelegate:(id)delegate selector:(SEL)selector error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:NULL delegate:delegate selector:selector error:error]);
}

@end

@category_implementation(NSDictionary, AGXJSONKitSerializing)

// NSData returning methods...

- (NSData *)AGXJSONData {
    return([AGXJKSerializer serializeObject:self options:AGXJKSerializeOptionNone encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:NULL]);
}

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:error]);
}

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingDelegate:(id)delegate selector:(SEL)selector error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:NULL delegate:delegate selector:selector error:error]);
}

// NSString returning methods...

- (NSString *)AGXJSONString {
    return([AGXJKSerializer serializeObject:self options:AGXJKSerializeOptionNone encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:NULL]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:NULL delegate:NULL selector:NULL error:error]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingDelegate:(id)delegate selector:(SEL)selector error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:NULL delegate:delegate selector:selector error:error]);
}

@end

#ifdef __BLOCKS__

@category_implementation(NSArray, AGXJSONKitSerializingBlockAdditions)

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingBlock:(id(^)(id object))block error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:block delegate:NULL selector:NULL error:error]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingBlock:(id(^)(id object))block error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:block delegate:NULL selector:NULL error:error]);
}

@end

@category_implementation(NSDictionary, AGXJSONKitSerializingBlockAdditions)

- (NSData *)AGXJSONDataWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingBlock:(id(^)(id object))block error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsData | AGXJKEncodeOptionCollectionObj) block:block delegate:NULL selector:NULL error:error]);
}

- (NSString *)AGXJSONStringWithOptions:(AGXJKSerializeOptionFlags)serializeOptions serializeUnsupportedClassesUsingBlock:(id(^)(id object))block error:(NSError **)error {
    return([AGXJKSerializer serializeObject:self options:serializeOptions encodeOption:(AGXJKEncodeOptionAsString | AGXJKEncodeOptionCollectionObj) block:block delegate:NULL selector:NULL error:error]);
}

@end

#endif // __BLOCKS__
