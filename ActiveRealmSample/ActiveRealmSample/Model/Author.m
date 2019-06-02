//
// Created by Masaki Ando on 2019-06-02.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "Author.h"

@interface ActiveRealmAuthor : ARMObject

@property NSString *articleID;
@property NSString *name;
@property NSNumber <RLMInt> *age;

@end

RLM_ARRAY_TYPE(ActiveRealmAuthor)

@implementation ActiveRealmAuthor

@end

@implementation Author

+ (NSArray<NSString *> *)ignoredProperties {
    return @[ @"country" ];
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"uid",
        @"articleID",
        @"name",
        @"age",
        @"createdAt",
        @"updatedAt"
    ]].description;
}

@end
