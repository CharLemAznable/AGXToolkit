//
//  AGXPDF417ECErrorCorrection.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/3.
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

#import "AGXPDF417ECErrorCorrection.h"
#import "AGXPDF417Common.h"

@class AGXModulusGF, AGXModulusPoly;

@interface AGXModulusGF : NSObject
@property (nonatomic, readonly) AGXModulusPoly *one;
@property (nonatomic, readonly) AGXModulusPoly *zero;

+ (AGX_INSTANCETYPE)PDF417_GF;
- (AGX_INSTANCETYPE)initWithModulus:(int)modulus generator:(int)generator;
- (AGXModulusPoly *)buildMonomial:(int)degree coefficient:(int)coefficient;
- (int)add:(int)a b:(int)b;
- (int)subtract:(int)a b:(int)b;
- (int)exp:(int)a;
- (int)log:(int)a;
- (int)inverse:(int)a;
- (int)multiply:(int)a b:(int)b;
- (int)size;
@end

@interface AGXModulusPoly : NSObject
- (AGX_INSTANCETYPE)initWithField:(AGXModulusGF *)field coefficients:(AGXIntArray *)coefficients;
- (int)degree;
- (BOOL)zero;
- (int)coefficient:(int)degree;
- (int)evaluateAt:(int)a;
- (AGXModulusPoly *)add:(AGXModulusPoly *)other;
- (AGXModulusPoly *)subtract:(AGXModulusPoly *)other;
- (AGXModulusPoly *)multiply:(AGXModulusPoly *)other;
- (AGXModulusPoly *)negative;
- (AGXModulusPoly *)multiplyScalar:(int)scalar;
- (AGXModulusPoly *)multiplyByMonomial:(int)degree coefficient:(int)coefficient;
- (NSArray *)divide:(AGXModulusPoly *)other;
@end

@interface AGXPDF417ECErrorCorrection ()
@property (nonatomic, readonly) AGXModulusGF *field;
@end

@singleton_implementation(AGXPDF417ECErrorCorrection)

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _field = AGX_RETAIN(AGXModulusGF.PDF417_GF);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_field);
    AGX_SUPER_DEALLOC;
}

- (int)decode:(AGXIntArray *)received numECCodewords:(int)numECCodewords erasures:(AGXIntArray *)erasures {
    AGXModulusPoly *poly = AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:received]);
    AGXIntArray *S = [AGXIntArray intArrayWithLength:numECCodewords];
    BOOL error = NO;
    for (int i = numECCodewords; i > 0; i--) {
        int eval = [poly evaluateAt:[_field exp:i]];
        S.array[numECCodewords - i] = eval;
        if AGX_EXPECT_F(eval != 0) error = YES;
    }
    if AGX_EXPECT_F(!error) return 0;

    AGXModulusPoly *knownErrors = _field.one;
    if (erasures) {
        for (int i = 0; i < erasures.length; i++) {
            int erasure = erasures.array[i];
            int b = [_field exp:received.length - 1 - erasure];
            // Add (1 - bx) term:
            AGXModulusPoly *term = AGX_AUTORELEASE(([[AGXModulusPoly alloc] initWithField:_field coefficients:[AGXIntArray intArrayWithInts:[_field subtract:0 b:b], 1, -1]]));
            knownErrors = [knownErrors multiply:term];
        }
    }

    AGXModulusPoly *syndrome = AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:S]);
    //[syndrome multiply:knownErrors];

    NSArray *sigmaOmega = [self runEuclideanAlgorithm:[_field buildMonomial:numECCodewords coefficient:1] b:syndrome R:numECCodewords];
    if AGX_EXPECT_F(!sigmaOmega) return -1;

    AGXModulusPoly *sigma = sigmaOmega[0];
    AGXModulusPoly *omega = sigmaOmega[1];

    //sigma = [sigma multiply:knownErrors];

    AGXIntArray *errorLocations = [self findErrorLocations:sigma];
    if AGX_EXPECT_F(!errorLocations) return -1;
    AGXIntArray *errorMagnitudes = [self findErrorMagnitudes:omega errorLocator:sigma errorLocations:errorLocations];

    for (int i = 0; i < errorLocations.length; i++) {
        int position = received.length - 1 - [_field log:errorLocations.array[i]];
        if AGX_EXPECT_F(position < 0) return -1;
        received.array[position] = [_field subtract:received.array[position] b:errorMagnitudes.array[i]];
    }

    return errorLocations.length;
}

- (NSArray *)runEuclideanAlgorithm:(AGXModulusPoly *)a b:(AGXModulusPoly *)b R:(int)R {
    // Assume a's degree is >= b's
    if (a.degree < b.degree) {
        AGXModulusPoly *temp = a;
        a = b;
        b = temp;
    }

    AGXModulusPoly *rLast = a;
    AGXModulusPoly *r = b;
    AGXModulusPoly *tLast = _field.zero;
    AGXModulusPoly *t = _field.one;

    // Run Euclidean algorithm until r's degree is less than R/2
    while (r.degree >= R / 2) {
        AGXModulusPoly *rLastLast = rLast;
        AGXModulusPoly *tLastLast = tLast;
        rLast = r;
        tLast = t;

        // Divide rLastLast by rLast, with quotient in q and remainder in r
        if AGX_EXPECT_F(rLast.zero) {
            // Oops, Euclidean algorithm already terminated?
            return nil;
        }
        r = rLastLast;
        AGXModulusPoly *q = _field.zero;
        int denominatorLeadingTerm = [rLast coefficient:rLast.degree];
        int dltInverse = [_field inverse:denominatorLeadingTerm];
        while (r.degree >= rLast.degree && !r.zero) {
            int degreeDiff = r.degree - rLast.degree;
            int scale = [_field multiply:[r coefficient:r.degree] b:dltInverse];
            q = [q add:[_field buildMonomial:degreeDiff coefficient:scale]];
            r = [r subtract:[rLast multiplyByMonomial:degreeDiff coefficient:scale]];
        }

        t = [[q multiply:tLast] subtract:tLastLast].negative;
    }

    int sigmaTildeAtZero = [t coefficient:0];
    if AGX_EXPECT_F(sigmaTildeAtZero == 0) return nil;

    int inverse = [_field inverse:sigmaTildeAtZero];
    AGXModulusPoly *sigma = [t multiplyScalar:inverse];
    AGXModulusPoly *omega = [r multiplyScalar:inverse];
    return @[sigma, omega];
}

- (AGXIntArray *)findErrorLocations:(AGXModulusPoly *)errorLocator {
    // This is a direct application of Chien's search
    int numErrors = errorLocator.degree;
    AGXIntArray *result = [AGXIntArray intArrayWithLength:numErrors];
    int e = 0;
    for (int i = 1; i < _field.size && e < numErrors; i++) {
        if ([errorLocator evaluateAt:i] == 0) {
            result.array[e] = [_field inverse:i];
            e++;
        }
    }
    if AGX_EXPECT_F(e != numErrors) return nil;
    return result;
}

- (AGXIntArray *)findErrorMagnitudes:(AGXModulusPoly *)errorEvaluator errorLocator:(AGXModulusPoly *)errorLocator errorLocations:(AGXIntArray *)errorLocations {
    int errorLocatorDegree = errorLocator.degree;
    AGXIntArray *formalDerivativeCoefficients = [AGXIntArray intArrayWithLength:errorLocatorDegree];
    for (int i = 1; i <= errorLocatorDegree; i++) {
        formalDerivativeCoefficients.array[errorLocatorDegree - i] =
        [_field multiply:i b:[errorLocator coefficient:i]];
    }
    AGXModulusPoly *formalDerivative = AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:formalDerivativeCoefficients]);

    // This is directly applying Forney's Formula
    int s = errorLocations.length;
    AGXIntArray *result = [AGXIntArray intArrayWithLength:s];
    for (int i = 0; i < s; i++) {
        int xiInverse = [_field inverse:errorLocations.array[i]];
        int numerator = [_field subtract:0 b:[errorEvaluator evaluateAt:xiInverse]];
        int denominator = [_field inverse:[formalDerivative evaluateAt:xiInverse]];
        result.array[i] = [_field multiply:numerator b:denominator];
    }
    return result;
}

@end

@implementation AGXModulusGF {
    int32_t *_expTable;
    int32_t *_logTable;
    int _modulus;
}

static id _PDF417_GF = nil;
+ (AGX_INSTANCETYPE)PDF417_GF {
    agx_once
    (_PDF417_GF = [[self alloc] initWithModulus:AGX_PDF417_NUMBER_OF_CODEWORDS generator:3];);
    return _PDF417_GF;
}

- (AGX_INSTANCETYPE)initWithModulus:(int)modulus generator:(int)generator {
    if AGX_EXPECT_T(self = [super init]) {
        _modulus = modulus;
        _expTable = (int32_t *)calloc(_modulus, sizeof(int32_t));
        _logTable = (int32_t *)calloc(_modulus, sizeof(int32_t));
        int32_t x = 1;
        for (int i = 0; i < modulus; i++) {
            _expTable[i] = x;
            x = (x * generator) % modulus;
        }
        for (int i = 0; i < _modulus - 1; i++) {
            _logTable[_expTable[i]] = i;
        }
        // logTable[0] == 0 but this should never be used
        _zero = [[AGXModulusPoly alloc] initWithField:self coefficients:[AGXIntArray intArrayWithLength:1]];
        _one = [[AGXModulusPoly alloc] initWithField:self coefficients:[AGXIntArray intArrayWithInts:1, -1]];
    }
    return self;
}

- (void)dealloc {
    if (_expTable) free(_expTable);
    if (_logTable) free(_logTable);
    AGX_RELEASE(_zero);
    AGX_RELEASE(_one);
    AGX_SUPER_DEALLOC;
}

- (AGXModulusPoly *)buildMonomial:(int)degree coefficient:(int)coefficient {
    if AGX_EXPECT_F(degree < 0)
        [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];

    if (coefficient == 0) {
        return _zero;
    }
    AGXIntArray *coefficients = [AGXIntArray intArrayWithLength:degree + 1];
    coefficients.array[0] = coefficient;
    return AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:self coefficients:coefficients]);
}

- (int)add:(int)a b:(int)b {
    return (a + b) % _modulus;
}

- (int)subtract:(int)a b:(int)b {
    return (_modulus + a - b) % _modulus;
}

- (int)exp:(int)a {
    return _expTable[a];
}

- (int)log:(int)a {
    if AGX_EXPECT_F(a == 0)
        [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
    return _logTable[a];
}

- (int)inverse:(int)a {
    if AGX_EXPECT_F(a == 0)
        [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
    return _expTable[_modulus - _logTable[a] - 1];
}

- (int)multiply:(int)a b:(int)b {
    if (a == 0 || b == 0) {
        return 0;
    }
    return _expTable[(_logTable[a] + _logTable[b]) % (_modulus - 1)];
}

- (int)size {
    return _modulus;
}

@end

@implementation AGXModulusPoly {
    AGXIntArray *_coefficients;
    AGXModulusGF *_field;
}

- (AGX_INSTANCETYPE)initWithField:(AGXModulusGF *)field coefficients:(AGXIntArray *)coefficients {
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

- (AGXIntArray *)coefficients {
    return _coefficients;
}

- (AGXModulusGF *)field {
    return _field;
}

/**
 * @return degree of this polynomial
 */
- (int)degree {
    return _coefficients.length - 1;
}

/**
 * @return true iff this polynomial is the monomial "0"
 */
- (BOOL)zero {
    return _coefficients.array[0] == 0;
}

/**
 * @return coefficient of x^degree term in this polynomial
 */
- (int)coefficient:(int)degree {
    return _coefficients.array[_coefficients.length - 1 - degree];
}

/**
 * @return evaluation of this polynomial at a given point
 */
- (int)evaluateAt:(int)a {
    if (a == 0) return [self coefficient:0];

    int size = _coefficients.length;
    if (a == 1) {
        // Just the sum of the coefficients
        int result = 0;
        for (int i = 0; i < size; i++) {
            result = [_field add:result b:_coefficients.array[i]];
        }
        return result;
    }
    int result = _coefficients.array[0];
    for (int i = 1; i < size; i++) {
        result = [_field add:[_field multiply:a b:result] b:_coefficients.array[i]];
    }
    return result;
}

- (AGXModulusPoly *)add:(AGXModulusPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field])
        [NSException raise:NSInvalidArgumentException format:
         @"ZXModulusPolys do not have same ZXModulusGF field"];

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
        sumDiff.array[i] = [_field add:smallerCoefficients.array[i - lengthDiff] b:largerCoefficients.array[i]];
    }
    return AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:sumDiff]);
}

- (AGXModulusPoly *)subtract:(AGXModulusPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field])
        [NSException raise:NSInvalidArgumentException format:
         @"ZXModulusPolys do not have same ZXModulusGF field"];

    if AGX_EXPECT_F(self.zero) return self;
    return [self add:other.negative];
}

- (AGXModulusPoly *)multiply:(AGXModulusPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field])
        [NSException raise:NSInvalidArgumentException format:
         @"ZXModulusPolys do not have same ZXModulusGF field"];

    if AGX_EXPECT_F(self.zero || other.zero) return _field.zero;

    AGXIntArray *aCoefficients = _coefficients;
    int aLength = aCoefficients.length;
    AGXIntArray *bCoefficients = other.coefficients;
    int bLength = bCoefficients.length;
    AGXIntArray *product = [AGXIntArray intArrayWithLength:aLength + bLength - 1];
    for (int i = 0; i < aLength; i++) {
        int aCoeff = aCoefficients.array[i];
        for (int j = 0; j < bLength; j++) {
            product.array[i + j] = [_field add:product.array[i + j]
                                             b:[_field multiply:aCoeff b:bCoefficients.array[j]]];
        }
    }
    return AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:product]);
}

- (AGXModulusPoly *)negative {
    int size = _coefficients.length;
    AGXIntArray *negativeCoefficients = [AGXIntArray intArrayWithLength:size];
    for (int i = 0; i < size; i++) {
        negativeCoefficients.array[i] = [_field subtract:0 b:_coefficients.array[i]];
    }
    return AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:negativeCoefficients]);
}

- (AGXModulusPoly *)multiplyScalar:(int)scalar {
    if AGX_EXPECT_F(scalar == 0) return _field.zero;
    if AGX_EXPECT_F(scalar == 1) return self;
    int size = _coefficients.length;
    AGXIntArray *product = [AGXIntArray intArrayWithLength:size];
    for (int i = 0; i < size; i++) {
        product.array[i] = [_field multiply:_coefficients.array[i] b:scalar];
    }
    return AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:product]);
}

- (AGXModulusPoly *)multiplyByMonomial:(int)degree coefficient:(int)coefficient {
    if AGX_EXPECT_F(degree < 0)
        [NSException raise:NSInvalidArgumentException format:
         @"Degree must be greater than 0."];

    if AGX_EXPECT_F(coefficient == 0) return _field.zero;
    int size = _coefficients.length;
    AGXIntArray *product = [AGXIntArray intArrayWithLength:size + degree];
    for (int i = 0; i < size; i++) {
        product.array[i] = [_field multiply:_coefficients.array[i] b:coefficient];
    }
    return AGX_AUTORELEASE([[AGXModulusPoly alloc] initWithField:_field coefficients:product]);
}

- (NSArray *)divide:(AGXModulusPoly *)other {
    if AGX_EXPECT_F(![_field isEqual:other.field])
        [NSException raise:NSInvalidArgumentException format:
         @"ZXModulusPolys do not have same ZXModulusGF field"];

    if AGX_EXPECT_F(other.zero)
        [NSException raise:NSInvalidArgumentException format:@"Divide by 0"];

    AGXModulusPoly *quotient = _field.zero;
    AGXModulusPoly *remainder = self;

    int denominatorLeadingTerm = [other coefficient:other.degree];
    int inverseDenominatorLeadingTerm = [_field inverse:denominatorLeadingTerm];

    while (remainder.degree >= other.degree && !remainder.zero) {
        int degreeDifference = remainder.degree - other.degree;
        int scale = [_field multiply:[remainder coefficient:remainder.degree] b:inverseDenominatorLeadingTerm];
        AGXModulusPoly *term = [other multiplyByMonomial:degreeDifference coefficient:scale];
        AGXModulusPoly *iterationQuotient = [_field buildMonomial:degreeDifference coefficient:scale];
        quotient = [quotient add:iterationQuotient];
        remainder = [remainder subtract:term];
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
                [result appendFormat:@"%d", coefficient];
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
