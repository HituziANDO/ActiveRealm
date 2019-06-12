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

@interface ARMRelation : NSObject
/**
 * Tells whether the relationship is One-to-One.
 */
@property (nonatomic, readonly) BOOL hasOne;
/**
 * Tells whether the relationship is One-to-Many.
 */
@property (nonatomic, readonly) BOOL hasMany;
/**
 * Tells whether the relationship is inverse relationship for One-to-One or One-to-Many.
 */
@property (nonatomic, readonly) BOOL belongsTo;
/**
 * If `hasOne` property is YES, returns a child object of the relationship.
 * On the other hand, if `belongsTo` property is YES, returns a parent object.
 * Otherwise, returns nil.
 */
@property (nonatomic, readonly, nullable) __kindof ARMActiveRealm *object;
/**
 * If `hasMany` property is YES, returns children objects of the relationships, otherwise nil.
 */
@property (nonatomic, readonly, nullable) NSArray<__kindof ARMActiveRealm *> *objects;

@end

NS_ASSUME_NONNULL_END
