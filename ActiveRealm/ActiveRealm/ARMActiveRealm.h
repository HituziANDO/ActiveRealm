//
// Created by Masaki Ando on 2019-05-30.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ARMRelation;

@interface ARMActiveRealm : NSObject

@property (nonatomic, readonly) NSString *uid;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

- (void)save;
- (void)destroy;

+ (NSArray<NSString *> *)ignoredProperties;
+ (NSDictionary<NSString *, ARMRelation *> *)relationship;
+ (NSArray<ARMActiveRealm *> *)all;
+ (nullable instancetype)first;
+ (nullable instancetype)last;
+ (nullable instancetype)findByID:(NSString *)uid;
+ (nullable instancetype)find:(NSDictionary<NSString *, id> *)dictionary;
+ (nullable instancetype)findWithFormat:(NSString *)format, ...;
+ (nullable instancetype)findLast:(NSDictionary<NSString *, id> *)dictionary;
+ (nullable instancetype)findLastWithFormat:(NSString *)format, ...;
+ (instancetype)findOrInitialize:(NSDictionary<NSString *, id> *)dictionary;
+ (instancetype)findOrCreate:(NSDictionary<NSString *, id> *)dictionary;
+ (NSArray<ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary;;
+ (NSArray<ARMActiveRealm *> *)whereWithFormat:(NSString *)format, ...;
+ (NSArray<ARMActiveRealm *> *)whereWithFormat:(NSString *)format arguments:(va_list)arguments;
+ (void)destroy:(NSDictionary<NSString *, id> *)dictionary;
+ (void)destroyWithFormat:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
