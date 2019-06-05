//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ActiveRealm/ActiveRealm.h>

NS_ASSUME_NONNULL_BEGIN

@class Article;
@class UserSettings;

@interface Author : ARMActiveRealm

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *age;

// Relation properties. These properties are just aliases.
@property (nonatomic, readonly, nullable) UserSettings *userSettings;
@property (nonatomic, readonly) NSArray<Article *> *articles;

@end

NS_ASSUME_NONNULL_END
