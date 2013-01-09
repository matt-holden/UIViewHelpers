//
//  UIView+Helpers.h
//  UIViewHelpers
//
//  Created by Matt Holden on 1/8/13.
//  Copyright (c) 2013 Matt Holden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helpers)

-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test;
-(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test
                      maxDepth:(NSInteger)depth;
-(NSArray*)subviewsMatchingClass:(__unsafe_unretained Class)aClass;


@end
