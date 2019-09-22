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

#import "ARMCollection.h"

#import "ARMActiveRealm.h"
#import "ARMActiveRealm+Internal.h"
#import "ARMRelation.h"
#import "ARMRelation+Internal.h"
#import "ARMRelationship.h"

@interface ARMActiveRealm ()

@property (nonatomic, copy) NSDictionary<NSString *, ARMRelation *> *relations;

@end

@interface ARMCollection ()

@property (nonatomic) Class modelClass;
@property (nonatomic) RLMResults *results;

@end

@implementation ARMCollection

- (instancetype)initWithClass:(Class)aClass results:(RLMResults *)results {
    self = [super init];

    if (self) {
        _modelClass = aClass;
        _results = [results sortedResultsUsingKeyPath:@"createdAt" ascending:YES];
    }

    return self;
}

#pragma mark - public method

- (NSArray<__kindof ARMActiveRealm *> *)toArray {
    NSMutableArray<ARMActiveRealm *> *array = [NSMutableArray new];

    for (RLMObject *obj in self.results) {
        [array addObject:[self activeRealmFromRLMObject:obj]];
    }

    return array;
}

- (nullable __kindof ARMActiveRealm *)first {
    return self.results.firstObject ? [self activeRealmFromRLMObject:self.results.firstObject] : nil;
}

- (nullable __kindof ARMActiveRealm *)last {
    return self.results.lastObject ? [self activeRealmFromRLMObject:self.results.lastObject] : nil;
}

- (NSUInteger)count {
    return self.results.count;
}

- (instancetype)order:(NSString *)property ascending:(BOOL)ascending {
    self.results = [self.results sortedResultsUsingKeyPath:property ascending:ascending];
    return self;
}

- (NSArray<__kindof ARMActiveRealm *> *)firstWithLimit:(NSUInteger)limit {
    NSArray *results = self.toArray;

    if (results.count <= limit) {
        return results;
    }

    return [results subarrayWithRange:NSMakeRange(0, limit)];
}

- (NSArray<__kindof ARMActiveRealm *> *)lastWithLimit:(NSUInteger)limit {
    NSArray *results = self.toArray;

    if (results.count <= limit) {
        return results;
    }

    results = [results.reverseObjectEnumerator.allObjects subarrayWithRange:NSMakeRange(0, limit)];

    return results.reverseObjectEnumerator.allObjects;
}

- (NSArray *)pluck:(NSArray<NSString *> *)properties {
    NSMutableArray *array = [NSMutableArray new];

    for (RLMObject *obj in self.results) {
        if (properties.count == 1) {
            id value = obj[properties.firstObject];

            if (value) {
                [array addObject:value];
            }
        }
        else if (properties.count > 1) {
            NSMutableArray *values = [NSMutableArray new];

            for (NSString *prop in properties) {
                id value = obj[prop];
                [values addObject:value ?: [NSNull null]];
            }

            [array addObject:values];
        }
    }

    return array;
}

- (__kindof ARMActiveRealm *)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self activeRealmFromRLMObject:self.results[idx]];
}

#pragma mark - private method

- (ARMActiveRealm *)activeRealmFromRLMObject:(RLMObject *)obj {
    ARMActiveRealm *activeRealm = (ARMActiveRealm *) [self.modelClass new];

    for (NSString *prop in [self.modelClass propertyNames]) {
        activeRealm[prop] = obj[prop];
    }

    NSMutableDictionary<NSString *, ARMRelation *> *relations = [NSMutableDictionary new];

    NSDictionary<NSString *, ARMRelationship *> *definedRelationships = [self.modelClass definedRelationships];

    for (NSString *prop in definedRelationships) {
        relations[prop] = [ARMRelation relationWithObject:activeRealm relationship:definedRelationships[prop]];
    }

    activeRealm.relations = relations;

    return activeRealm;
}

@end
