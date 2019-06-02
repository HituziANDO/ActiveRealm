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

@interface Article ()

@property (nonatomic) NSMutableArray<Tag *> *tags;

@end

@implementation Article

- (instancetype)init {
    if (self = [super init]) {
        _tags = [NSMutableArray new];
        _revision = @0;
    }

    return self;
}

+ (NSDictionary<NSString *, ARMRelation *> *)relationship {
    return @{
        @"author": [ARMRelation relationWithClass:Author.class type:ARMRelationTypeHasOne],
        @"tags": [ARMRelation relationWithClass:Tag.class type:ARMRelationTypeHasMany]
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

@end
