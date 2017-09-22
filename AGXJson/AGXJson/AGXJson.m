//
//  AGXJson.m
//  AGXJson
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXProperty.h>
#import <AGXRuntime/AGXRuntime/NSObject+AGXRuntime.h>
#import "AGXJson.h"
#import "AGXJSONKit.h"

const long AGXJsonVersionNumber = AGXToolkitVersionNumber;
const unsigned char AGXJsonVersionString[] = AGXToolkitVersionString;

NSString *const AGXJSONABLE_CLASS_NAME = @"AGXClassName";
NSString *const AGXJSONABLE_STRUCT_NAME = @"AGXStructName";

BOOL AGX_USE_JSONKIT = NO;

AGX_STATIC BOOL isValidJsonObject(id object);
AGX_STATIC id parseAGXJsonObject(id jsonObject);

@category_implementation(NSData, AGXJson)

- (id)agxJsonObject {
    if (AGX_USE_JSONKIT) {
        return [self objectFromAGXJSONData];
    } else {
        return [NSJSONSerialization
                JSONObjectWithData:self
                options:NSJSONReadingAllowFragments error:NULL];
    }
}

- (id)agxJsonObjectAsClass:(Class)clazz {
    return AGX_AUTORELEASE([[clazz alloc] initWithValidJsonObject:[self agxJsonObject]]);
}

@end

@category_implementation(NSString, AGXJson)

- (id)agxJsonObject {
    if (AGX_USE_JSONKIT) {
        if ([self hasPrefix:@"\""] && [self hasSuffix:@"\""])
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        return [self objectFromAGXJSONString];
    } else {
        return [[self dataUsingEncoding:NSUTF8StringEncoding] agxJsonObject];
    }
}

- (id)agxJsonObjectAsClass:(Class)clazz {
    return AGX_AUTORELEASE([[clazz alloc] initWithValidJsonObject:[self agxJsonObject]]);
}

@end

@category_implementation(NSObject, AGXJson)

- (NSData *)agxJsonData {
    return [self agxJsonDataWithOptions:AGXJsonNone];
}

- (NSData *)agxJsonDataWithOptions:(AGXJsonOptions)options {
    if (!isValidJsonObject(self)) {
        id jsonObject = [self validJsonObjectWithOptions:options];
        if ([jsonObject isKindOfClass:[NSString class]]) {
            return [[NSString stringWithFormat:@"\"%@\"", jsonObject] dataUsingEncoding:NSUTF8StringEncoding];
        } else if (AGX_EXPECT_F(!isValidJsonObject(jsonObject))) {
            return [[jsonObject description] dataUsingEncoding:NSUTF8StringEncoding];
        }
        return AGX_USE_JSONKIT ? [jsonObject AGXJSONData] :
        [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
    }
    return AGX_USE_JSONKIT ? [self performSelector:@selector(AGXJSONData)] :
    [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
}

- (NSString *)agxJsonString {
    return [self agxJsonStringWithOptions:AGXJsonNone];
}

- (NSString *)agxJsonStringWithOptions:(AGXJsonOptions)options {
    NSData *jsonData = [self agxJsonDataWithOptions:options];
    if (AGX_EXPECT_F(!jsonData || [jsonData length] == 0)) return nil;
    return [NSString stringWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@category_implementation(NSObject, AGXJsonable)

static NSArray *NSObjectProperties = nil;

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        NSMutableArray *properties = [NSMutableArray array];
        [NSObject enumerateAGXPropertiesWithBlock:^(AGXProperty *property) {
            [properties addObject:[property name]];
        }];
        NSObjectProperties = [properties copy];
    });
}

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    if (AGX_EXPECT_T(self = [self init])) {
        [self setPropertiesWithValidJsonObject:jsonObject];
    }
    return self;
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
    [self enumerateAGXPropertiesWithBlock:^(id object, AGXProperty *property) {
        if ([property isReadOnly] || [property isWeakReference]
            || [NSObjectProperties containsObject:[property name]]) return;

        id value = [jsonObject objectForKey:[property name]];
        if (!value) return;

        Class propertyClass = [property objectClass];
        if (propertyClass == [NSValue class]) value = [NSValue valueWithValidJsonObject:value];
        else if (propertyClass) value = AGX_AUTORELEASE([[propertyClass alloc] initWithValidJsonObject:value]);
        else value = parseAGXJsonObject(value);

        @try {
            [object setValue:value forKey:[property name]];
        }
        @catch (NSException *exception) {
            AGXLog(@"%@", exception);
        }
    }];
}

- (id)validJsonObject {
    return [self validJsonObjectWithOptions:AGXJsonNone];
}

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    NSMutableDictionary *properties = options & AGXJsonWriteClassName
    ? [NSMutableDictionary dictionaryWithObjectsAndKeys:[[self class] description], AGXJSONABLE_CLASS_NAME, nil]
    : [NSMutableDictionary dictionary];

    [self enumerateAGXPropertiesWithBlock:^(id object, AGXProperty *property) {
        if ([property isWeakReference] || [NSObjectProperties containsObject:[property name]]) return;

        @try {
            id jsonObj = [[object valueForKey:[property name]] validJsonObjectWithOptions:options];
            if (!jsonObj) return;
            [properties setObject:jsonObj forKey:[property name]];
        }
        @catch (NSException *exception) {
            AGXLog(@"%@", exception);
        }
    }];
    return AGX_AUTORELEASE([properties copy]);
}

@end

@category_interface(NSNull, AGXJsonable)
@end
@category_implementation(NSNull, AGXJsonable)

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    return [NSNull null];
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
}

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    return nil;
}

@end

@category_implementation(NSValue, AGXJsonable)

static NSString *const AGXJsonableMappingKey = @"AGXJsonableMapping";

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSValue setRetainProperty:[NSMutableDictionary dictionaryWithDictionary:
                                    @{@(@encode(CGPoint))             :@"CGPoint",
                                      @(@encode(CGVector))            :@"CGVector",
                                      @(@encode(CGSize))              :@"CGSize",
                                      @(@encode(CGRect))              :@"CGRect",
                                      @(@encode(CGAffineTransform))   :@"CGAffineTransform",
                                      @(@encode(UIEdgeInsets))        :@"UIEdgeInsets",
                                      @(@encode(UIOffset))            :@"UIOffset"}]
                   forAssociateKey:AGXJsonableMappingKey];
    });
}

+ (void)addJsonableObjCType:(const char *)objCType withName:(NSString *)typeName {
    [[NSValue retainPropertyForAssociateKey:AGXJsonableMappingKey] setObject:typeName forKey:@(objCType)];
}

+ (NSValue *)valueWithValidJsonObject:(id)jsonObject {
    if (![jsonObject isKindOfClass:[NSDictionary class]]) return nil;
    NSString *typeName = [[NSValue retainPropertyForAssociateKey:AGXJsonableMappingKey]
                          objectForKey:jsonObject[AGXJSONABLE_STRUCT_NAME]];
    if (!typeName) return nil;
    SEL jsonSel = NSSelectorFromString([NSString stringWithFormat:@"valueWithValidJsonObjectFor%@:", typeName]);
    if (!jsonSel || ![self respondsToSelector:jsonSel]) return nil;
    AGX_PerformSelector(return [self performSelector:jsonSel withObject:jsonObject];)
}

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    return [self init];
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
}

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    NSString *objCType = @([self objCType]);
    NSString *typeName = [[NSValue retainPropertyForAssociateKey:AGXJsonableMappingKey] objectForKey:objCType];
    if (!typeName) return [super validJsonObjectWithOptions:options];
    SEL jsonSel = NSSelectorFromString([NSString stringWithFormat:@"validJsonObjectFor%@", typeName]);
    if (!jsonSel || ![self respondsToSelector:jsonSel]) return [super validJsonObjectWithOptions:options];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   objCType, AGXJSONABLE_STRUCT_NAME, nil];
    AGX_PerformSelector([result addEntriesFromDictionary:[self performSelector:jsonSel]];)
    return AGX_AUTORELEASE([result copy]);
}

#pragma mark - json encode/decode implementation

#define selfIsStructType(type) \
(strcmp([self objCType], @encode(type)) == 0)
#define jsonIsStructType(jsonObject, type) \
(strcmp([jsonObject[AGXJSONABLE_STRUCT_NAME] UTF8String], @encode(type)) == 0)

- (id)validJsonObjectForCGPoint {
    if (AGX_EXPECT_F(!selfIsStructType(CGPoint))) return nil;
    CGPoint p = [self CGPointValue];
    return @{@"x": @(p.x), @"y": @(p.y)};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGPoint:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, CGPoint))) return nil;
    CGFloat x = [[jsonObject objectForKey:@"x"] cgfloatValue];
    CGFloat y = [[jsonObject objectForKey:@"y"] cgfloatValue];
    return [NSValue valueWithCGPoint:CGPointMake(x, y)];
}

- (id)validJsonObjectForCGVector {
    if (AGX_EXPECT_F(!selfIsStructType(CGVector))) return nil;
    CGVector v = [self CGVectorValue];
    return @{@"dx": @(v.dx), @"dy": @(v.dy)};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGVector:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, CGVector))) return nil;
    CGFloat dx = [[jsonObject objectForKey:@"dx"] cgfloatValue];
    CGFloat dy = [[jsonObject objectForKey:@"dy"] cgfloatValue];
    return [NSValue valueWithCGVector:CGVectorMake(dx, dy)];
}

- (id)validJsonObjectForCGSize {
    if (AGX_EXPECT_F(!selfIsStructType(CGSize))) return nil;
    CGSize s = [self CGSizeValue];
    return @{@"width": @(s.width), @"height": @(s.height)};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGSize:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, CGSize))) return nil;
    CGFloat width = [[jsonObject objectForKey:@"width"] cgfloatValue];
    CGFloat height = [[jsonObject objectForKey:@"height"] cgfloatValue];
    return [NSValue valueWithCGSize:CGSizeMake(width, height)];
}

- (id)validJsonObjectForCGRect {
    if (AGX_EXPECT_F(!selfIsStructType(CGRect))) return nil;
    CGRect r = [self CGRectValue];
    return @{@"origin": [[NSValue valueWithCGPoint:r.origin] validJsonObject],
             @"size": [[NSValue valueWithCGSize:r.size] validJsonObject]};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGRect:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, CGRect))) return nil;
    NSValue *origin = [NSValue valueWithValidJsonObject:[jsonObject objectForKey:@"origin"]];
    NSValue *size = [NSValue valueWithValidJsonObject:[jsonObject objectForKey:@"size"]];
    return [NSValue valueWithCGRect:AGX_CGRectMake([origin CGPointValue], [size CGSizeValue])];
}

- (id)validJsonObjectForCGAffineTransform {
    if (AGX_EXPECT_F(!selfIsStructType(CGAffineTransform))) return nil;
    CGAffineTransform t = [self CGAffineTransformValue];
    return @{@"a": @(t.a), @"b": @(t.b), @"c": @(t.c), @"d": @(t.d),
             @"tx": @(t.tx), @"ty": @(t.ty)};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGAffineTransform:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, CGAffineTransform))) return nil;
    CGFloat a = [[jsonObject objectForKey:@"a"] cgfloatValue];
    CGFloat b = [[jsonObject objectForKey:@"b"] cgfloatValue];
    CGFloat c = [[jsonObject objectForKey:@"c"] cgfloatValue];
    CGFloat d = [[jsonObject objectForKey:@"d"] cgfloatValue];
    CGFloat tx = [[jsonObject objectForKey:@"tx"] cgfloatValue];
    CGFloat ty = [[jsonObject objectForKey:@"ty"] cgfloatValue];
    return [NSValue valueWithCGAffineTransform:CGAffineTransformMake(a, b, c, d, tx, ty)];
}

- (id)validJsonObjectForUIEdgeInsets {
    if (AGX_EXPECT_F(!selfIsStructType(UIEdgeInsets))) return nil;
    UIEdgeInsets e = [self UIEdgeInsetsValue];
    return @{@"top": @(e.top), @"left": @(e.left),
             @"bottom": @(e.bottom), @"right": @(e.right)};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForUIEdgeInsets:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, UIEdgeInsets))) return nil;
    CGFloat top = [[jsonObject objectForKey:@"top"] cgfloatValue];
    CGFloat left = [[jsonObject objectForKey:@"left"] cgfloatValue];
    CGFloat bottom = [[jsonObject objectForKey:@"bottom"] cgfloatValue];
    CGFloat right = [[jsonObject objectForKey:@"right"] cgfloatValue];
    return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(top, left, bottom, right)];
}

- (id)validJsonObjectForUIOffset {
    if (AGX_EXPECT_F(!selfIsStructType(UIOffset))) return nil;
    UIOffset o = [self UIOffsetValue];
    return @{@"horizontal": @(o.horizontal), @"vertical": @(o.vertical)};
}

+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForUIOffset:(id)jsonObject {
    if (AGX_EXPECT_F(!jsonIsStructType(jsonObject, UIOffset))) return nil;
    CGFloat horizontal = [[jsonObject objectForKey:@"horizontal"] cgfloatValue];
    CGFloat vertical = [[jsonObject objectForKey:@"vertical"] cgfloatValue];
    return [NSValue valueWithUIOffset:UIOffsetMake(horizontal, vertical)];
}

#undef jsonIsStructType
#undef selfIsStructType

@end

@category_interface(NSNumber, AGXJsonable)
@end
@category_implementation(NSNumber, AGXJsonable)

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSNumber class]]) {
        return [self initWithDouble:[jsonObject doubleValue]];
    }
    return [self init];
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
}

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    if (isnan([self doubleValue]) || isinf([self doubleValue])) return nil;
    return self;
}

@end

@category_interface(NSString, AGXJsonable)
@end
@category_implementation(NSString, AGXJsonable)

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSString class]]) {
        return [self initWithString:jsonObject];
    }
    return [self init];
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
}

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    return self;
}

@end

@category_implementation(NSArray, AGXJsonable)

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    if ([NSJSONSerialization isValidJSONObject:self]) return self;

    NSMutableArray *array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         id jsonObj = [obj validJsonObjectWithOptions:options];
         if (!jsonObj) return;
         [array addObject:jsonObj];
     }];
    return AGX_AUTORELEASE([array copy]);
}

+ (AGX_INSTANCETYPE)arrayWithValidJsonObject:(id)jsonObject {
    return AGX_AUTORELEASE([[self alloc] initWithValidJsonObject:jsonObject]);
}

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *unjsonArray = [NSMutableArray array];
        [jsonObject enumerateObjectsUsingBlock:
         ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             [unjsonArray addObject:parseAGXJsonObject(obj)];
         }];
        return [self initWithArray:unjsonArray copyItems:YES];
    }
    return [self init];
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
}

@end

@category_implementation(NSDictionary, AGXJsonable)

- (id)validJsonObjectWithOptions:(AGXJsonOptions)options {
    if ([NSJSONSerialization isValidJSONObject:self]) return self;

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:
     ^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
         [dictionary setObject:[obj validJsonObjectWithOptions:options]
                        forKey:[key validJsonObjectWithOptions:options]];
     }];
    return AGX_AUTORELEASE([dictionary copy]);
}

+ (AGX_INSTANCETYPE)dictionaryWithValidJsonObject:(id)jsonObject {
    return AGX_AUTORELEASE([[self alloc] initWithValidJsonObject:jsonObject]);
}

- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *unjsonDictionary = [NSMutableDictionary dictionary];
        [jsonObject enumerateKeysAndObjectsUsingBlock:
         ^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
             [unjsonDictionary setObject:parseAGXJsonObject(obj)
                                  forKey:parseAGXJsonObject(key)];
         }];
        return [self initWithDictionary:unjsonDictionary copyItems:YES];
    }
    return [self init];
}

- (void)setPropertiesWithValidJsonObject:(id)jsonObject {
}

@end

AGX_STATIC BOOL isValidJsonObject(id object) {
    return AGX_USE_JSONKIT ? [object isKindOfClass:[NSString class]]
    || [object isKindOfClass:[NSArray class]]
    || [object isKindOfClass:[NSDictionary class]] :
    [NSJSONSerialization isValidJSONObject:object];
}

AGX_STATIC id parseAGXJsonObject(id jsonObject) {
    if ([jsonObject isKindOfClass:[NSArray class]]) return [NSArray arrayWithValidJsonObject:jsonObject];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        if ([jsonObject objectForKey:AGXJSONABLE_STRUCT_NAME])
            return [NSValue valueWithValidJsonObject:jsonObject];
        if ([jsonObject objectForKey:AGXJSONABLE_CLASS_NAME]) {
            Class clz = objc_getClass([[jsonObject objectForKey:AGXJSONABLE_CLASS_NAME] UTF8String]);
            if (AGX_EXPECT_T(clz)) return AGX_AUTORELEASE([[clz alloc] initWithValidJsonObject:jsonObject]);
        }
        return [NSDictionary dictionaryWithValidJsonObject:jsonObject];
    } return jsonObject;
}
