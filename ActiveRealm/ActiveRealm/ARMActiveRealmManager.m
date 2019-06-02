//
// Created by Masaki Ando on 2019-05-30.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "ARMActiveRealmManager.h"

@implementation ARMActiveRealmManager

+ (instancetype)sharedInstance {
    static ARMActiveRealmManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ARMActiveRealmManager new];
    });

    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _realm = [RLMRealm defaultRealm];
    }

    return self;
}

#pragma mark - property

- (void)setRealm:(RLMRealm *)realm {
    if (realm) {
        _realm = realm;
    }
}

@end
