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

#import <Realm/Realm.h>
#import <ActiveRealm/ActiveRealm.h>

#import "ARMActiveRealm.h"
#import "ARMActiveRealm+Internal.h"

#import "ARMActiveRealmManager.h"
#import "ARMCollection.h"
#import "ARMObject.h"
#import "ARMProperty.h"
#import "ARMQuery.h"
#import "ARMRelation.h"
#import "ARMRelation+Internal.h"
#import "ARMRelationship.h"

@interface ARMActiveRealm ()

@property (nonatomic, copy) NSString *uid;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) NSDate *updatedAt;
@property (nonatomic, copy) NSDictionary<NSString *, ARMRelation *> *relations;

@end

@interface ARMCollection ()

@property (nonatomic) RLMResults *results;

@end

@implementation ARMActiveRealm

static NSString *const kActiveRealmPrimaryKeyName = @"uid";

+ (NSArray<NSString *> *)propertyNames {
    NSMutableArray *properties = [NSMutableArray new];

    for (NSString *prop in self.properties.allKeys) {
        if (![self.ignoredProperties containsObject:prop] &&
            !self.definedRelationships[prop] &&
            ![prop isEqualToString:@"relations"] &&
            ![prop isEqualToString:@"description"] &&
            ![prop isEqualToString:@"debugDescription"] &&
            ![prop isEqualToString:@"hash"]) {

            [properties addObject:prop];
        }
    }

    return properties;
}

+ (ARMQuery *)query {
    return [[ARMQuery alloc] initWithClass:self.class];
}

+ (NSArray<NSString *> *)ignoredProperties {
    return @[];
}

+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships {
    return @{};
}

+ (BOOL)validateBeforeSaving:(id)obj {
    return YES;
}

- (instancetype)init {
    if (self = [super init]) {
        _uid = [NSUUID UUID].UUIDString.uppercaseString;
        _createdAt = [NSDate date];
        _updatedAt = [NSDate date];

        NSMutableDictionary<NSString *, ARMRelation *> *relations = [NSMutableDictionary new];

        for (NSString *prop in self.class.definedRelationships) {
            relations[prop] = [ARMRelation relationWithObject:self relationship:self.class.definedRelationships[prop]];
        }

        _relations = relations;
    }

    return self;
}

#pragma mark - public method

- (BOOL)save {
    if (![self.class validateBeforeSaving:self]) {
        return NO;
    }

    if ([self.class findByID:self[kActiveRealmPrimaryKeyName]]) {
        [self update];
    }
    else {
        [self create];
    }

    return YES;
}

- (void)destroy {
    [self destroyWithCascade:YES];
}

- (void)destroyWithCascade:(BOOL)cascade {
    RLMObject *obj = [self.class object:self.class forPrimaryKey:self[kActiveRealmPrimaryKeyName]];

    if (!obj) {
        return;
    }

    RLMRealm *realm = ARMActiveRealmManager.sharedInstance.defaultRealm;
    [realm transactionWithBlock:^{
        [realm deleteObject:obj];
    }];

    if (!cascade) {
        return;
    }

    for (NSString *prop in self.relations) {
        if (self.relations[prop].hasOne) {
            [self.relations[prop].object destroy];
        }
        else if (self.relations[prop].hasMany) {
            for (ARMActiveRealm *activeRealm in self.relations[prop].objects) {
                [activeRealm destroy];
            }
        }
    }
}

+ (NSArray<__kindof ARMActiveRealm *> *)all {
    return [self.query.all order:@"createdAt" ascending:YES].toArray;
}

+ (NSArray<__kindof ARMActiveRealm *> *)allOrderedBy:(NSString *)order ascending:(BOOL)ascending {
    return [self.query.all order:order ascending:ascending].toArray;
}

+ (nullable instancetype)first {
    return self.query.all.first;
}

+ (NSArray<__kindof ARMActiveRealm *> *)firstWithLimit:(NSUInteger)limit {
    return [self.query.all firstWithLimit:limit];
}

+ (NSArray<__kindof ARMActiveRealm *> *)firstOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                 limit:(NSUInteger)limit {

    return [[self.query.all order:order ascending:ascending] firstWithLimit:limit];
}

+ (nullable instancetype)last {
    return self.query.all.last;
}

+ (NSArray<__kindof ARMActiveRealm *> *)lastWithLimit:(NSUInteger)limit {
    return [self.query.all lastWithLimit:limit];
}

+ (NSArray<__kindof ARMActiveRealm *> *)lastOrderedBy:(NSString *)order
                                            ascending:(BOOL)ascending
                                                limit:(NSUInteger)limit {

    return [[self.query.all order:order ascending:ascending] lastWithLimit:limit];
}

+ (nullable instancetype)findByID:(NSString *)uid {
    return [self.query whereWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", uid]].first;
}

+ (nullable instancetype)find:(NSDictionary<NSString *, id> *)dictionary {
    return [self.query where:dictionary].first;
}

+ (nullable instancetype)findWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self findWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (nullable instancetype)findWithPredicate:(NSPredicate *)predicate {
    return [self.query whereWithPredicate:predicate].first;
}

+ (nullable instancetype)findLast:(NSDictionary<NSString *, id> *)dictionary {
    return [self.query where:dictionary].last;
}

+ (nullable instancetype)findLastWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self findLastWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (nullable instancetype)findLastWithPredicate:(NSPredicate *)predicate {
    return [self.query whereWithPredicate:predicate].last;
}

+ (instancetype)findOrInitialize:(NSDictionary<NSString *, id> *)dictionary {
    id activeRealm = [self find:dictionary];

    if (activeRealm) {
        return activeRealm;
    }

    activeRealm = [self.class new];

    for (NSString *prop in self.class.propertyNames) {
        if (!self.definedRelationships[prop] &&
            ![prop isEqualToString:@"uid"] &&
            ![prop isEqualToString:@"createdAt"] &&
            ![prop isEqualToString:@"updatedAt"]) {

            activeRealm[prop] = dictionary[prop];
        }
    }

    return activeRealm;
}

+ (instancetype)findOrCreate:(NSDictionary<NSString *, id> *)dictionary {
    id activeRealm = [self find:dictionary];

    if (activeRealm) {
        return activeRealm;
    }

    activeRealm = [self.class new];

    for (NSString *prop in self.class.propertyNames) {
        if (!self.definedRelationships[prop] &&
            ![prop isEqualToString:@"uid"] &&
            ![prop isEqualToString:@"createdAt"] &&
            ![prop isEqualToString:@"updatedAt"]) {

            activeRealm[prop] = dictionary[prop];
        }
    }

    [((ARMActiveRealm *) activeRealm) save];

    return activeRealm;
}

+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary {
    return [self.query where:dictionary].toArray;
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self whereWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate {
    return [self.query whereWithPredicate:predicate].toArray;
}

+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                                    orderedBy:(NSString *)order
                                    ascending:(BOOL)ascending {

    return [[self.query where:dictionary] order:order ascending:ascending].toArray;
}

+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                                    orderedBy:(NSString *)order
                                    ascending:(BOOL)ascending
                                        limit:(NSUInteger)limit {

    return [[[self.query where:dictionary] order:order ascending:ascending] firstWithLimit:limit];
}


+ (NSArray<__kindof ARMActiveRealm *> *)whereOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                format:(NSString *)format, ... {

    va_list args;
    va_start(args, format);
    va_end(args);

    return [self whereWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]
                          orderedBy:order
                          ascending:ascending];
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                 limit:(NSUInteger)limit
                                                format:(NSString *)format, ... {

    va_list args;
    va_start(args, format);
    va_end(args);

    return [self whereWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]
                          orderedBy:order
                          ascending:ascending
                              limit:limit];
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                                 orderedBy:(NSString *)order
                                                 ascending:(BOOL)ascending {

    return [[self.query whereWithPredicate:predicate] order:order ascending:ascending].toArray;
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                                 orderedBy:(NSString *)order
                                                 ascending:(BOOL)ascending
                                                     limit:(NSUInteger)limit {

    return [[[self.query whereWithPredicate:predicate] order:order ascending:ascending] firstWithLimit:limit];
}

+ (void)destroy:(NSDictionary<NSString *, id> *)dictionary {
    [[self where:dictionary] enumerateObjectsUsingBlock:^(ARMActiveRealm *obj, NSUInteger idx, BOOL *stop) {
        [obj destroy];
    }];
}

+ (void)destroyWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    [self destroyWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (void)destroyWithPredicate:(NSPredicate *)predicate {
    [[self whereWithPredicate:predicate] enumerateObjectsUsingBlock:^(ARMActiveRealm *obj, NSUInteger idx, BOOL *stop) {
        [obj destroy];
    }];
}

+ (void)destroy:(NSDictionary<NSString *, id> *)dictionary cascade:(BOOL)cascade {
    [[self where:dictionary] enumerateObjectsUsingBlock:^(ARMActiveRealm *obj, NSUInteger idx, BOOL *stop) {
        [obj destroyWithCascade:cascade];
    }];
}

+ (void)destroyWithCascade:(BOOL)cascade format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    [self destroyWithPredicate:[NSPredicate predicateWithFormat:format arguments:args] cascade:cascade];
}

+ (void)destroyWithPredicate:(NSPredicate *)predicate cascade:(BOOL)cascade {
    [[self whereWithPredicate:predicate] enumerateObjectsUsingBlock:^(ARMActiveRealm *obj, NSUInteger idx, BOOL *stop) {
        [obj destroyWithCascade:cascade];
    }];
}

+ (void)destroyAll {
    [self destroyAllWithCascade:YES];
}

+ (void)destroyAllWithCascade:(BOOL)cascade {
    [self.all enumerateObjectsUsingBlock:^(ARMActiveRealm *obj, NSUInteger idx, BOOL *stop) {
        [obj destroyWithCascade:cascade];
    }];
}

#pragma mark - private method

+ (NSDictionary<NSString *, NSString *> *)properties {
    NSMutableDictionary *props = self.superclass != NSObject.class ?
        ARMGetProperties(self.superclass).mutableCopy : [NSMutableDictionary new];
    NSDictionary *selfProps = ARMGetProperties(self.class);

    // Merge properties of superclass and self class.
    for (NSString *key in selfProps) {
        props[key] = selfProps[key];
    }

    return props;
}

- (void)create {
    Class realmClass = [[ARMActiveRealmManager sharedInstance] map:self.class];
    id obj = [realmClass new];

    for (NSString *prop in self.class.propertyNames) {
        if (!self.class.definedRelationships[prop]) {
            obj[prop] = self[prop];
        }
    }

    RLMRealm *realm = ARMActiveRealmManager.sharedInstance.defaultRealm;
    [realm transactionWithBlock:^{
        [realm addObject:obj];
    }];
}

- (void)update {
    RLMObject *obj = [self.class object:self.class forPrimaryKey:self[kActiveRealmPrimaryKeyName]];

    if (!obj) {
        return;
    }

    self.updatedAt = [NSDate date];

    [ARMActiveRealmManager.sharedInstance.defaultRealm transactionWithBlock:^{
        for (NSString *prop in self.class.propertyNames) {
            if (![prop isEqualToString:kActiveRealmPrimaryKeyName] && !self.class.definedRelationships[prop]) {
                obj[prop] = self[prop];
            }
        }
    }];
}

+ (NSPredicate *)predicateWithDictionary:(NSDictionary<NSString *, id> *)dictionary {
    NSMutableArray *formats = [NSMutableArray new];
    NSMutableArray *arguments = [NSMutableArray new];

    for (NSString *prop in dictionary.allKeys) {
        [formats addObject:[prop stringByAppendingString:@"=%@"]];
        [arguments addObject:dictionary[prop]];
    }

    NSString *format = [formats componentsJoinedByString:@" AND "];

    return [NSPredicate predicateWithFormat:format argumentArray:arguments];
}

+ (nullable RLMObject *)object:(Class)aClass forPrimaryKey:(id)primaryKey {
    Class rlmObjClass = [[ARMActiveRealmManager sharedInstance] map:aClass];
    SEL sel = NSSelectorFromString(@"objectInRealm:forPrimaryKey:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    id (*func)(id, SEL, RLMRealm *, id) =(void *) imp;

    return func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.defaultRealm, primaryKey);
}

@end

@implementation ARMActiveRealm (Internal)

- (id)objectForKeyedSubscript:(NSString *)prop {
    SEL sel = NSSelectorFromString(prop);
    IMP imp = [self methodForSelector:sel];
    id (*func)(id, SEL) = (void *) imp;

    return func(self, sel);
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)prop {
    NSString *setter = [NSString stringWithFormat:@"set%@%@:",
                                                  [prop substringToIndex:1].uppercaseString,
                                                  [prop substringFromIndex:1]];
    SEL sel = NSSelectorFromString(setter);
    IMP imp = [self methodForSelector:sel];
    void (*func)(id, SEL, id) = (void *) imp;
    func(self, sel, obj);
}

@end

@implementation ARMActiveRealm (Converting)

- (NSDictionary *)asDictionary {
    return [self asDictionaryExceptingProperties:@[]];
}

- (NSDictionary *)asDictionaryWithBlock:(id (^)(NSString *prop, id value))converter {
    return [self asDictionaryExceptingProperties:@[] block:converter];
}

- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties {
    return [self asDictionaryExceptingProperties:exceptedProperties block:^id(NSString *prop, id value) {
        return value;
    }];
}

- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                            block:(id (^)(NSString *prop, id value))converter {

    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    for (NSString *prop in self.class.propertyNames) {
        if (![exceptedProperties containsObject:prop]) {
            dictionary[prop] = converter(prop, self[prop]);
        }
    }

    return dictionary;
}

- (NSDictionary *)asDictionaryIncludingProperties:(NSArray<NSString *> *)includedProperties {
    return [self asDictionaryIncludingProperties:includedProperties block:^id(NSString *prop, id value) {
        return value;
    }];
}

- (NSDictionary *)asDictionaryIncludingProperties:(NSArray<NSString *> *)includedProperties
                                            block:(id (^)(NSString *prop, id value))converter {

    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    for (NSString *prop in includedProperties) {
        dictionary[prop] = converter(prop, self[prop]);
    }

    return dictionary;
}

- (NSDictionary *)asDictionaryAddingPropertiesWithTarget:(id)target
                                                 methods:(NSDictionary<NSString *, NSString *> *)methods {

    NSMutableDictionary *dictionary = [self asDictionary].mutableCopy;

    for (NSString *prop in methods.allKeys) {
        SEL selector = NSSelectorFromString(methods[prop]);

        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dictionary[prop] = [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }

    return dictionary;
}

- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                       addingPropertiesWithTarget:(id)target
                                          methods:(NSDictionary<NSString *, NSString *> *)methods {

    NSMutableDictionary *dictionary = [self asDictionaryExceptingProperties:exceptedProperties].mutableCopy;

    for (NSString *prop in methods.allKeys) {
        SEL selector = NSSelectorFromString(methods[prop]);

        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dictionary[prop] = [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }

    return dictionary;
}

- (NSDictionary *)asDictionaryIncludingProperties:(NSArray<NSString *> *)includedProperties
                       addingPropertiesWithTarget:(id)target
                                          methods:(NSDictionary<NSString *, NSString *> *)methods {

    NSMutableDictionary *dictionary = [self asDictionaryIncludingProperties:includedProperties].mutableCopy;

    for (NSString *prop in methods.allKeys) {
        SEL selector = NSSelectorFromString(methods[prop]);

        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dictionary[prop] = [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }

    return dictionary;
}

- (NSData *)asJSON {
    return [self asJSONExceptingProperties:@[]];
}

- (NSData *)asJSONWithBlock:(id (^)(NSString *prop, id value))converter {
    return [self asJSONExceptingProperties:@[] block:converter];
}

- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties {
    return [self asJSONExceptingProperties:exceptedProperties block:^id(NSString *prop, id value) {
        return value;
    }];
}

- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                block:(id (^)(NSString *prop, id value))converter {

    NSDictionary *dictionary1 = [self asDictionaryExceptingProperties:exceptedProperties block:converter];
    NSMutableDictionary *dictionary2 = [NSMutableDictionary new];

    for (NSString *prop in dictionary1) {
        if ([dictionary1[prop] isKindOfClass:[NSDate class]]) {
            dictionary2[prop] = [dictionary1[prop] description];
        }
        else {
            dictionary2[prop] = dictionary1[prop];
        }
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary2 options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)asJSONIncludingProperties:(NSArray<NSString *> *)includedProperties {
    return [self asJSONIncludingProperties:includedProperties block:^id(NSString *prop, id value) {
        return value;
    }];
}

- (NSData *)asJSONIncludingProperties:(NSArray<NSString *> *)includedProperties
                                block:(id (^)(NSString *prop, id value))converter {

    NSDictionary *dictionary1 = [self asDictionaryIncludingProperties:includedProperties block:converter];
    NSMutableDictionary *dictionary2 = [NSMutableDictionary new];

    for (NSString *prop in dictionary1) {
        if ([dictionary1[prop] isKindOfClass:[NSDate class]]) {
            dictionary2[prop] = [dictionary1[prop] description];
        }
        else {
            dictionary2[prop] = dictionary1[prop];
        }
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary2 options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)asJSONAddingPropertiesWithTarget:(id)target
                                     methods:(NSDictionary<NSString *, NSString *> *)methods {

    NSMutableDictionary *dictionary1 = [self asDictionary].mutableCopy;

    for (NSString *prop in methods.allKeys) {
        SEL selector = NSSelectorFromString(methods[prop]);

        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dictionary1[prop] = [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }

    NSMutableDictionary *dictionary2 = [NSMutableDictionary new];

    for (NSString *prop in dictionary1) {
        if ([dictionary1[prop] isKindOfClass:[NSDate class]]) {
            dictionary2[prop] = [dictionary1[prop] description];
        }
        else {
            dictionary2[prop] = dictionary1[prop];
        }
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary2 options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties
           addingPropertiesWithTarget:(id)target
                              methods:(NSDictionary<NSString *, NSString *> *)methods {

    NSMutableDictionary *dictionary = [self asDictionaryExceptingProperties:exceptedProperties].mutableCopy;

    for (NSString *prop in methods.allKeys) {
        SEL selector = NSSelectorFromString(methods[prop]);

        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dictionary[prop] = [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)asJSONIncludingProperties:(NSArray<NSString *> *)includedProperties
           addingPropertiesWithTarget:(id)target
                              methods:(NSDictionary<NSString *, NSString *> *)methods {

    NSMutableDictionary *dictionary = [self asDictionaryIncludingProperties:includedProperties].mutableCopy;

    for (NSString *prop in methods.allKeys) {
        SEL selector = NSSelectorFromString(methods[prop]);

        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dictionary[prop] = [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSString *)asJSONString {
    return [[NSString alloc] initWithData:[self asJSON] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringWithBlock:(id (^)(NSString *prop, id value))converter {
    return [[NSString alloc] initWithData:[self asJSONWithBlock:converter] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties {
    return [[NSString alloc] initWithData:[self asJSONExceptingProperties:exceptedProperties]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                        block:(id (^)(NSString *prop, id value))converter {

    return [[NSString alloc] initWithData:[self asJSONExceptingProperties:exceptedProperties
                                                                    block:converter] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties {
    return [[NSString alloc] initWithData:[self asJSONIncludingProperties:includedProperties]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties
                                        block:(id (^)(NSString *prop, id value))converter {

    return [[NSString alloc] initWithData:[self asJSONIncludingProperties:includedProperties block:converter]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringAddingPropertiesWithTarget:(id)target
                                             methods:(NSDictionary<NSString *, NSString *> *)methods {

    return [[NSString alloc] initWithData:[self asJSONAddingPropertiesWithTarget:target methods:methods]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                   addingPropertiesWithTarget:(id)target
                                      methods:(NSDictionary<NSString *, NSString *> *)methods {

    return [[NSString alloc] initWithData:[self asJSONExceptingProperties:exceptedProperties
                                               addingPropertiesWithTarget:target
                                                                  methods:methods] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties
                   addingPropertiesWithTarget:(id)target
                                      methods:(NSDictionary<NSString *, NSString *> *)methods {

    return [[NSString alloc] initWithData:[self asJSONIncludingProperties:includedProperties
                                               addingPropertiesWithTarget:target
                                                                  methods:methods] encoding:NSUTF8StringEncoding];
}

@end

@implementation ARMActiveRealm (Counting)

+ (NSUInteger)count {
    return self.query.all.count;
}

+ (NSUInteger)countWhere:(NSDictionary<NSString *, id> *)dictionary {
    return [self countWithPredicate:[self predicateWithDictionary:dictionary]];
}

+ (NSUInteger)countWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self countWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate {
    return [self.query whereWithPredicate:predicate].count;
}

@end
