//
//  JCPropertyMapper.m
//  JCModel
//
//  Created by Joseph Constantakis on 10/25/13.
//  Copyright (c) 2013 Joseph Constantakis. All rights reserved.
//

#import "JCPropertyMapper.h"
#import "NSObject+Properties.h"
#import "NSDictionary+CustomKVC.h"
#import "NSArray+CustomKVC.h"
#import "NSObject+CustomKVC.h"
#import "NSBundle+PList.h"

@implementation JCPropertyMapper

+ (BOOL)mapDictionary:(id)src toObject:(id <JCPropertyMappee>)object usingMappingPlist:(NSString *)plistName
{
    id plist = [[NSBundle mainBundle] plistNamed:plistName];
    if (!plist)
        return NO;
    
    [self mapDictionary:src toObject:object usingMapping:plist];
    return YES;
}

+ (void)mapDictionary:(id)src toObject:(id <JCPropertyMappee>)object usingMapping:(id)idTypeMapping
{
    NSAssert(object, @"destination object cannot be nil");
    NSAssert(src, @"source object cannot be nil");
    
    NSDictionary *mapping = [idTypeMapping isKindOfClass:[NSArray class]]
                            ? [NSDictionary dictionaryWithObjects:idTypeMapping forKeys:idTypeMapping]
                            : idTypeMapping;
    
    for (NSString *unresolvedRemoteKey in mapping) {
        
        NSString *localKey = mapping[unresolvedRemoteKey];

        NSString *remoteKey = [self resolveDynamicAttributesInRemoteKey:unresolvedRemoteKey source:src object:object mapping:mapping];
            
        if ([remoteKey hasPrefix:@"@"] && ![remoteKey hasPrefix:@"@("]) //ignore meta-keys
            continue;
        
        [self mapRemoteKey:remoteKey fromSource:src toLocalKey:localKey inObject:object withMapping:mapping];
    }
}

+ (NSString *)resolveDynamicAttributesInRemoteKey:(NSString *)remoteKey
                                           source:(id)src
                                           object:(id <JCPropertyMappee>)object
                                          mapping:(NSDictionary *)mapping
{
    //Use regex to check for dynamic nesting attributes in the style of
    //https://github.com/RestKit/RestKit/wiki/Object-mapping#handling-dynamic-nesting-attributes
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@\\(([\\w\\.]*)\\)"
                                                                           options:0
                                                                             error:nil];
    [regex enumerateMatchesInString:remoteKey
                            options:0
                              range:NSMakeRange(0, remoteKey.length)
     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         
         if (flags & NSMatchingInternalError)
             return;
         
         NSRange resultRange = result.range;
         NSRange capGroup1 = [result rangeAtIndex:1];
         
         //e.g. given json "stock": {"AAPL": "Apple Inc."} & mapping remote key stock.@(ticker), assign @"AAPL" to local key "ticker"
         NSString *localKey = [remoteKey substringWithRange:capGroup1];
         NSString *remoteKeyPrefix = resultRange.location ? [remoteKey substringToIndex:resultRange.location] : @"";
         NSString *remoteSubKey = [remoteKeyPrefix stringByAppendingString:@"$"];
         
         [self mapRemoteKey:remoteSubKey fromSource:src toLocalKey:localKey inObject:object withMapping:mapping];
    }];
    
    //replace stock.@(tickers) with stock.*
    return [regex stringByReplacingMatchesInString:remoteKey
                                           options:0
                                             range:NSMakeRange(0, remoteKey.length)
                                      withTemplate:@"\\*"];
}

+ (void)mapRemoteKey:(NSString *)remoteKey
          fromSource:(id)src
          toLocalKey:(NSString *)localKey
            inObject:(id/* <JCPropertyMappee>*/)object
         withMapping:(NSDictionary *)mapping
{
    id value = [src jc_valueForKeyPath:remoteKey];
    if (!value) {
        NSLog(@"mapping error: remote source %@ has no value for key path %@", src, remoteKey);
        return;
    }
    if (value == [NSNull null]) {
        value = nil;
    }
    
    if ([object hasPropertyNamed:localKey]) {
        
        Class destClass = [[object class] classOfPropertyNamed:localKey];
        NSDictionary *attributes = [self attributesForKey:remoteKey inMapping:mapping];
        
        id transformed;
        if ([object respondsToSelector:@selector(transformValue:forLocalKey:)]) {
            transformed = [[object class] transformValue:value forLocalKey:localKey];
        }
        if (!transformed) {
            transformed = [self value:value transformedToClass:destClass withAttributes:attributes];
        }
        
        [object setValue:transformed forKey:localKey];
    } else {
        NSLog(@"mapping error: object %@ has no property named %@", object, localKey);
    }
}

+ (NSDictionary *)attributesForKey:(NSString *)remoteKey inMapping:(NSDictionary *)mapping
{
    NSString *prefix = [NSString stringWithFormat:@"@%@.", remoteKey];
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    for (NSString *key in mapping) {
        if ([key hasPrefix:prefix]) {
            NSString *attrKey = [key substringFromIndex:prefix.length];
            //e.g. ret[@"dateFormat"] = mapping[@"@created.dateFormat"]
            ret[attrKey] = mapping[key];
        }
    }
    
    return ret;
}

+ (id)value:(id)value transformedToClass:(Class)destClass withAttributes:(NSDictionary *)attributes
{
    if (!value)
        return value;
    if ([[value class] isSubclassOfClass:destClass])
        return value;
    if ([[value class] isSubclassOfClass:[NSString class]]) {
        if (destClass == [NSNumber class]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            if ([value rangeOfString:@"%"].location != NSNotFound)
                [f setNumberStyle:NSNumberFormatterPercentStyle];
            if ([value characterAtIndex:0] == '+')
                [f setPositivePrefix:@"+"];
            else if ([value characterAtIndex:0] == '-')
                [f setNegativePrefix:@"-"];
            return [f numberFromString:value];
        } if (destClass == [NSDate class]) {
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            if (attributes[kAttrDateFormat])
                [f setDateFormat:attributes[kAttrDateFormat]];
            return [f dateFromString:value];
        } if (destClass == [NSURL class]) {
            return [NSURL URLWithString:value];
        }
    }
    if ([[value class] isSubclassOfClass:[NSArray class]]) {
        if (destClass == [NSSet class])
            return [NSSet setWithArray:value];
        if (destClass == [NSMutableSet class])
            return [NSMutableSet setWithArray:value];
        if (destClass == [NSOrderedSet class])
            return [NSOrderedSet orderedSetWithArray:value];
        if (destClass == [NSMutableOrderedSet class])
            return [NSMutableOrderedSet orderedSetWithArray:value];
        if (destClass == [NSString class]) {
            if ([value count] == 1 && [value[0] isKindOfClass:[NSString class]])
                return value[0];
        }
    }
    if (destClass == [NSString class])
        return [value description];
    NSLog(@"failed to transform value %@ to class %@", value, destClass);
    return value;
}


@end
