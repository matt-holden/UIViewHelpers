This is a growing collection of helper methods in a Category on `UIView`. Includes a collection of unit tests.  

As of now, every method in this category is dedicated to recursing subviews of a UIView and testing each against a condition.  

Say you wanted to find your application's "first responder."  Using the category method `firstSubviewPassingTest:`, you could easily iterate all your application's subviews to locate the first responder.


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


