//
// Created by Masaki Ando on 2019-06-05.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "UserSettings.h"

@interface ActiveRealmUserSettings : ARMObject

@property NSString *authorID;
@property NSNumber <RLMBool> *notificationEnabled;

@end

RLM_ARRAY_TYPE(ActiveRealmUserSettings)

@implementation ActiveRealmUserSettings

@end

@implementation UserSettings

- (instancetype)init {
    if (self = [super init]) {
        _notificationEnabled = @NO;
    }

    return self;
}

+ (NSArray<NSString *> *)ignoredProperties {
    return @[ @"isNotificationEnabled" ];
}

+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships {
    return @{
        @"author": [ARMInverseRelationship inverseRelationshipWithClass:NSClassFromString(@"Author")
                                                                   type:ARMInverseRelationshipTypeBelongsTo]
    };
}

+ (BOOL)validateBeforeSaving:(id)obj {
    UserSettings *userSettings = obj;

    return userSettings.authorID.length > 0 && userSettings.notificationEnabled != nil;
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"uid",
        @"authorID",
        @"notificationEnabled",
        @"createdAt",
        @"updatedAt"
    ]].description;
}

#pragma mark - property

- (id)author {
    return self.relations[@"author"].object;
}

- (BOOL)isNotificationEnabled {
    return self.notificationEnabled.boolValue;
}

@end
