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

+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships {
    return @{
        @"article": [ARMInverseRelationship inverseRelationshipWithClass:NSClassFromString(@"Article")
                                                                    type:ARMInverseRelationshipTypeBelongsTo]
    };
}

+ (BOOL)validateBeforeSaving:(id)obj {
    Tag *tag = obj;

    return tag.articleID.length > 0 && tag.name.length > 0;
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"uid",
        @"articleID",
        @"name",
        @"createdAt",
        @"updatedAt"
    ]].description;
}

#pragma mark - property

- (id)article {
    return self.relations[@"article"].object;
}

@end
