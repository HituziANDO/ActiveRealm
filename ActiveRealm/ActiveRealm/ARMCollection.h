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

@class ARMActiveRealm;
@class RLMResults;

@interface ARMCollection : NSObject
/**
 * The models in the collection.
 */
@property (nonatomic, copy, readonly) NSArray<__kindof ARMActiveRealm *> *toArray;
/**
 * The first model in the collection.
 */
@property (nonatomic, nullable, readonly) __kindof ARMActiveRealm *first;
/**
 * The last model in the collection.
 */
@property (nonatomic, nullable, readonly) __kindof ARMActiveRealm *last;
/**
 * The number of models in the collection.
 */
@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithClass:(Class)aClass results:(RLMResults *)results;

/**
 * Sorts objects in the collection by specified property.
 *
 * @param property A property.
 * @param ascending YES if ascending, otherwise descending.
 * @return The collection.
 */
- (instancetype)order:(NSString *)property ascending:(BOOL)ascending;
/**
 * Returns specified number of the models from the head.
 *
 * @param limit Maximum number of acquisitions.
 * @return Objects of the model.
 */
- (NSArray<__kindof ARMActiveRealm *> *)firstWithLimit:(NSUInteger)limit NS_SWIFT_NAME(first(limit:));
/**
 * Returns specified number of the models from the tail.
 *
 * @param limit Maximum number of acquisitions.
 * @return Objects of the model.
 */
- (NSArray<__kindof ARMActiveRealm *> *)lastWithLimit:(NSUInteger)limit NS_SWIFT_NAME(last(limit:));
/**
 * Plucks properties of the model.
 *
 * @param properties Properties.
 * @return Property array.
 */
- (NSArray *)pluck:(NSArray<NSString *> *)properties;

@end

NS_ASSUME_NONNULL_END
