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

#import "ARMQuery.h"

#import "ARMActiveRealmManager.h"
#import "ARMCollection.h"

@interface ARMQuery ()

@property (nonatomic) Class modelClass;

@end

@implementation ARMQuery

- (instancetype)initWithClass:(Class)aClass {
    self = [super init];

    if (self) {
        _modelClass = aClass;
    }

    return self;
}

#pragma mark - public method

- (ARMCollection *)all {
    Class rlmObjClass = [[ARMActiveRealmManager sharedInstance] map:self.modelClass];
    SEL sel = NSSelectorFromString(@"allObjectsInRealm:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    RLMResults *(*func)(id, SEL, RLMRealm *) = (void *) imp;
    RLMResults *results = func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.defaultRealm);

    return [[ARMCollection alloc] initWithClass:self.modelClass results:results];
}

- (ARMCollection *)where:(NSDictionary<NSString *, id> *)dictionary {
    return [self whereWithPredicate:[ARMQuery predicateWithDictionary:dictionary]];
}

- (ARMCollection *)whereWithPredicate:(NSPredicate *)predicate {
    Class rlmObjClass = [[ARMActiveRealmManager sharedInstance] map:self.modelClass];
    SEL sel = NSSelectorFromString(@"objectsInRealm:withPredicate:");
    IMP imp = [rlmObjClass methodForSelector:sel];
    RLMResults *(*func)(id, SEL, RLMRealm *, NSPredicate *) = (void *) imp;
    RLMResults *results = func(rlmObjClass, sel, ARMActiveRealmManager.sharedInstance.defaultRealm, predicate);

    return [[ARMCollection alloc] initWithClass:self.modelClass results:results];
}

- (ARMCollection *)whereWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    va_end(args);

    return [self whereWithPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
}

#pragma mark - private method

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

@end
