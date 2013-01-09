//
//  UIViewHelpersTests.m
//  UIViewHelpersTests
//
//  Created by Matt Holden on 1/8/13.
//  Copyright (c) 2013 Matt Holden. All rights reserved.
//

#import "UIViewHelpersTests.h"
#import "UIView+Helpers.h"

@interface UIViewHelpersTests()
@end
@implementation UIViewHelpersTests

UIView* loadFromNib() {
    return [[NSBundle mainBundle] loadNibNamed:@"TestView"
                                  owner:nil
                                options:nil][0];
};

-(void)testSubviewsPassingTestBasic {
    const int NUM_VIEWS = 4;
    UIView *countTestView = [[UIView alloc] init];
    UIView *nextView = countTestView;
    countTestView.tag = 0;
    for (int i = 0; i < NUM_VIEWS; i++) {
        UIView *subview = [[UIView alloc] init];
        subview.tag = i+1;
        [nextView addSubview:subview];
        nextView = subview;
    }
    
    NSArray *passes = [countTestView subviewsPassingTest:^BOOL(UIView *view, BOOL *stop) {
        return 1 == 1;
    }];

    STAssertTrue([passes count] == NUM_VIEWS, @"Found %i, subviews that passed test '1==1'", NUM_VIEWS);
    
    passes = [countTestView subviewsPassingTest:^BOOL(UIView *view, BOOL *stop) {
        return 0 == 1;
    }];
    STAssertTrue([passes count] == 0, @"Found 0, subviews that passed test '0==1'");
    
    passes = [countTestView subviewsPassingTest:^BOOL(UIView *aView, BOOL *stop) {
        return aView.tag == 2;
    }];
    STAssertTrue([passes count] == 1, @"Found 1 subview with a tag property of 2");
    STAssertTrue([passes count] && [(UIView*)(passes[0]) tag] == 2, @"Found correct UIView with tag==2");
}

-(void)testSubviewsPassingTestsFromNIB {
    UIView *view = loadFromNib();
    
    int expected = 4;
    NSArray *passes = [view subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
        return [subview isKindOfClass:[UIButton class]];
    }];
    STAssertTrue([passes count] == expected, @"Found %i, expected %i", [passes count], expected);
    
    passes = [view subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
        return [[subview subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
            return [subview isKindOfClass:[UISegmentedControl class]];
        }] count] == 2;
    }];
    expected = 1;
    STAssertTrue(passes.count == expected, @"Found %i view with two children that were UISegmentedControls, expected %i.", passes.count, expected);
    
    passes = [view subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
        return [subview isKindOfClass:[UISegmentedControl class]];
    }];
    expected = 3;
    STAssertTrue(passes.count == expected, @"Found a total of %i UISegmentedControls, expected %i", [passes count], expected);
}

-(void)testSubviewsPassingTestWithStopParameter {
    UIView *view = loadFromNib();
    
    // First, count the total number of subviews in the NIB
    int totalSubviewCount = [[view subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
        return YES;
    }] count];
    
    // Find three of the 4 UIButton instances
    __block int foundButtonCount = 0;
    __block int evaluatedSubviews = 0;
    int testPassCount = [[view subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
        BOOL isButton = [subview isKindOfClass:[UIButton class]];
        if (isButton)
            *stop = (++foundButtonCount == 2);
        evaluatedSubviews++;
        return isButton;
    }] count];
    
    STAssertTrue(foundButtonCount == 2, @"Should have stopped at foundButtonCount = %i", 2);
    STAssertTrue(testPassCount == 2, @"Number of items passing test was 2", 2);
    STAssertTrue(totalSubviewCount > evaluatedSubviews, @"*stop pointer worked successfully, we evaluated fewer subviews");
}

-(void)testSubviewsPassingTestWithDepth {
    UIView *node, *rootView;
    node = rootView = [[UIView alloc] init];
    
    int i = 5;
    while (i--) {
        UIView *subview = [[UIView alloc] init];
        subview.tag = 5-i;
        [node addSubview:subview];
        node = subview;
    }
    
    int maxDepth = 2;
    NSArray *passedViews = [rootView subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
        return YES;
    } maxDepth:maxDepth];
    
    STAssertTrue([passedViews count] == maxDepth, @"Found %i subviews, should have found %i", [passedViews count], maxDepth);
    passedViews = [passedViews sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int first = [((UIView*)obj1) tag];
        int second = [((UIView*)obj2) tag];
        if (first < second)
            return NSOrderedAscending;
        else if (first > second)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    STAssertTrue([passedViews count]
                 && [passedViews count] == 2
                 && ((UIView*)passedViews[0]).tag == 1
                 && ((UIView*)passedViews[1]).tag == 2,
                 @"Found correct views with expected Tag properties");
    
}
@end
