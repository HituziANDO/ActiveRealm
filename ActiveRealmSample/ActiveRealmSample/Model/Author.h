//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ActiveRealm/ActiveRealm.h>

NS_ASSUME_NONNULL_BEGIN

@interface Author : ARMActiveRealm

@property (nonatomic, copy) NSString *articleID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *age;
@property (nonatomic, copy, nullable) NSString *country;

// Relation properties. These properties are just aliases.
@property (nonatomic, readonly) id article;

@end

NS_ASSUME_NONNULL_END
