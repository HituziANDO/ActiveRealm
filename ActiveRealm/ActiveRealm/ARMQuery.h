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

@interface ARMQuery : NSObject
/**
 * Returns all objects of the model.
 */
@property (nonatomic, readonly) ARMCollection *all;

- (instancetype)initWithClass:(Class)aClass;

/**
 * Returns objects searched by specified parameters.
 *
 * @param dictionary Parameters for searching.
 * @return Objects of the model.
 */
- (ARMCollection *)where:(NSDictionary<NSString *, id> *)dictionary;
/**
 * Returns objects searched by specified searching condition with a predicate.
 *
 * @param predicate A NSPredicate.
 * @return Objects of the model.
 */
- (ARMCollection *)whereWithPredicate:(NSPredicate *)predicate NS_SWIFT_NAME(where(predicate:));
/**
 * Returns objects searched by specified searching condition with a format.
 *
 * @param format A format.
 * @return Objects of the model.
 */
- (ARMCollection *)whereWithFormat:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
