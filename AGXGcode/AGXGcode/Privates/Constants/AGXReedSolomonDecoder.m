//
//  AGXReedSolomonDecoder.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/5.
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
#import "AGXReedSolomonDecoder.h"
#import "AGXGcodeError.h"

NSError *AGXReedSolomonErrorInstance(NSString *description);

@implementation AGXReedSolomonDecoder {
    AGXGenericGF *_field;
}

+ (AGX_INSTANCETYPE)decoderWithField:(AGXGenericGF *)field {
    return AGX_AUTORELEASE([[self alloc] initWithField:field]);
}

- (AGX_INSTANCETYPE)initWithField:(AGXGenericGF *)field {
    if AGX_EXPECT_T(self = [super init]) {
        _field = AGX_RETAIN(field);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_field);
    AGX_SUPER_DEALLOC;
}

- (BOOL)decode:(AGXIntArray *)received twoS:(int)twoS error:(NSError **)error {
    AGXGenericGFPoly *poly = [AGXGenericGFPoly polyWithField:_field coefficients:received];
    AGXIntArray *syndromeCoefficients = [AGXIntArray intArrayWithLength:twoS];
    BOOL noError = YES;
    for (int i = 0; i < twoS; i++) {
        int eval = [poly evaluateAt:[_field exp:i + _field.generatorBase]];
        syndromeCoefficients.array[syndromeCoefficients.length - 1 - i] = eval;
        if AGX_EXPECT_F(eval != 0) noError = NO;
    }
    if (noError) return YES;

    AGXGenericGFPoly *syndrome = [AGXGenericGFPoly polyWithField:_field coefficients:syndromeCoefficients];
    NSArray *sigmaOmega = [self runEuclideanAlgorithm:[_field buildMonomial:twoS coefficient:1] b:syndrome R:twoS error:error];
    if AGX_EXPECT_F(!sigmaOmega) return NO;

    AGXGenericGFPoly *sigma = sigmaOmega[0];
    AGXGenericGFPoly *omega = sigmaOmega[1];
    AGXIntArray *errorLocations = [self findErrorLocations:sigma error:error];
    if AGX_EXPECT_F(!errorLocations) return NO;

    AGXIntArray *errorMagnitudes = [self findErrorMagnitudes:omega errorLocations:errorLocations];
    for (int i = 0; i < errorLocations.length; i++) {
        int position = received.length - 1 - [_field log:errorLocations.array[i]];
        if AGX_EXPECT_F(position < 0) {
            if AGX_EXPECT_T(error) *error = AGXReedSolomonErrorInstance(@"Bad error location");
            return NO;
        }
        received.array[position] = [AGXGenericGF addOrSubtract:received.array[position] b:errorMagnitudes.array[i]];
    }
    return YES;
}

- (NSArray *)runEuclideanAlgorithm:(AGXGenericGFPoly *)a b:(AGXGenericGFPoly *)b R:(int)R error:(NSError **)error {
    if (a.degree < b.degree) {
        AGXGenericGFPoly *temp = a;
        a = b;
        b = temp;
    }

    AGXGenericGFPoly *rLast = a;
    AGXGenericGFPoly *r = b;
    AGXGenericGFPoly *tLast = _field.zero;
    AGXGenericGFPoly *t = _field.one;

    while ([r degree] >= R / 2) {
        AGXGenericGFPoly *rLastLast = rLast;
        AGXGenericGFPoly *tLastLast = tLast;
        rLast = r;
        tLast = t;

        if AGX_EXPECT_F([rLast zero]) {
            if AGX_EXPECT_T(error) *error = AGXReedSolomonErrorInstance(@"r_{i-1} was zero");
            return nil;
        }
        r = rLastLast;
        AGXGenericGFPoly *q = _field.zero;
        int denominatorLeadingTerm = [rLast coefficient:[rLast degree]];
        int dltInverse = [_field inverse:denominatorLeadingTerm];

        while (r.degree >= rLast.degree && !r.zero) {
            int degreeDiff = r.degree - rLast.degree;
            int scale = [_field multiply:[r coefficient:r.degree] b:dltInverse];
            q = [q addOrSubtract:[_field buildMonomial:degreeDiff coefficient:scale]];
            r = [r addOrSubtract:[rLast multiplyByMonomial:degreeDiff coefficient:scale]];
        }

        t = [[q multiply:tLast] addOrSubtract:tLastLast];

        if AGX_EXPECT_F(r.degree >= rLast.degree)
            @throw [NSException exceptionWithName:@"IllegalStateException" reason:
                    @"Division algorithm failed to reduce polynomial?" userInfo:nil];
    }

    int sigmaTildeAtZero = [t coefficient:0];
    if AGX_EXPECT_F(sigmaTildeAtZero == 0) {
        if AGX_EXPECT_T(error) *error = AGXReedSolomonErrorInstance(@"sigmaTilde(0) was zero");
        return nil;
    }

    int inverse = [_field inverse:sigmaTildeAtZero];
    AGXGenericGFPoly *sigma = [t multiplyScalar:inverse];
    AGXGenericGFPoly *omega = [r multiplyScalar:inverse];
    return @[sigma, omega];
}

- (AGXIntArray *)findErrorLocations:(AGXGenericGFPoly *)errorLocator error:(NSError **)error {
    int numErrors = errorLocator.degree;
    if (numErrors == 1) {
        AGXIntArray *array = [AGXIntArray intArrayWithLength:1];
        array.array[0] = [errorLocator coefficient:1];
        return array;
    }
    AGXIntArray *result = [AGXIntArray intArrayWithLength:numErrors];
    int e = 0;
    for (int i = 1; i < _field.size && e < numErrors; i++) {
        if ([errorLocator evaluateAt:i] == 0) {
            result.array[e] = [_field inverse:i];
            e++;
        }
    }

    if AGX_EXPECT_F(e != numErrors) {
        if AGX_EXPECT_T(error) *error = AGXReedSolomonErrorInstance
            (@"Error locator degree does not match number of roots");
        return nil;
    }
    return result;
}

- (AGXIntArray *)findErrorMagnitudes:(AGXGenericGFPoly *)errorEvaluator errorLocations:(AGXIntArray *)errorLocations {
    int s = errorLocations.length;
    AGXIntArray *result = [AGXIntArray intArrayWithLength:s];
    AGXGenericGF *field = _field;
    for (int i = 0; i < s; i++) {
        int xiInverse = [field inverse:errorLocations.array[i]];
        int denominator = 1;
        for (int j = 0; j < s; j++) {
            if (i != j) {
                //denominator = field.multiply(denominator,
                //    GenericGF.addOrSubtract(1, field.multiply(errorLocations[j], xiInverse)));
                // Above should work but fails on some Apple and Linux JDKs due to a Hotspot bug.
                // Below is a funny-looking workaround from Steven Parkes
                int term = [field multiply:errorLocations.array[j] b:xiInverse];
                int termPlus1 = (term & 0x1) == 0 ? term | 1 : term & ~1;
                denominator = [field multiply:denominator b:termPlus1];
            }
        }
        result.array[i] = [field multiply:[errorEvaluator evaluateAt:xiInverse] b:[field inverse:denominator]];
        if (field.generatorBase != 0) {
            result.array[i] = [field multiply:result.array[i] b:xiInverse];
        }
    }
    return result;
}

@end

NSError *AGXReedSolomonErrorInstance(NSString *description) {
    return [NSError errorWithDomain:AGXGcodeErrorDomain code:AGXReedSolomonError
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@interface AGXGenericGF ()
@property (nonatomic, readonly) int primitive;
@property (nonatomic, readonly) int32_t *expTable;
@property (nonatomic, readonly) int32_t *logTable;
@end

@implementation AGXGenericGF

- (AGX_INSTANCETYPE)initWithPrimitive:(int)primitive size:(int)size b:(int)b {
    if AGX_EXPECT_T(self = [super init]) {
        _zero = [[AGXGenericGFPoly alloc] initWithField:self coefficients:[AGXIntArray intArrayWithLength:1]];
        _one = [[AGXGenericGFPoly alloc] initWithField:self coefficients:[AGXIntArray intArrayWithInts:1, -1]];
        _size = size;
        _generatorBase = b;

        _primitive = primitive;
        _expTable = (int32_t *)calloc(_size, sizeof(int32_t));
        _logTable = (int32_t *)calloc(_size, sizeof(int32_t));
        int32_t x = 1;
        for (int i = 0; i < _size; i++) {
            _expTable[i] = x;
            x <<= 1; // we're assuming the generator alpha is 2
            if (x >= _size) {
                x ^= (int32_t)_primitive;
                x &= (int32_t)_size - 1;
            }
        }

        for (int32_t i = 0; i < (int32_t)_size-1; i++) {
            _logTable[_expTable[i]] = i;
        }
        // logTable[0] == 0 but this should never be used
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_zero);
    AGX_RELEASE(_one);
    if (_expTable) free(_expTable);
    if (_logTable) free(_logTable);
    AGX_SUPER_DEALLOC;
}

+ (AGXGenericGF *)AztecData12 {
    static AGXGenericGF *AztecData12 = nil;
    agx_once
    (AztecData12 = [[self alloc] initWithPrimitive:0x1069 size:4096 b:1];) // x^12 + x^6 + x^5 + x^3 + 1
    return AztecData12;
}

+ (AGXGenericGF *)AztecData10 {
    static AGXGenericGF *AztecData10 = nil;
    agx_once
    (AztecData10 = [[self alloc] initWithPrimitive:0x409 size:1024 b:1];) // x^10 + x^3 + 1
    return AztecData10;
}

+ (AGXGenericGF *)AztecData6 {
    static AGXGenericGF *AztecData6 = nil;
    agx_once
    (AztecData6 = [[self alloc] initWithPrimitive:0x43 size:64 b:1];) // x^6 + x + 1
    return AztecData6;
}

+ (AGXGenericGF *)AztecParam {
    static AGXGenericGF *AztecParam = nil;
    agx_once
    (AztecParam = [[self alloc] initWithPrimitive:0x13 size:16 b:1];) // x^4 + x + 1
    return AztecParam;
}

+ (AGXGenericGF *)QrCodeField256 {
    static AGXGenericGF *QrCodeField256 = nil;
    agx_once
    (QrCodeField256 = [[self alloc] initWithPrimitive:0x011D size:256 b:0];) // x^8 + x^4 + x^3 + x^2 + 1
    return QrCodeField256;
}

+ (AGXGenericGF *)DataMatrixField256 {
    static AGXGenericGF *DataMatrixField256 = nil;
    agx_once
    (DataMatrixField256 = [[self alloc] initWithPrimitive:0x012D size:256 b:1];) // x^8 + x^5 + x^3 + x^2 + 1
    return DataMatrixField256;
}

+ (AGXGenericGF *)AztecData8 {
    return self.DataMatrixField256;
}

+ (AGXGenericGF *)MaxiCodeField64 {
    return self.AztecData6;
}

- (AGXGenericGFPoly *)buildMonomial:(int)degree coefficient:(int32_t)coefficient {
    if AGX_EXPECT_F(degree < 0) [NSException raise:NSInvalidArgumentException format:
                                 @"Degree must be greater than 0."];

    if (coefficient == 0) return _zero;
    AGXIntArray *coefficients = [AGXIntArray intArrayWithLength:degree + 1];
    coefficients.array[0] = coefficient;
    return [AGXGenericGFPoly polyWithField:self coefficients:coefficients];
}

+ (int32_t)addOrSubtract:(int32_t)a b:(int32_t)b {
    return a ^ b;
}

- (int32_t)exp:(int)a {
    return _expTable[a];
}

- (int32_t)log:(int)a {
    if AGX_EXPECT_F(a == 0) [NSException raise:NSInvalidArgumentException format:
                             @"Argument must be non-zero."];

    return _logTable[a];
}

- (int32_t)inverse:(int)a {
    if AGX_EXPECT_F(a == 0) [NSException raise:NSInvalidArgumentException format:
                             @"Argument must be non-zero."];

    return _expTable[_size - _logTable[a] - 1];
}

- (int32_t)multiply:(int)a b:(int)b {
    if (a == 0 || b == 0) return 0;
    if (a == 1) return b;
    if (b == 1) return a;
    return _expTable[(_logTable[a] + _logTable[b]) % (_size - 1)];
}

- (BOOL)isEqual:(AGXGenericGF *)object {
    return _primitive == object.primitive && _size == object.size;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"GF(0x%X,%d)", _primitive, _size];
}

@end

@implementation AGXGenericGFPoly {
    AGXGenericGF *_field;
}

+ (AGX_INSTANCETYPE)polyWithField:(AGXGenericGF *)field coefficients:(AGXIntArray *)coefficients {
    return AGX_AUTORELEASE([[self alloc] initWithField:field coefficients:coefficients]);
}

- (AGX_INSTANCETYPE)initWithField:(AGXGenericGF *)field coefficients:(AGXIntArray *)coefficients {
    if AGX_EXPECT_T(self = [super init]) {
        if AGX_EXPECT_F(coefficients.length == 0)
            @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:
                    @"coefficients must have at least one element" userInfo:nil];

        _field = field;
        int coefficientsLength = coefficients.length;
        if (coefficientsLength > 1 && coefficients.array[0] == 0) {
            // Leading term must be non-zero for anything except the constant polynomial "0"
            int firstNonZero = 1;
            while (firstNonZero < coefficientsLength && coefficients.array[firstNonZero] == 0) {
                firstNonZero++;
            }
            if (firstNonZero == coefficientsLength) {
                _coefficients = [[AGXIntArray alloc] initWithLength:1];
            } else {
                _coefficients = [[AGXIntArray alloc] initWithLength:coefficientsLength - firstNonZero];
                for (int i = 0; i < _coefficients.length; i++) {
                    _coefficients.array[i] = coefficients.array[firstNonZero + i];
                }
            }
        } else {
            _coefficients = AGX_RETAIN(coefficients);
        }
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_coefficients);
    _field = nil;
    AGX_SUPER_DEALLOC;
}

- (AGXGenericGF *)field {
    return _field;
}

- (int)degree {
    return _coefficients.length - 1;
}

- (BOOL)zero {
    return _coefficients.array[0] == 0;
}

- (int)coefficient:(int)degree {
    return _coefficients.array[_coefficients.length - 1 - degree];
}

- (int)evaluateAt:(int)a {
    if (a == 0) return [self coefficient:0];

    int size = _coefficients.length;
    int32_t *coefficients = _coefficients.array;
    if (a == 1) {
        // Just the sum of the coefficients
        int result = 0;
        for (int i = 0; i < size; i++) {
            result = [AGXGenericGF addOrSubtract:result b:coefficients[i]];
        }
        return result;
    }
    int result = coefficients[0];
    for (int i = 1; i < size; i++) {
        result = [AGXGenericGF addOrSubtract:[_field multiply:a b:result] b:coefficients[i]];
    }
    return result;
}

- (AGXGenericGFPoly *)addOrSubtract:(AGXGenericGFPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field]) [NSException raise:NSInvalidArgumentException format:
                                                    @"ZXGenericGFPolys do not have same ZXGenericGF field"];

    if AGX_EXPECT_F(self.zero) return other;
    if AGX_EXPECT_F(other.zero) return self;

    AGXIntArray *smallerCoefficients = _coefficients;
    AGXIntArray *largerCoefficients = other.coefficients;
    if (smallerCoefficients.length > largerCoefficients.length) {
        AGXIntArray *temp = smallerCoefficients;
        smallerCoefficients = largerCoefficients;
        largerCoefficients = temp;
    }
    AGXIntArray *sumDiff = [AGXIntArray intArrayWithLength:largerCoefficients.length];
    int lengthDiff = largerCoefficients.length - smallerCoefficients.length;
    // Copy high-order terms only found in higher-degree polynomial's coefficients
    memcpy(sumDiff.array, largerCoefficients.array, lengthDiff * sizeof(int32_t));

    for (int i = lengthDiff; i < largerCoefficients.length; i++) {
        sumDiff.array[i] = [AGXGenericGF addOrSubtract:smallerCoefficients.array[i - lengthDiff] b:largerCoefficients.array[i]];
    }
    return [AGXGenericGFPoly polyWithField:_field coefficients:sumDiff];
}

- (AGXGenericGFPoly *)multiply:(AGXGenericGFPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field]) [NSException raise:NSInvalidArgumentException format:
                                                    @"ZXGenericGFPolys do not have same GenericGF field"];

    if AGX_EXPECT_F(self.zero || other.zero) return _field.zero;
    AGXIntArray *aCoefficients = _coefficients;
    int aLength = aCoefficients.length;
    AGXIntArray *bCoefficients = other.coefficients;
    int bLength = bCoefficients.length;
    AGXIntArray *product = [AGXIntArray intArrayWithLength:aLength + bLength - 1];
    for (int i = 0; i < aLength; i++) {
        int aCoeff = aCoefficients.array[i];
        for (int j = 0; j < bLength; j++) {
            product.array[i + j] = [AGXGenericGF addOrSubtract:product.array[i + j]
                                                            b:[_field multiply:aCoeff b:bCoefficients.array[j]]];
        }
    }
    return [AGXGenericGFPoly polyWithField:_field coefficients:product];
}

- (AGXGenericGFPoly *)multiplyScalar:(int)scalar {
    if AGX_EXPECT_F(scalar == 0) return _field.zero;
    if AGX_EXPECT_F(scalar == 1) return self;
    int size = _coefficients.length;
    int32_t *coefficients = _coefficients.array;
    AGXIntArray *product = [AGXIntArray intArrayWithLength:size];
    for (int i = 0; i < size; i++) {
        product.array[i] = [_field multiply:coefficients[i] b:scalar];
    }
    return [AGXGenericGFPoly polyWithField:_field coefficients:product];
}

- (AGXGenericGFPoly *)multiplyByMonomial:(int)degree coefficient:(int)coefficient {
    if AGX_EXPECT_F(degree < 0) [NSException raise:NSInvalidArgumentException format:
                                 @"Degree must be greater than 0."];

    if AGX_EXPECT_F(coefficient == 0) return _field.zero;
    int size = _coefficients.length;
    int32_t *coefficients = _coefficients.array;
    AGXGenericGF *field = _field;
    AGXIntArray *product = [AGXIntArray intArrayWithLength:size + degree];
    for (int i = 0; i < size; i++) {
        product.array[i] = [field multiply:coefficients[i] b:coefficient];
    }
    return [AGXGenericGFPoly polyWithField:field coefficients:product];
}

- (NSArray *)divide:(AGXGenericGFPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field]) [NSException raise:NSInvalidArgumentException format:
                                                    @"ZXGenericGFPolys do not have same ZXGenericGF field"];

    if AGX_EXPECT_F(other.zero) [NSException raise:NSInvalidArgumentException format:@"Divide by 0"];

    AGXGenericGFPoly *quotient = _field.zero;
    AGXGenericGFPoly *remainder = self;

    int denominatorLeadingTerm = [other coefficient:other.degree];
    int inverseDenominatorLeadingTerm = [_field inverse:denominatorLeadingTerm];

    while (remainder.degree >= other.degree && !remainder.zero) {
        int degreeDifference = remainder.degree - other.degree;
        int scale = [_field multiply:[remainder coefficient:remainder.degree] b:inverseDenominatorLeadingTerm];
        AGXGenericGFPoly *term = [other multiplyByMonomial:degreeDifference coefficient:scale];
        AGXGenericGFPoly *iterationQuotient = [_field buildMonomial:degreeDifference coefficient:scale];
        quotient = [quotient addOrSubtract:iterationQuotient];
        remainder = [remainder addOrSubtract:term];
    }
    return @[quotient, remainder];
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithCapacity:8 * self.degree];
    for (int degree = self.degree; degree >= 0; degree--) {
        int coefficient = [self coefficient:degree];
        if (coefficient != 0) {
            if (coefficient < 0) {
                [result appendString:@" - "];
                coefficient = -coefficient;
            } else {
                if (result.length > 0) {
                    [result appendString:@" + "];
                }
            }
            if (degree == 0 || coefficient != 1) {
                int alphaPower = [_field log:coefficient];
                if (alphaPower == 0) {
                    [result appendString:@"1"];
                } else if (alphaPower == 1) {
                    [result appendString:@"a"];
                } else {
                    [result appendString:@"a^"];
                    [result appendFormat:@"%d", alphaPower];
                }
            }
            if (degree != 0) {
                if (degree == 1) {
                    [result appendString:@"x"];
                } else {
                    [result appendString:@"x^"];
                    [result appendFormat:@"%d", degree];
                }
            }
        }
    }
    return result;
}

@end
