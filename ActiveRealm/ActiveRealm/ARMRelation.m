//
// Created by Masaki Ando on 2019-06-01.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import "ARMRelation.h"

ARMRelationType const ARMRelationTypeHasOne = @"has_one";
ARMRelationType const ARMRelationTypeHasMany = @"has_many";

@interface ARMRelation ()

@property (nonatomic) Class relationClass;
@property (nonatomic, copy) ARMRelationType type;

@end

@implementation ARMRelation

#pragma mark - Initializer

+ (instancetype)relationWithClass:(Class)aClass type:(ARMRelationType)type {
    ARMRelation *relation = [ARMRelation new];
    relation.relationClass = aClass;
    relation.type = type;

    return relation;
}

#pragma mark - property

- (BOOL)hasOne {
    return [self.type isEqualToString:ARMRelationTypeHasOne];
}

- (BOOL)hasMany {
    return [self.type isEqualToString:ARMRelationTypeHasMany];
}

@end
