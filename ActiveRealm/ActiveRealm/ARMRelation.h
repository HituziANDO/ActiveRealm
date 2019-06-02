//
// Created by Masaki Ando on 2019-06-01.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ARMRelationType;

FOUNDATION_EXTERN ARMRelationType const ARMRelationTypeHasOne;
FOUNDATION_EXTERN ARMRelationType const ARMRelationTypeHasMany;

@interface ARMRelation : NSObject

@property (nonatomic, readonly) Class relationClass;
@property (nonatomic, copy, readonly) ARMRelationType type;
@property (nonatomic, readonly) BOOL hasOne;
@property (nonatomic, readonly) BOOL hasMany;

+ (instancetype)relationWithClass:(Class)aClass type:(ARMRelationType)type;

@end

NS_ASSUME_NONNULL_END
