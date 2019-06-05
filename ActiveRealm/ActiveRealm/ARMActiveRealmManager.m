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

#import "ARMActiveRealmManager.h"

@implementation ARMActiveRealmManager

+ (instancetype)sharedInstance {
    static ARMActiveRealmManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ARMActiveRealmManager new];
    });

    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _realm = [RLMRealm defaultRealm];
    }

    return self;
}

#pragma mark - property

- (void)setRealm:(RLMRealm *)realm {
    if (realm) {
        _realm = realm;
    }
}

#pragma mark - public method

- (NSString *)stringFromClass:(Class)aClass namespace:(NSString *_Nullable *_Nullable)namespace {
    NSString *className = NSStringFromClass(aClass);

    // Remove namespace of Swift class.
    NSMutableArray<NSString *> *nameComponents = [className componentsSeparatedByString:@"."].mutableCopy;
    className = nameComponents.lastObject;
    [nameComponents removeLastObject];

    if (namespace) {
        *namespace = [nameComponents componentsJoinedByString:@"."];
    }

    if (self.vendorPrefix.length > 0) {
        className = [className substringFromIndex:self.vendorPrefix.length];
    }

    return className;
}

- (Class)map:(Class)aClass {
    NSString *namespace = nil;
    NSString *className = [self stringFromClass:aClass namespace:&namespace];
    NSString *arClassName = [NSString stringWithFormat:@"ActiveRealm%@", className];

    // Append namespace for Swift class.
    if (namespace.length > 0) {
        arClassName = [NSString stringWithFormat:@"%@.%@", namespace, arClassName];
    }

    Class arClass = NSClassFromString(arClassName);

    if (!arClass) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%@ class is not found.", arClassName]
                                     userInfo:nil];
    }

    return arClass;
}

@end
