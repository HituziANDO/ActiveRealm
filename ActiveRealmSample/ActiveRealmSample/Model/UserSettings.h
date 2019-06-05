//
// Created by Masaki Ando on 2019-06-05.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ActiveRealm/ActiveRealm.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserSettings : ARMActiveRealm

@property (nonatomic, copy) NSString *authorID;
@property (nonatomic) NSNumber *notificationEnabled;

// A relation property. This property is just alias.
@property (nonatomic, readonly) id author;

// A property ignored by ActiveRealm.
@property (nonatomic, readonly) BOOL isNotificationEnabled;

@end

NS_ASSUME_NONNULL_END
