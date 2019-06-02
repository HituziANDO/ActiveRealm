//
// Created by Masaki Ando on 2019-05-30.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARMObject : RLMObject

@property NSString *uid;
@property NSDate *createdAt;
@property NSDate *updatedAt;

@end

NS_ASSUME_NONNULL_END
