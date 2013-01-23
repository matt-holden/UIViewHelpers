This is a growing collection of helper methods in a Category on `UIView`. Includes a collection of unit tests.  

As of now, every method in this category is dedicated to recursing subviews of a UIView and testing each against a condition.  

Say you wanted to find your application's "first responder."  Using the category method `firstSubviewPassingTest:`, you could easily iterate all your application's subviews to locate the first responder.


    -(UIView*)findCurrentFirstResponder {
        // Get the app's highest-level view
        UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
        
        // Recurse through all its subviews to find the first responder
        return [rootView firstSubviewPassingTest:^BOOL(UIView *subview) {
            if ([subview isKindOfClass:[UIResponder class]])
                return [(UIResponder*)subview isFirstResponder];
            else return NO;
        }];
    }


<br/>
Match subviews against a block
-

Find the first subview of `self` for which the block `test` returns `YES`, and immediately cease recursion:

    -(UIView*)firstSubviewPassingTest:(BOOL(^)(UIView *subview))test;

Collect all subviews of `self` for which the block `test` returns `YES`:
    
    -(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test;

Collect all subviews, **(traversed to a maximum `depth`)** of `self` for which the block `test` returns `YES`:
    
    -(NSArray*)subviewsPassingTest:(BOOL(^)(UIView *subview, BOOL *stop))test
                          maxDepth:(NSInteger)depth;


<br/>
Match subviews against a Class object
-
Collect all subviews of `self` that are of class `aClass`:
    
    -(NSArray*)subviewsMatchingClass:(Class)aClass;
    
Collect all subviews of `self` **(traversed to a maximum `depth`)**  of class `aClass`:
    
    -(NSArray*)subviewsMatchingClass:(Class)aClass
                            maxDepth:(NSInteger)depth;

Collect all subviews of `self` that are subclasses, or members of class `aClass`:
    
    -(NSArray*)subviewsMatchingClassOrSubclass:(Class)aClass;

Collect all subviews of `self` **(traversed to a maximum `depth`)** that are subclasses, or members of class `aClass`:
    
    -(NSArray*)subviewsMatchingClassOrSubclass:(Class)aClass
                                      maxDepth:(NSInteger)depth;


