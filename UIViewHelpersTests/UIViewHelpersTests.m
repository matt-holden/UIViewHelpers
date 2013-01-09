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
    
    const int DEPTH_TO_MAKE = 6;
    int i = DEPTH_TO_MAKE;
    while (i--) {
        UIView *subview = [[UIView alloc] init];
        [subview setTag:DEPTH_TO_MAKE-i];
        [node addSubview:subview];
        node = subview;
    }
    
    const int testDepths[5] = {1, 2, 3, 4, 5};
    for (int i = 0; i < 5; i++) {
        int maxDepth = testDepths[i];
        NSArray *passedViews = [rootView subviewsPassingTest:^BOOL(UIView *subview, BOOL *stop) {
            return YES;
        } maxDepth:maxDepth];
        
        // There is one child view for each view, so we can expect to find N UIViews for maxDepth = N
        STAssertTrue([passedViews count] == maxDepth, @"Found %i subviews, should have found %i", [passedViews count], maxDepth);
        
        // Sort on Tag property to prepare for the test that follow
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
        
        // Test that we received the correct subviews (not just the correct count of subviews!)
        // This is why we've set the .tag property above
        for (int j = 0; j < maxDepth; j++) {
            STAssertTrue([(UIView*)passedViews[j] tag] == j+1, @"When testing maxDepth %i, the %i-th passed subview had the correct tag %i", maxDepth, j, j+1);
        }
    }
}

-(void) testSubviewsMatchingClass {
    UIView *node, *rootView;
    node = rootView = [[UIView alloc] init];
    
    const int CLASSES_COUNT = 2;
    Class classes[CLASSES_COUNT] = {[UIView class], [UIButton class]};
    const int DEPTH_TO_MAKE = 8;
    NSAssert((DEPTH_TO_MAKE % CLASSES_COUNT == 0) && ((DEPTH_TO_MAKE/2) % 2 == 0), @"Note to self... these tests will start to fail if the DEPTH_TO_MAKE isn't a multiple of CLASSES_COUNT.  DEPTH_TO_MAKE / 2 should also be an even number.");
    
    int i = DEPTH_TO_MAKE;
    while (i--) {
        UIView *subview = [[classes[i%2] alloc] init];
        [node addSubview:subview];
        node = subview;
    }
    
    // Without maxDepth limitation
    for (int i = 0; i < CLASSES_COUNT; i++) {
        NSArray *passes = [rootView subviewsMatchingClass:classes[i]];
        STAssertTrue([passes count] == DEPTH_TO_MAKE/CLASSES_COUNT,
                     @"%i of %i of the subviews were of class %@.  Expecting %i",
                     [passes count], DEPTH_TO_MAKE, classes[i], DEPTH_TO_MAKE/CLASSES_COUNT);
    }
    
    // With maxDepth
    for (int i = 0; i < CLASSES_COUNT; i++) {
        // Test again, restricting maxDepth to one half the total subviews created
        const int MAX_DEPTH = DEPTH_TO_MAKE / 2;
        NSArray *passes = [rootView subviewsMatchingClass:classes[i]
                                                 maxDepth:MAX_DEPTH];
        NSLog(@"passes: %@", passes);
        NSLog(@"equal? %i", [passes count] == MAX_DEPTH/CLASSES_COUNT);
        
        STAssertTrue([passes count] == MAX_DEPTH/CLASSES_COUNT,
                     @"%i of %i of the subviews found checked were of class %@.  Expecting %i",
                     [passes count], MAX_DEPTH, classes[i], MAX_DEPTH/CLASSES_COUNT);
    }
}

-(void) testSubviewsMatchingClassOrSubClass {
    
    UIView *node, *rootView;
    node = rootView = [[UIView alloc] init];
    
    const int CLASSES_COUNT = 2;
    Class classes[CLASSES_COUNT] = {[UIView class], [UIButton class]};
    const int DEPTH_TO_MAKE = 8;
    NSAssert((DEPTH_TO_MAKE % CLASSES_COUNT == 0) && ((DEPTH_TO_MAKE/2) % 2 == 0), @"Note to self... these tests will start to fail if the DEPTH_TO_MAKE isn't a multiple of CLASSES_COUNT.  DEPTH_TO_MAKE / 2 should also be an even number.");
    
    int i = DEPTH_TO_MAKE;
    while (i--) {
        UIView *subview = [[classes[i%2] alloc] init];
        [node addSubview:subview];
        node = subview;
    }
    
    // Test against the "UIView" class. Because all subviews are UIView subclasses,
    // Every subview should be included in the result set.
    
    NSArray *passes;
    // Without maxDepth limitation
    passes = [rootView subviewsMatchingClassOrSubclass:[UIView class]];
    STAssertTrue([passes count] == DEPTH_TO_MAKE,
                 @"%i of %i of the subviews were of class %@.  Expecting %i",
                 [passes count], DEPTH_TO_MAKE, classes[i], DEPTH_TO_MAKE);
    
   // Test again, restricting maxDepth to one half the total subviews created
    const int MAX_DEPTH = DEPTH_TO_MAKE / 2;
    passes = [rootView subviewsMatchingClassOrSubclass:[UIView class]
                                    maxDepth:MAX_DEPTH];
    STAssertTrue([passes count] == MAX_DEPTH,
                 @"%i of %i of the subviews found checked were of class %@.  Expecting %i",
                 [passes count], MAX_DEPTH, classes[i], MAX_DEPTH);
}
@end
