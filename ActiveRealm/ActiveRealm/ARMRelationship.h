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

typedef NS_ENUM(NSInteger, ARMRelationshipType) {
    ARMRelationshipTypeHasOne = 0,
    ARMRelationshipTypeHasMany
};

@interface ARMRelationship : NSObject

@property (nonatomic, readonly) Class relationClass;
@property (nonatomic, readonly) NSInteger type;

+ (instancetype)relationshipWithClass:(Class)relationClass type:(ARMRelationshipType)type;

@end

typedef NS_ENUM(NSInteger, ARMInverseRelationshipType) {
    ARMInverseRelationshipTypeBelongsTo = 10
};

@interface ARMInverseRelationship : ARMRelationship

+ (instancetype)relationshipWithClass:(Class)relationClass type:(ARMRelationshipType)type DEPRECATED_MSG_ATTRIBUTE(
    "Use `+inverseRelationshipWithClass:type:` instead.");
+ (instancetype)inverseRelationshipWithClass:(Class)relationClass type:(ARMInverseRelationshipType)type;

@end

NS_ASSUME_NONNULL_END
