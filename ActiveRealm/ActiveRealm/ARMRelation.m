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

#import "ARMActiveRealm.h"
#import "ARMActiveRealm+Internal.h"

@interface ARMRelation ()

@property (nonatomic) ARMActiveRealm *activeRealm;
@property (nonatomic) ARMRelationship *relationship;
@property (nonatomic, copy, nullable) NSString *foreignKeyName;

@end

@implementation ARMRelation

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[
        @"activeRealm",
        @"relationship",
        @"foreignKeyName"
    ]].description;
}

#pragma mark - property

- (BOOL)hasOne {
    return self.relationship.type == ARMRelationshipTypeHasOne;
}

- (BOOL)hasMany {
    return self.relationship.type == ARMRelationshipTypeHasMany;
}

- (BOOL)belongsTo {
    return self.relationship.type == ARMInverseRelationshipTypeBelongsTo;
}

- (nullable ARMActiveRealm *)object {
    if (self.hasOne) {
        SEL sel = NSSelectorFromString(@"find:");
        IMP imp = [self.relationship.relationClass methodForSelector:sel];
        id (*func)(id, SEL, NSDictionary *) = (void *) imp;

        return func(self.relationship.relationClass, sel, @{ self.foreignKeyName: self.activeRealm.uid });
    }
    else if (self.belongsTo) {
        SEL sel = NSSelectorFromString(@"findByID:");
        IMP imp = [self.relationship.relationClass methodForSelector:sel];
        id (*func)(id, SEL, NSString *) = (void *) imp;

        return func(self.relationship.relationClass, sel, self.activeRealm[self.foreignKeyName]);
    }

    return nil;
}

- (nullable NSArray<ARMActiveRealm *> *)objects {
    if (!self.hasMany) {
        return nil;
    }

    SEL sel = NSSelectorFromString(@"where:");
    IMP imp = [self.relationship.relationClass methodForSelector:sel];
    NSArray *(*func)(id, SEL, NSDictionary *) = (void *) imp;

    return func(self.relationship.relationClass, sel, @{ self.foreignKeyName: self.activeRealm.uid });
}

@end

@implementation ARMRelation (Internal)

+ (instancetype)relationWithObject:(ARMActiveRealm *)activeRealm relationship:(ARMRelationship *)relationship {
    ARMRelation *relation = [ARMRelation new];
    relation.activeRealm = activeRealm;
    relation.relationship = relationship;

    NSString *className = relation.belongsTo ?
        NSStringFromClass(relationship.relationClass) :
        NSStringFromClass(activeRealm.class);
    relation.foreignKeyName = [NSString stringWithFormat:@"%@%@ID",
                                                         [className substringToIndex:1].lowercaseString,
                                                         [className substringFromIndex:1]];

    return relation;
}

@end
