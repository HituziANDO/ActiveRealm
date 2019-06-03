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

#import "ARMRelation.h"
#import "ARMRelation+Internal.h"

@interface ARMRelation ()

@property (nonatomic) Class relationClass;
@property (nonatomic) ARMRelationshipType type;
@property (nonatomic, copy, nullable) NSString *foreignKey;
@property (nonatomic, copy, nullable) NSString *foreignKeyName;

@end

@implementation ARMRelation

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"relationClass",
        @"type",
        @"foreignKey",
        @"foreignKeyName"
    ]].description;
}

#pragma mark - property

- (BOOL)hasOne {
    return self.type == ARMRelationshipTypeHasOne;
}

- (BOOL)hasMany {
    return self.type == ARMRelationshipTypeHasMany;
}

- (nullable ARMActiveRealm *)object {
    if (!self.hasOne) {
        return nil;
    }

    SEL sel = NSSelectorFromString(@"findOrInitialize:");
    IMP imp = [self.relationClass methodForSelector:sel];
    id (*func)(id, SEL, NSDictionary *) = (void *) imp;

    return func(self.relationClass, sel, @{ self.foreignKeyName: self.foreignKey });
}

- (nullable NSArray<ARMActiveRealm *> *)objects {
    if (!self.hasMany) {
        return nil;
    }

    SEL sel = NSSelectorFromString(@"where:");
    IMP imp = [self.relationClass methodForSelector:sel];
    NSArray *(*func)(id, SEL, NSDictionary *) = (void *) imp;

    return func(self.relationClass, sel, @{ self.foreignKeyName: self.foreignKey });
}

@end

@implementation ARMRelation (Internal)

+ (instancetype)relationWithID:(NSString *)uid relationship:(ARMRelationship *)relationship belongsTo:(Class)aClass {
    ARMRelation *relation = [ARMRelation new];
    relation.relationClass = relationship.relationClass;
    relation.type = relationship.type;
    relation.foreignKey = uid;

    NSString *className = NSStringFromClass(aClass);
    relation.foreignKeyName = [NSString stringWithFormat:@"%@%@ID",
                                                         [className substringToIndex:1].lowercaseString,
                                                         [className substringFromIndex:1]];

    return relation;
}

@end
