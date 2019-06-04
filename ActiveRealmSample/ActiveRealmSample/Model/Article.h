//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ActiveRealm/ActiveRealm.h>

NS_ASSUME_NONNULL_BEGIN

@class Author;
@class Tag;

@interface Article : ARMActiveRealm

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, nullable) NSNumber *revision;

// Relation properties. These properties are just aliases.
@property (nonatomic, readonly, nullable) Author *author;
@property (nonatomic, readonly) NSArray<Tag *> *tags;

@end

NS_ASSUME_NONNULL_END
