//
// ActiveRealm
//
// MIT License
//
// Copyright (c) 2019-present Hituzi Ando
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ARMRelation;
@class ARMRelationship;

@interface ARMActiveRealm : NSObject

@property (nonatomic, copy, readonly) NSString *uid;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, ARMRelation *> *relations;

- (void)save;
- (void)destroy;

+ (NSArray<NSString *> *)ignoredProperties;
+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships;
+ (NSArray<ARMActiveRealm *> *)all;
+ (NSArray<ARMActiveRealm *> *)allOrderedBy:(NSString *)order ascending:(BOOL)ascending;
+ (nullable instancetype)first;
+ (NSArray<ARMActiveRealm *> *)firstWithLimit:(NSUInteger)limit;
+ (NSArray<ARMActiveRealm *> *)firstOrderedBy:(NSString *)order ascending:(BOOL)ascending limit:(NSUInteger)limit;
+ (nullable instancetype)last;
+ (NSArray<ARMActiveRealm *> *)lastWithLimit:(NSUInteger)limit;
+ (NSArray<ARMActiveRealm *> *)lastOrderedBy:(NSString *)order ascending:(BOOL)ascending limit:(NSUInteger)limit;
+ (nullable instancetype)findByID:(NSString *)uid;
+ (nullable instancetype)find:(NSDictionary<NSString *, id> *)dictionary;
+ (nullable instancetype)findWithFormat:(NSString *)format, ...;
+ (nullable instancetype)findWithPredicate:(NSPredicate *)predicate;
+ (nullable instancetype)findLast:(NSDictionary<NSString *, id> *)dictionary;
+ (nullable instancetype)findLastWithFormat:(NSString *)format, ...;
+ (nullable instancetype)findLastWithPredicate:(NSPredicate *)predicate;
+ (instancetype)findOrInitialize:(NSDictionary<NSString *, id> *)dictionary;
+ (instancetype)findOrCreate:(NSDictionary<NSString *, id> *)dictionary;
+ (NSArray<ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary;
+ (NSArray<ARMActiveRealm *> *)whereWithFormat:(NSString *)format, ...;
+ (NSArray<ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate;
+ (NSArray<ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                           orderedBy:(NSString *)order
                           ascending:(BOOL)ascending;
+ (NSArray<ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                           orderedBy:(NSString *)order
                           ascending:(BOOL)ascending
                               limit:(NSUInteger)limit;
+ (NSArray<ARMActiveRealm *> *)whereOrderedBy:(NSString *)order
                                    ascending:(BOOL)ascending
                                       format:(NSString *)format, ...;
+ (NSArray<ARMActiveRealm *> *)whereOrderedBy:(NSString *)order
                                    ascending:(BOOL)ascending
                                        limit:(NSUInteger)limit
                                       format:(NSString *)format, ...;
+ (NSArray<ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                        orderedBy:(NSString *)order
                                        ascending:(BOOL)ascending;
+ (NSArray<ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                        orderedBy:(NSString *)order
                                        ascending:(BOOL)ascending
                                            limit:(NSUInteger)limit;
+ (void)destroy:(NSDictionary<NSString *, id> *)dictionary;
+ (void)destroyWithFormat:(NSString *)format, ...;
+ (void)destroyWithPredicate:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END
