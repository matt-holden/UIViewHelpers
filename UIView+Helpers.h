//
//  UIView+Helpers.h
//  UIViewHelpers
//
//  Created by Matt Holden on 1/8/13.
//  Copyright (c) 2013 Matt Holden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helpers)

-(UIView*)firstSubviewPassingTest:(BOOL(^)(UIView *subview))test;

-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test;
-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test
                      maxDepth:(NSInteger)depth;

-(NSArray*)subviewsMatchingClass:(Class)aClass;
-(NSArray*)subviewsMatchingClass:(Class)aClass
                        maxDepth:(NSInteger)depth;

-(NSArray*)subviewsMatchingClassOrSubclass:(Class)aClass;
-(NSArray*)subviewsMatchingClassOrSubclass:(Class)aClass
                                  maxDepth:(NSInteger)depth;
@end
