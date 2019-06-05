//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "Author.h"

#import "Article.h"
#import "UserSettings.h"

@interface ActiveRealmAuthor : ARMObject

@property NSString *name;
@property NSNumber <RLMInt> *age;

@end

RLM_ARRAY_TYPE(ActiveRealmAuthor)

@implementation ActiveRealmAuthor

@end

@implementation Author

+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships {
    return @{
        @"userSettings": [ARMRelationship relationshipWithClass:UserSettings.class
                                                           type:ARMRelationshipTypeHasOne],
        @"articles": [ARMRelationship relationshipWithClass:Article.class
                                                       type:ARMRelationshipTypeHasMany]
    };
}

+ (BOOL)validateBeforeSaving:(id)obj {
    Author *author = obj;

    return author.name.length > 0;
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"uid",
        @"name",
        @"age",
        @"createdAt",
        @"updatedAt"
    ]].description;
}

#pragma mark - property

- (nullable UserSettings *)userSettings {
    return self.relations[@"userSettings"].object;
}

- (NSArray<Article *> *)articles {
    return self.relations[@"articles"].objects;
}

@end
