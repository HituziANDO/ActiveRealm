//
// Created by Masaki Ando on 2019-05-30.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARMClassMapper : NSObject

@property (nonatomic, copy, nullable) NSString *vendorPrefix;

+ (instancetype)sharedInstance;

- (Class)map:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
