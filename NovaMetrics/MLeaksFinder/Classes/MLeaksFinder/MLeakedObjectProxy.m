//
//  MLeakedObjectProxy.m
//  MLeaksFinder
//
//  Created by 佘泽坡 on 7/15/16.
//  Copyright © 2016 zeposhe. All rights reserved.
//

#import "MLeakedObjectProxy.h"
#import "MLeaksFinder.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "DoraemonMemoryLeakData.h"
#import "MLeakAdapter.h"

static NSMutableSet *leakedObjectPtrs;

@interface MLeakedObjectProxy ()
@property (nonatomic, weak) id object;
@end

@implementation MLeakedObjectProxy

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leakedObjectPtrs = [[NSMutableSet alloc] init];
    });
    
    if (!ptrs.count) {
        return NO;
    }
    if ([leakedObjectPtrs intersectsSet:ptrs]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)addLeakedObject:(id)object {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    MLeakedObjectProxy *proxy = [[MLeakedObjectProxy alloc] init];
    proxy.object = object;
    proxy.objectPtr = @((uintptr_t)object);
    proxy.viewStack = [object viewStack];
    static const void *const kLeakedObjectProxyKey = &kLeakedObjectProxyKey;
    objc_setAssociatedObject(object, kLeakedObjectProxyKey, proxy, OBJC_ASSOCIATION_RETAIN);
    
    [leakedObjectPtrs addObject:proxy.objectPtr];
    [[DoraemonMemoryLeakData shareInstance] addObject:object];
    
    [[MLeakAdapter sharedInstance] reportMemoryLeak:proxy];
}

- (void)dealloc {
    NSNumber *objectPtr = _objectPtr;
//    NSArray *viewStack = _viewStack;
    dispatch_async(dispatch_get_main_queue(), ^{
        [leakedObjectPtrs removeObject:objectPtr];
        [[DoraemonMemoryLeakData shareInstance] removeObjectPtr:objectPtr];
//        [DoraemonAlertUtil handleAlertActionWithVC:[UIViewController rootViewControllerForKeyWindow] title:@"Object Deallocated" text:[NSString stringWithFormat:@"%@", viewStack] ok:@"OK" okBlock:^{
//            
//        }];
    });
}

@end
