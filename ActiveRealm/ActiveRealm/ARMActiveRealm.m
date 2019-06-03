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

#import "ARMActiveRealmManager.h"
#import "ARMClassMapper.h"
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

+ (NSString *)primaryKey {
    return @"uid";
}

+ (NSArray<NSString *> *)ignoredProperties {
    return @[];
}

+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships {
    return @{};
}

- (instancetype)init {
    if (self = [super init]) {
        _uid = [NSUUID UUID].UUIDString;
        _createdAt = [NSDate date];
        _updatedAt = [NSDate date];

        NSMutableDictionary<NSString *, ARMRelation *> *relations = [NSMutableDictionary new];

        for (NSString *prop in self.class.definedRelationships) {
            relations[prop] = [ARMRelation relationWithID:_uid
                                             relationship:self.class.definedRelationships[prop]
                                                belongsTo:self.class];
        }

        _relations = relations;
    }

    return self;
}

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

#pragma mark - public method

- (void)save {
    if ([self.class findByID:self[self.class.primaryKey]]) {
        [self update];
    }
    else {
        [self create];
    }
}

- (void)destroy {
    RLMObject *obj = [self.class object:self.class forPrimaryKey:self[self.class.primaryKey]];

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

+ (NSArray<ARMActiveRealm *> *)all {
    NSMutableArray<ARMActiveRealm *> *models = [NSMutableArray new];

    for (RLMObject *obj in [self allObjects:self.class]) {
        [models addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return models;
}

+ (nullable instancetype)first {
    return self.all.firstObject;
}

+ (nullable instancetype)last {
    return self.all.lastObject;
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

+ (NSArray<ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary {
    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in [self objects:self.class withPredicate:[self predicateWithDictionary:dictionary]]) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];
    }

    return array;
}

+ (NSArray<ARMActiveRealm *> *)whereWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self whereWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

+ (NSArray<ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate {
    RLMResults *results = [self objects:self.class withPredicate:predicate];

    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in results) {
        [array addObject:[self.class createInstanceWithRLMObject:obj]];
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
        relations[prop] = [ARMRelation relationWithID:activeRealm.uid
                                         relationship:self.class.definedRelationships[prop]
                                            belongsTo:self.class];
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
            ![prop isEqualToString:@"relations"]) {

            [properties addObject:prop];
        }
    }

    return properties;
}

- (void)create {
    Class realmClass = [[ARMClassMapper sharedInstance] map:self.class];
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
    RLMObject *obj = [self.class object:self.class forPrimaryKey:self[self.class.primaryKey]];

    if (!obj) {
        return;
    }

    self.updatedAt = [NSDate date];

    [ARMActiveRealmManager.sharedInstance.realm transactionWithBlock:^{
        for (NSString *prop in self.class.propertyNames) {
            if (![prop isEqualToString:self.class.primaryKey] && !self.class.definedRelationships[prop]) {
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
    Class rlmObjClass = [[ARMClassMapper sharedInstance] map:aClass];
    SEL sel = NSSelectorFromString(@"objectInRealm:forPrimaryKey:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    id (*func)(id, SEL, RLMRealm *, id) =(void *) imp;

    return func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.realm, primaryKey);
}

+ (RLMResults *)allObjects:(Class)aClass {
    Class rlmObjClass = [[ARMClassMapper sharedInstance] map:aClass];
    SEL sel = NSSelectorFromString(@"allObjectsInRealm:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    RLMResults *(*func)(id, SEL, RLMRealm *) = (void *) imp;
    RLMResults *results = func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.realm);

    return [results sortedResultsUsingKeyPath:@"createdAt" ascending:YES];
}

+ (RLMResults *)objects:(Class)aClass withPredicate:(NSPredicate *)predicate {
    Class rlmObjClass = [[ARMClassMapper sharedInstance] map:aClass];
    SEL sel = NSSelectorFromString(@"objectsInRealm:withPredicate:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    RLMResults *(*func)(id, SEL, RLMRealm *, NSPredicate *) = (void *) imp;
    RLMResults *results = func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.realm, predicate);

    return [results sortedResultsUsingKeyPath:@"createdAt" ascending:YES];
}

@end
