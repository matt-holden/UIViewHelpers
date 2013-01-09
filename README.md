This is a growing collection of helper methods in a Category on UIView.

<br/>
Match subviews against a block
-
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



