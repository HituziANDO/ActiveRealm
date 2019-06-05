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

#import <objc/runtime.h>

#import <Realm/Realm.h>

#import "ARMActiveRealm.h"
#import "ARMActiveRealm+Internal.h"

#import "ARMActiveRealmManager.h"
#import "ARMObject.h"
#import "ARMRelation.h"
#import "ARMRelation+Internal.h"
#import "ARMRelationship.h"

static const char *ARMGetPropertyType(objc_property_t property, BOOL *isPrimitiveType) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;

    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            *isPrimitiveType = YES;

            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *) [[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            *isPrimitiveType = NO;

            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            *isPrimitiveType = NO;

            return (const char *) [[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }

    *isPrimitiveType = NO;

    return "";
}

NSDictionary<NSString *, NSString *> *ARMGetProperties(Class aClass) {
    NSMutableDictionary<NSString *, NSString *> *props = [NSMutableDictionary new];

    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(aClass, &outCount);

    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);

        if (propName) {
            BOOL isPrimitiveType;
            const char *propType = ARMGetPropertyType(property, &isPrimitiveType);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            props[propertyName] = propertyType;
        }
    }

    free(properties);

    return props;
}

@interface ARMActiveRealm ()

@property (nonatomic, copy) NSString *uid;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) NSDate *updatedAt;
@property (nonatomic, copy) NSDictionary<NSString *, ARMRelation *> *relations;

@end

@implementation ARMActiveRealm

static NSString *const kActiveRealmPrimaryKeyName = @"uid";

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
        _uid = [NSUUID UUID].UUIDString;
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
    RLMObject *obj = [self.class object:self.class forPrimaryKey:self[kActiveRealmPrimaryKeyName]];

    if (!obj) {
        return;
    }

    RLMRealm *realm = ARMActiveRealmManager.sharedInstance.realm;
    [realm transactionWithBlock:^{
        [realm deleteObject:obj];
    }];

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
    return [self allOrderedBy:@"createdAt" ascending:YES];
}

+ (NSArray<__kindof ARMActiveRealm *> *)allOrderedBy:(NSString *)order ascending:(BOOL)ascending {
    NSMutableArray<ARMActiveRealm *> *models = [NSMutableArray new];

    for (RLMObject *obj in [self allObjects:self.class orderedBy:order ascending:ascending]) {
        [models addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return models;
}

+ (nullable instancetype)first {
    return self.all.firstObject;
}

+ (NSArray<__kindof ARMActiveRealm *> *)firstWithLimit:(NSUInteger)limit {
    NSArray *results = self.all;

    if (results.count <= limit) {
        return results;
    }

    return [results subarrayWithRange:NSMakeRange(0, limit)];
}

+ (NSArray<__kindof ARMActiveRealm *> *)firstOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                 limit:(NSUInteger)limit {

    NSArray *results = [self allOrderedBy:order ascending:ascending];

    if (results.count <= limit) {
        return results;
    }

    return [results subarrayWithRange:NSMakeRange(0, limit)];
}

+ (nullable instancetype)last {
    return self.all.lastObject;
}

+ (NSArray<__kindof ARMActiveRealm *> *)lastWithLimit:(NSUInteger)limit {
    NSArray *results = self.all;

    if (results.count <= limit) {
        return results;
    }

    results = [results.reverseObjectEnumerator.allObjects subarrayWithRange:NSMakeRange(0, limit)];

    return results.reverseObjectEnumerator.allObjects;
}

+ (NSArray<__kindof ARMActiveRealm *> *)lastOrderedBy:(NSString *)order
                                            ascending:(BOOL)ascending
                                                limit:(NSUInteger)limit {

    NSArray *results = [self allOrderedBy:order ascending:ascending];

    if (results.count <= limit) {
        return results;
    }

    results = [results.reverseObjectEnumerator.allObjects subarrayWithRange:NSMakeRange(0, limit)];

    return results.reverseObjectEnumerator.allObjects;
}

+ (nullable instancetype)findByID:(NSString *)uid {
    id rlmObj = [self object:self.class forPrimaryKey:uid];

    if (rlmObj) {
        return [self createInstanceWithRLMObject:rlmObj];
    }

    return nil;
}

+ (nullable instancetype)find:(NSDictionary<NSString *, id> *)dictionary {
    id rlmObj = [self objects:self.class withPredicate:[self predicateWithDictionary:dictionary]].firstObject;

    if (rlmObj) {
        return [self createInstanceWithRLMObject:rlmObj];
    }

    return nil;
}

+ (nullable instancetype)findWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self findWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (nullable instancetype)findWithPredicate:(NSPredicate *)predicate {
    id rlmObj = [self objects:self.class withPredicate:predicate].firstObject;

    if (rlmObj) {
        return [self createInstanceWithRLMObject:rlmObj];
    }

    return nil;
}

+ (nullable instancetype)findLast:(NSDictionary<NSString *, id> *)dictionary {
    id rlmObj = [self objects:self.class withPredicate:[self predicateWithDictionary:dictionary]].lastObject;

    if (rlmObj) {
        return [self createInstanceWithRLMObject:rlmObj];
    }

    return nil;
}

+ (nullable instancetype)findLastWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self findLastWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (nullable instancetype)findLastWithPredicate:(NSPredicate *)predicate {
    id rlmObj = [self objects:self.class withPredicate:predicate].lastObject;

    if (rlmObj) {
        return [self createInstanceWithRLMObject:rlmObj];
    }

    return nil;
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
    RLMResults *results = [self objects:self.class withPredicate:[self predicateWithDictionary:dictionary]];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return array;
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self whereWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate {
    RLMResults *results = [self objects:self.class withPredicate:predicate];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return array;
}

+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                                    orderedBy:(NSString *)order
                                    ascending:(BOOL)ascending {

    RLMResults *results = [self objects:self.class
                          withPredicate:[self predicateWithDictionary:dictionary]
                              orderedBy:order
                              ascending:ascending];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return array;
}

+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                                    orderedBy:(NSString *)order
                                    ascending:(BOOL)ascending
                                        limit:(NSUInteger)limit {

    RLMResults *results = [self objects:self.class
                          withPredicate:[self predicateWithDictionary:dictionary]
                              orderedBy:order
                              ascending:ascending];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];

        if (array.count == limit) {
            return array;
        }
    }

    return array;
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

    RLMResults *results = [self objects:self.class withPredicate:predicate orderedBy:order ascending:ascending];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return array;
}

+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                                 orderedBy:(NSString *)order
                                                 ascending:(BOOL)ascending
                                                     limit:(NSUInteger)limit {

    RLMResults *results = [self objects:self.class withPredicate:predicate orderedBy:order ascending:ascending];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];

        if (array.count == limit) {
            return array;
        }
    }

    return array;
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

#pragma mark - private method

+ (instancetype)createInstanceWithRLMObject:(RLMObject *)obj {
    ARMActiveRealm *activeRealm = (ARMActiveRealm *) [self.class new];

    for (NSString *prop in self.class.propertyNames) {
        activeRealm[prop] = obj[prop];
    }

    NSMutableDictionary<NSString *, ARMRelation *> *relations = [NSMutableDictionary new];

    for (NSString *prop in self.class.definedRelationships) {
        relations[prop] = [ARMRelation relationWithObject:activeRealm
                                             relationship:self.class.definedRelationships[prop]];
    }

    activeRealm.relations = relations;

    return activeRealm;
}

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

- (void)create {
    Class realmClass = [[ARMActiveRealmManager sharedInstance] map:self.class];
    id obj = [realmClass new];

    for (NSString *prop in self.class.propertyNames) {
        if (!self.class.definedRelationships[prop]) {
            obj[prop] = self[prop];
        }
    }

    RLMRealm *realm = ARMActiveRealmManager.sharedInstance.realm;
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

    [ARMActiveRealmManager.sharedInstance.realm transactionWithBlock:^{
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

    return func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.realm, primaryKey);
}

+ (RLMResults *)allObjects:(Class)aClass orderedBy:(NSString *)order ascending:(BOOL)ascending {
    Class rlmObjClass = [[ARMActiveRealmManager sharedInstance] map:aClass];
    SEL sel = NSSelectorFromString(@"allObjectsInRealm:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    RLMResults *(*func)(id, SEL, RLMRealm *) = (void *) imp;
    RLMResults *results = func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.realm);

    return [results sortedResultsUsingKeyPath:order ascending:ascending];
}

+ (RLMResults *)objects:(Class)aClass withPredicate:(NSPredicate *)predicate {
    return [self objects:aClass withPredicate:predicate orderedBy:@"createdAt" ascending:YES];
}

+ (RLMResults *)objects:(Class)aClass
          withPredicate:(NSPredicate *)predicate
              orderedBy:(NSString *)order
              ascending:(BOOL)ascending {

    Class rlmObjClass = [[ARMActiveRealmManager sharedInstance] map:aClass];
    SEL sel = NSSelectorFromString(@"objectsInRealm:withPredicate:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    RLMResults *(*func)(id, SEL, RLMRealm *, NSPredicate *) = (void *) imp;
    RLMResults *results = func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.realm, predicate);

    return [results sortedResultsUsingKeyPath:order ascending:ascending];
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

- (NSDictionary *)asDictionaryWithBlock:(id (^)(NSString *prop, id value))block {
    return [self asDictionaryExceptingProperties:@[] block:block];
}

- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties {
    return [self asDictionaryExceptingProperties:exceptedProperties block:^id(NSString *prop, id value) {
        return value;
    }];
}

- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                            block:(id (^)(NSString *prop, id value))block {

    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    for (NSString *prop in self.class.propertyNames) {
        if (![exceptedProperties containsObject:prop]) {
            dictionary[prop] = block(prop, self[prop]);
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
                                            block:(id (^)(NSString *prop, id value))block {

    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    for (NSString *prop in includedProperties) {
        dictionary[prop] = block(prop, self[prop]);
    }

    return dictionary;
}

- (NSData *)asJSON {
    return [self asJSONExceptingProperties:@[]];
}

- (NSData *)asJSONWithBlock:(id (^)(NSString *prop, id value))block {
    return [self asJSONExceptingProperties:@[] block:block];
}

- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties {
    return [self asJSONExceptingProperties:exceptedProperties block:^id(NSString *prop, id value) {
        return value;
    }];
}

- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                block:(id (^)(NSString *prop, id value))block {

    NSDictionary *dictionary1 = [self asDictionaryExceptingProperties:exceptedProperties block:block];
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
                                block:(id (^)(NSString *prop, id value))block {

    NSDictionary *dictionary1 = [self asDictionaryIncludingProperties:includedProperties block:block];
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

- (NSString *)asJSONString {
    return [[NSString alloc] initWithData:[self asJSON] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringWithBlock:(id (^)(NSString *prop, id value))block {
    return [[NSString alloc] initWithData:[self asJSONWithBlock:block] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties {
    return [[NSString alloc] initWithData:[self asJSONExceptingProperties:exceptedProperties]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                        block:(id (^)(NSString *prop, id value))block {

    return [[NSString alloc] initWithData:[self asJSONExceptingProperties:exceptedProperties
                                                                    block:block] encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties {
    return [[NSString alloc] initWithData:[self asJSONIncludingProperties:includedProperties]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties
                                        block:(id (^)(NSString *prop, id value))block {

    return [[NSString alloc] initWithData:[self asJSONIncludingProperties:includedProperties block:block]
                                 encoding:NSUTF8StringEncoding];
}

@end
