//
// Created by Masaki Ando on 2019-05-30.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "ARMClassMapper.h"

@implementation ARMClassMapper

+ (instancetype)sharedInstance {
    static ARMClassMapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ARMClassMapper new];
    });

    return instance;
}

- (Class)map:(Class)aClass {
    NSString *className = NSStringFromClass(aClass);

    if (self.vendorPrefix.length > 0) {
        className = [className substringFromIndex:self.vendorPrefix.length];
    }

    NSString *arClassName = [NSString stringWithFormat:@"ActiveRealm%@", className];
    Class arClass = NSClassFromString(arClassName);

    if (!arClass) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%@ class is not found.", arClassName]
                                     userInfo:nil];
    }

    return arClass;
}

@end
