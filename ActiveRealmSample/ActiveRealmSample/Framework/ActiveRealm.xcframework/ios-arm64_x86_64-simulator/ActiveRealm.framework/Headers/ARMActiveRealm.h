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

@class ARMCollection;
@class ARMQuery;
@class ARMRelation;
@class ARMRelationship;

typedef NS_OPTIONS(NSInteger, ARMSavingOption) {
    /**
     * No option.
     */
    ARMSavingOptionNone,
    /**
     * The `updatedAt` property is not automatically updated.
     */
    ARMSavingOptionNotAutomaticallyUpdateTimestamp,
};

@interface ARMActiveRealm : NSObject
/**
 * The property names of the model.
 */
@property (class, nonatomic, copy, readonly) NSArray<NSString *> *propertyNames;
/**
 * The query object.
 */
@property (class, nonatomic, readonly) ARMQuery *query;
/**
 * The primary key.
 */
@property (nonatomic, copy, readonly) NSString *uid;
/**
 * The creation date.
 */
@property (nonatomic, readonly) NSDate *createdAt;
/**
 * The modification date.
 */
@property (nonatomic, readonly) NSDate *updatedAt;
/**
 * You can access related object(s) through `relations` property.
 * The `relations` is the dictionary,
 * so you specify the key that is same key of the dictionary `definedRelationships` method returns.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, ARMRelation *> *relations;

/**
 * The `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
 *
 * @return YES if the validation is successful, otherwise NO.
 */
- (BOOL)save;
/**
 * The `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
 *
 * @param options Options.
 * @return YES if the validation is successful, otherwise NO.
 */
- (BOOL)saveWithOptions:(ARMSavingOption)options NS_SWIFT_NAME(save(options:));
/**
 * The `destroy` method performs cascade delete by default.
 * In other words, related data are also deleted collectively.
 */
- (void)destroy;
/**
 * The `destroy` method performs cascade delete by default.
 * Use this if not cascade deleting. Specify NO to cascade argument.
 *
 * @param cascade NO if not cascade deleting.
 */
- (void)destroyWithCascade:(BOOL)cascade NS_SWIFT_NAME(destroy(cascade:));

/**
 * ActiveRealm saves all properties in your model to the DB by default.
 * If you don’t want to save a property, override this method.
 *
 * @return Ignored property names.
 */
+ (NSArray<NSString *> *)ignoredProperties;
/**
 * You can make a relationship between two ActiveRealm subclasses by override this method.
 * By making a relationship, cascade delete is possible.
 * Use ARMRelationship class and ARMInverseRelationship class for making the relationship.
 *
 * @return Relationships definition.
 */
+ (NSDictionary<NSString *, ARMRelationship *> *)definedRelationships;
/**
 * ActiveRealm can validate data before saving a model. By default, the validation is always successful.
 * If you want to validate data, override this method. When the method returns false, the data isn't saved.
 *
 * @param obj A target.
 * @return YES if the validation is successful, otherwise NO.
 */
+ (BOOL)validateBeforeSaving:(id)obj NS_SWIFT_NAME(validateBeforeSaving(_:));
/**
 * Select all objects.
 *
 * @return All objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)all;
/**
 * Select all objects ordered by specified property.
 *
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @return All sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)allOrderedBy:(NSString *)order
                                           ascending:(BOOL)ascending NS_SWIFT_NAME(all(orderedBy:ascending:)) DEPRECATED_ATTRIBUTE;
/**
 * Select first created object.
 *
 * @return An object.
 */
+ (nullable instancetype)first;
/**
 * Select specified number of objects from the head.
 *
 * @param limit Maximum number of acquisitions.
 * @return Objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)firstWithLimit:(NSUInteger)limit NS_SWIFT_NAME(first(limit:));
/**
 * Select specified number of objects ordered by specified property from the head.
 *
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @param limit Maximum number of acquisitions.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)firstOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                 limit:(NSUInteger)limit NS_SWIFT_NAME(first(orderedBy:ascending:limit:)) DEPRECATED_ATTRIBUTE;
/**
 * Select last created object.
 *
 * @return An object.
 */
+ (nullable instancetype)last;
/**
 * Select specified number of objects from the tail.
 *
 * @param limit Maximum number of acquisitions.
 * @return Objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)lastWithLimit:(NSUInteger)limit NS_SWIFT_NAME(last(limit:));
/**
 * Select specified number of objects ordered by specified property from the tail.
 *
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @param limit Maximum number of acquisitions.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)lastOrderedBy:(NSString *)order
                                            ascending:(BOOL)ascending
                                                limit:(NSUInteger)limit NS_SWIFT_NAME(last(orderedBy:ascending:limit:)) DEPRECATED_ATTRIBUTE;
/**
 * Find an object by specified ID.
 *
 * @param uid The primary key generated by ActiveRealm automatically.
 * @return An object.
 */
+ (nullable instancetype)findByID:(NSString *)uid NS_SWIFT_NAME(find(ID:));
/**
 * Find an object by specified parameters. When multiple objects are found, select first object.
 *
 * @param dictionary Parameters for searching.
 * @return An object if found, otherwise nil.
 */
+ (nullable instancetype)find:(NSDictionary<NSString *, id> *)dictionary;
/**
 * Find an object by a format. When multiple objects are found, select first object.
 *
 * @param format A format.
 * @return An object if found, otherwise nil.
 */
+ (nullable instancetype)findWithFormat:(NSString *)format, ...;
/**
 * Find an object by a NSPredicate. When multiple objects are found, select first object.
 *
 * @param predicate A NSPredicate.
 * @return An object if found, otherwise nil.
 */
+ (nullable instancetype)findWithPredicate:(NSPredicate *)predicate;
/**
 * Find an object by specified parameters. When multiple objects are found, select last object.
 *
 * @param dictionary Parameters for searching.
 * @return An object if found, otherwise nil.
 */
+ (nullable instancetype)findLast:(NSDictionary<NSString *, id> *)dictionary;
/**
 *
 * Find an object by a format. When multiple objects are found, select last object.
 *
 * @param format A format.
 * @return An object if found, otherwise nil.
 */
+ (nullable instancetype)findLastWithFormat:(NSString *)format, ...;
/**
 * Find an object by a NSPredicate. When multiple objects are found, select last object.
 *
 * @param predicate A NSPredicate.
 * @return An object if found, otherwise nil.
 */
+ (nullable instancetype)findLastWithPredicate:(NSPredicate *)predicate;
/**
 * Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters. NOT save yet.
 *
 * @param dictionary Parameters for searching. If an object does not exist, the parameters are used to initialize it.
 * @return An object.
 */
+ (instancetype)findOrInitialize:(NSDictionary<NSString *, id> *)dictionary;
/**
 * Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
 *
 * @param dictionary Parameters for searching. If an object does not exist, the parameters are used to initialize it.
 * @return An object.
 */
+ (instancetype)findOrCreate:(NSDictionary<NSString *, id> *)dictionary;
/**
 * Find multiple objects by specified parameters.
 *
 * @param dictionary Parameters for searching.
 * @return Objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary DEPRECATED_ATTRIBUTE;
/**
 * Find multiple objects by a format.
 *
 * @param format A format.
 * @return Objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)whereWithFormat:(NSString *)format, ... DEPRECATED_ATTRIBUTE;
/**
 * Find multiple objects by a NSPredicate.
 *
 * @param predicate A NSPredicate.
 * @return Objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate DEPRECATED_ATTRIBUTE;
/**
 * Find multiple objects by specified parameters. The results are ordered by specified property.
 *
 * @param dictionary Parameters for searching.
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                                    orderedBy:(NSString *)order
                                    ascending:(BOOL)ascending DEPRECATED_ATTRIBUTE;
/**
 * Find specified number of objects by specified parameters. The results are ordered by specified property.
 *
 * @param dictionary Parameters for searching.
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @param limit Maximum number of acquisitions.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)where:(NSDictionary<NSString *, id> *)dictionary
                                    orderedBy:(NSString *)order
                                    ascending:(BOOL)ascending
                                        limit:(NSUInteger)limit DEPRECATED_ATTRIBUTE;
/**
 * Find specified number of objects by a format. The results are ordered by specified property.
 *
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @param format A format.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)whereOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                format:(NSString *)format, ... DEPRECATED_ATTRIBUTE;
/**
 * Find specified number of objects by a format. The results are ordered by specified property.
 *
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @param limit Maximum number of acquisitions.
 * @param format A format.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)whereOrderedBy:(NSString *)order
                                             ascending:(BOOL)ascending
                                                 limit:(NSUInteger)limit
                                                format:(NSString *)format, ... DEPRECATED_ATTRIBUTE;
/**
 * Find specified number of objects by a NSPredicate. The results are ordered by specified property.
 *
 * @param predicate A NSPredicate.
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                                 orderedBy:(NSString *)order
                                                 ascending:(BOOL)ascending DEPRECATED_ATTRIBUTE;
/**
 * Find specified number of objects by a NSPredicate. The results are ordered by specified property.
 *
 * @param predicate A NSPredicate.
 * @param order A property name.
 * @param ascending YES if ascending order.
 * @param limit Maximum number of acquisitions.
 * @return Sorted objects.
 */
+ (NSArray<__kindof ARMActiveRealm *> *)whereWithPredicate:(NSPredicate *)predicate
                                                 orderedBy:(NSString *)order
                                                 ascending:(BOOL)ascending
                                                     limit:(NSUInteger)limit DEPRECATED_ATTRIBUTE;
/**
 * Deletes objects and related objects searched by specified parameters.
 *
 * @param dictionary Parameters for searching.
 */
+ (void)destroy:(NSDictionary<NSString *, id> *)dictionary;
/**
 * Deletes objects and related objects searched by specified searching condition with a format.
 *
 * @param format A format.
 */
+ (void)destroyWithFormat:(NSString *)format, ...;
/**
 * Deletes objects and related objects searched by specified searching condition with a predicate.
 *
 * @param predicate A NSPredicate.
 */
+ (void)destroyWithPredicate:(NSPredicate *)predicate;
/**
 * Deletes objects searched by specified parameters.
 * If not cascade deleting. Specify NO to cascade argument.
 *
 * @param dictionary Parameters for searching.
 * @param cascade NO if not cascade deleting.
 */
+ (void)destroy:(NSDictionary<NSString *, id> *)dictionary cascade:(BOOL)cascade;
/**
 * Deletes objects searched by specified searching condition with a format.
 * If not cascade deleting. Specify NO to cascade argument.
 *
 * @param cascade NO if not cascade deleting.
 * @param format A format.
 */
+ (void)destroyWithCascade:(BOOL)cascade format:(NSString *)format, ...;
/**
 * Deletes objects searched by specified searching condition with a predicate.
 * If not cascade deleting. Specify NO to cascade argument.
 *
 * @param predicate A NSPredicate.
 * @param cascade NO if not cascade deleting.
 */
+ (void)destroyWithPredicate:(NSPredicate *)predicate cascade:(BOOL)cascade;
/**
 * Deletes all objects and related objects at the same time.
 */
+ (void)destroyAll;
/**
 * Deletes all objects.
 * If not cascade deleting. Specify NO to cascade argument.
 *
 * @param cascade NO if not cascade deleting.
 */
+ (void)destroyAllWithCascade:(BOOL)cascade;

@end

@interface ARMActiveRealm (Converting)
/**
 * Convert to a dictionary.
 *
 * @return A dictionary.
 */
- (NSDictionary *)asDictionary;
/**
 * Convert to a dictionary using a conversion logic.
 *
 * @param converter A block.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryWithBlock:(id (^)(NSString *prop, id value))converter;
/**
 * Convert to a dictionary using a black list of property names.
 *
 * @param exceptedProperties A black list of property names.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties
NS_SWIFT_NAME(asDictionary(excepted:));
/**
 * Convert to a dictionary using a black list of property names and a conversion logic.
 *
 * @param exceptedProperties A black list of property names.
 * @param converter A block.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                            block:(id (^)(NSString *prop, id value))converter
NS_SWIFT_NAME(asDictionary(excepted:block:));
/**
 * Convert to a dictionary using a white list of property names. This method also includes ignored properties.
 *
 * @param includedProperties A white list of property names.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryIncludingProperties:(NSArray<NSString *> *)includedProperties
NS_SWIFT_NAME(asDictionary(included:));
/**
 * Convert to a dictionary using white list of property names and a conversion logic.
 *
 * @param includedProperties A white list of property names.
 * @param converter A block.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryIncludingProperties:(NSArray<NSString *> *)includedProperties
                                            block:(id (^)(NSString *prop, id value))converter
NS_SWIFT_NAME(asDictionary(included:block:));
/**
 * Convert to a dictionary adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryAddingPropertiesWithTarget:(id)target
                                                 methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asDictionary(addingPropertiesWith:methods:));
/**
 * Convert to a dictionary adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param exceptedProperties A black list of property names.
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                       addingPropertiesWithTarget:(id)target
                                          methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asDictionary(excepted:addingPropertiesWith:methods:));
/**
 * Convert to a dictionary adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param includedProperties A white list of property names.
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A dictionary.
 */
- (NSDictionary *)asDictionaryIncludingProperties:(NSArray<NSString *> *)includedProperties
                       addingPropertiesWithTarget:(id)target
                                          methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asDictionary(included:addingPropertiesWith:methods:));
/**
 * Convert to a JSON.
 *
 * @return A JSON.
 */
- (NSData *)asJSON;
/**
 * Convert to a JSON using a conversion logic.
 *
 * @param converter A block.
 * @return A JSON.
 */
- (NSData *)asJSONWithBlock:(id (^)(NSString *prop, id value))converter;
/**
 * Convert to a JSON using a black list of property names.
 *
 * @param exceptedProperties A black list of property names.
 * @return A JSON.
 */
- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties
NS_SWIFT_NAME(asJSON(excepted:));
/**
 * Convert to a JSON using a black list of property names and a conversion logic.
 *
 * @param exceptedProperties A black list of property names.
 * @param converter A block.
 * @return A JSON.
 */
- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                block:(id (^)(NSString *prop, id value))converter
NS_SWIFT_NAME(asJSON(excepted:block:));
/**
 * Convert to a JSON using a white list of property names. This method also includes ignored properties.
 *
 * @param includedProperties A white list of property names.
 * @return A JSON.
 */
- (NSData *)asJSONIncludingProperties:(NSArray<NSString *> *)includedProperties
NS_SWIFT_NAME(asJSON(included:));
/**
 * Convert to a JSON using a white list of property names and a conversion logic.
 *
 * @param includedProperties A white list of property names.
 * @param converter A block.
 * @return A JSON.
 */
- (NSData *)asJSONIncludingProperties:(NSArray<NSString *> *)includedProperties
                                block:(id (^)(NSString *prop, id value))converter
NS_SWIFT_NAME(asJSON(included:block:));
/**
 * Convert to a JSON adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A JSON.
 */
- (NSData *)asJSONAddingPropertiesWithTarget:(id)target methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asJSON(addingPropertiesWith:methods:));
/**
 * Convert to a JSON adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param exceptedProperties A black list of property names.
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A JSON.
 */
- (NSData *)asJSONExceptingProperties:(NSArray<NSString *> *)exceptedProperties
           addingPropertiesWithTarget:(id)target
                              methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asJSON(excepted:addingPropertiesWith:methods:));
/**
 * Convert to a JSON adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param includedProperties A white list of property names.
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A JSON.
 */
- (NSData *)asJSONIncludingProperties:(NSArray<NSString *> *)includedProperties
           addingPropertiesWithTarget:(id)target
                              methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asJSON(included:addingPropertiesWith:methods:));
/**
 * Convert to a JSON.
 *
 * @return A JSON.
 */
- (NSString *)asJSONString;
/**
 * Convert to a JSON using a conversion logic.
 *
 * @param converter A block.
 * @return A JSON.
 */
- (NSString *)asJSONStringWithBlock:(id (^)(NSString *prop, id value))converter;
/**
 * Convert to a JSON using a black list of property names.
 *
 * @param exceptedProperties A black list of property names.
 * @return A JSON.
 */
- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties
NS_SWIFT_NAME(asJSONString(excepted:));
/**
 * Convert to a JSON using a black list of property names and a conversion logic.
 *
 * @param exceptedProperties A black list of property names.
 * @param converter A block.
 * @return A JSON.
 */
- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                                        block:(id (^)(NSString *prop, id value))converter
NS_SWIFT_NAME(asJSONString(excepted:block:));
/**
 * Convert to a JSON using a white list of property names. This method also includes ignored properties.
 *
 * @param includedProperties A white list of property names.
 * @return A JSON.
 */
- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties
NS_SWIFT_NAME(asJSONString(included:));
/**
 * Convert to a JSON using a white list of property names and a conversion logic.
 *
 * @param includedProperties A white list of property names.
 * @param converter A block.
 * @return A JSON.
 */
- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties
                                        block:(id (^)(NSString *prop, id value))converter
NS_SWIFT_NAME(asJSONString(included:block:));
/**
 * Convert to a JSON adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A JSON.
 */
- (NSString *)asJSONStringAddingPropertiesWithTarget:(id)target methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asJSONString(addingPropertiesWith:methods:));
/**
 * Convert to a JSON adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param exceptedProperties A black list of property names.
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A JSON.
 */
- (NSString *)asJSONStringExceptingProperties:(NSArray<NSString *> *)exceptedProperties
                   addingPropertiesWithTarget:(id)target
                                      methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asJSONString(excepted:addingPropertiesWith:methods:));
/**
 * Convert to a JSON adding properties with a conversion method of a target.
 * The method name is specified by Objective-C representation.
 *
 * @param includedProperties A white list of property names.
 * @param target A target for conversion methods.
 * @param methods Method names.
 * @return A JSON.
 */
- (NSString *)asJSONStringIncludingProperties:(NSArray<NSString *> *)includedProperties
                   addingPropertiesWithTarget:(id)target
                                      methods:(NSDictionary<NSString *, NSString *> *)methods
NS_SWIFT_NAME(asJSONString(included:addingPropertiesWith:methods:));

@end

@interface ARMActiveRealm (Counting)
/**
 * Returns the number of objects of the model.
 *
 * @return The number of objects.
 */
@property (class, nonatomic, readonly) NSUInteger count;
/**
 * Returns the number of objects searched by specified parameters.
 *
 * @param dictionary Parameters for searching.
 * @return The number of objects.
 */
+ (NSUInteger)countWhere:(NSDictionary<NSString *, id> *)dictionary NS_SWIFT_NAME(count(where:)) DEPRECATED_ATTRIBUTE;
/**
 * Returns the number of objects searched by specified searching condition.
 *
 * @param format A format.
 * @return The number of objects.
 */
+ (NSUInteger)countWithFormat:(NSString *)format, ... DEPRECATED_ATTRIBUTE;
/**
 * Returns the number of objects searched by specified searching condition.
 *
 * @param predicate A NSPredicate.
 * @return The number of objects.
 */
+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate NS_SWIFT_NAME(count(predicate:)) DEPRECATED_ATTRIBUTE;

@end

@interface ARMActiveRealm (Callback)

+ (void)beforeCreate:(__kindof ARMActiveRealm *)obj;
+ (void)beforeUpdate:(__kindof ARMActiveRealm *)obj;
+ (void)beforeSave:(__kindof ARMActiveRealm *)obj;
+ (void)afterCreate:(__kindof ARMActiveRealm *)obj;
+ (void)afterUpdate:(__kindof ARMActiveRealm *)obj;
+ (void)afterSave:(__kindof ARMActiveRealm *)obj;
+ (void)beforeDestroy:(__kindof ARMActiveRealm *)obj;
+ (void)afterDestroy:(__kindof ARMActiveRealm *)obj;

@end

NS_ASSUME_NONNULL_END
