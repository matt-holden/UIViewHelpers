//
//  UIView+Helpers.m
//  UIViewHelpers
//
//  Created by Matt Holden on 1/8/13.
//  Copyright (c) 2013 Matt Holden. All rights reserved.
//

#import "UIView+Helpers.h"

@implementation UIView (Helpers)

-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test
                      maxDepth:(NSInteger)maxDepth {
    
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

-(NSArray*)subviewsMatchingClass:(__unsafe_unretained Class)aClass {
    return nil;
}


@end
