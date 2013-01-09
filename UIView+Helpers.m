//
//  UIView+Helpers.m
//  UIViewHelpers
//
//  Created by Matt Holden on 1/8/13.
//  Copyright (c) 2013 Matt Holden. All rights reserved.
//

#define INFINITE_DEPTH -1 // Only used internally for private API
#define SuppressPerformSelectorLeakWarning(LeakyCode) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    LeakyCode; \
    _Pragma("clang diagnostic pop") \
} while (0)
#import "UIView+Helpers.h"

@interface UIView (HelpersPrivate)
-(NSArray*)subviewsMatchingClass:(Class)aClass
               includeSubclasses:(BOOL)includeSubclasses
                        maxDepth:(NSInteger)maxDepth;
@end
@implementation UIView (Helpers)

-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test
                      maxDepth:(NSInteger)maxDepth {
    
    if (maxDepth < 0) {
        [NSException raise:NSInvalidArgumentException format:@"maxDepth must be >= 0"];
    }
    
    BOOL(^newTest)(UIView *subview, BOOL*stop) = ^BOOL(UIView* subview, BOOL *stop) {
        UIView *node = subview;
        int currentDepth = 0; // We're automatically starting at "1" (i.e. first subview of self)
        
        while ((node = [node superview])) {
            if (++currentDepth > maxDepth) return NO;
        }
        return test(subview, stop);
    };
    return [self subviewsPassingTest:newTest];
}
-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test {
    __block BOOL stop = NO;
    
    NSArray*(^__block __unsafe_unretained capturedEvaluateAndRecurse)(UIView*);
    NSArray*(^evaluateAndRecurse)(UIView*);
    evaluateAndRecurse = ^NSArray*(UIView *view) {
        NSMutableArray *myPassedChildren = [[NSMutableArray alloc] init];
        for (UIView *subview in [view subviews]) {
            BOOL passes = test(subview, &stop);
            if (passes) [myPassedChildren addObject:subview];
            if (stop) return myPassedChildren;
            
            [myPassedChildren addObjectsFromArray:capturedEvaluateAndRecurse(subview)];
        }
        return myPassedChildren;
    };
    capturedEvaluateAndRecurse = evaluateAndRecurse;
    
    return evaluateAndRecurse(self);
}

-(NSArray*)subviewsMatchingClass:(Class)aClass {
    return [self subviewsMatchingClass:[aClass class]
                     includeSubclasses:NO
                              maxDepth:INFINITE_DEPTH];
}

-(NSArray*)subviewsMatchingClass:(Class)aClass
                        maxDepth:(NSInteger)depth {
    return [self subviewsMatchingClass:[aClass class]
                     includeSubclasses:NO
                              maxDepth:depth];
}

-(NSArray*)subviewsMatchingClassOrSubclass:(Class)aClass {
    return [self subviewsMatchingClass:[aClass class]
                     includeSubclasses:YES
                              maxDepth:INFINITE_DEPTH];
}
-(NSArray*)subviewsMatchingClassOrSubclass:(Class)aClass
                                  maxDepth:(NSInteger)depth {
    return [self subviewsMatchingClass:[aClass class]
                     includeSubclasses:YES
                              maxDepth:depth];
    
}

#pragma mark Private methods
-(NSArray*)subviewsMatchingClass:(Class)aClass
               includeSubclasses:(BOOL)includeSubclasses
                        maxDepth:(NSInteger)maxDepth {
    
    SEL comparisonSelector = includeSubclasses ? @selector(isKindOfClass:) : @selector(isMemberOfClass:);
    if (maxDepth == INFINITE_DEPTH)
        return [self subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
            SuppressPerformSelectorLeakWarning(return (BOOL)[subview performSelector:comparisonSelector withObject:aClass]);
        }];
    else
        return [self subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
            SuppressPerformSelectorLeakWarning(return (BOOL)[subview performSelector:comparisonSelector withObject:aClass]);
        } maxDepth:maxDepth];
}

@end
