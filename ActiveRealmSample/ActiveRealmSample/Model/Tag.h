//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ActiveRealm/ActiveRealm.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tag : ARMActiveRealm

@property (nonatomic, copy) NSString *articleID;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
