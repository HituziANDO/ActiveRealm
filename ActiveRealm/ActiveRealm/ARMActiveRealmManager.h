//
// Created by Masaki Ando on 2019-05-30.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARMActiveRealmManager : NSObject

@property (nonatomic) RLMRealm *realm;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
