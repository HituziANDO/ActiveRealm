//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "Tag.h"

@interface ActiveRealmTag : ARMObject

@property NSString *articleID;
@property NSString *name;

@end

RLM_ARRAY_TYPE(ActiveRealmTag)

@implementation ActiveRealmTag

@end

@implementation Tag

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"uid",
        @"articleID",
        @"name",
        @"createdAt",
        @"updatedAt"
    ]].description;
}

@end
