//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "Article.h"

#import "Author.h"
#import "Tag.h"

@interface ActiveRealmArticle : ARMObject

@property NSString *title;
@property NSString *text;
@property NSNumber <RLMInt> *revision;

@end

RLM_ARRAY_TYPE(ActiveRealmArticle)

@implementation ActiveRealmArticle

@end

@implementation Article

- (instancetype)init {
    if (self = [super init]) {
        _revision = @0;
    }

    return self;
}

+ (NSDictionary<NSString *, ARMRelation *> *)definedRelationships {
    return @{
        @"author": [ARMRelationship relationshipWithClass:Author.class type:ARMRelationshipTypeHasOne],
        @"tags": [ARMRelationship relationshipWithClass:Tag.class type:ARMRelationshipTypeHasMany]
    };
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"uid",
        @"title",
        @"text",
        @"revision",
        @"createdAt",
        @"updatedAt"
    ]].description;
}

#pragma mark - property

- (Author *)author {
    return (Author *) self.relations[@"author"].object;
}

- (NSArray<Tag *> *)tags {
    return (NSArray<Tag *> *) self.relations[@"tags"].objects;
}

@end
