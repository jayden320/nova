//
//  UIViewController+MemoryLeak.m
//  MLeaksFinder
//
//  Created by zeposhe on 12/12/15.
//  Copyright © 2015 zeposhe. All rights reserved.
//

#import "UIViewController+MemoryLeak.h"
#import "NSObject+MemoryLeak.h"
#import <objc/runtime.h>

#if _INTERNAL_MLF_ENABLED

const void *const kHasBeenPoppedKey = &kHasBeenPoppedKey;

@implementation UIViewController (MemoryLeak)

+ (void)nova_hookForMemoryLeakDetection {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(viewDidDisappear:) withSEL:@selector(mlf_viewDidDisappear:)];
        [self swizzleSEL:@selector(viewWillAppear:) withSEL:@selector(mlf_viewWillAppear:)];
        [self swizzleSEL:@selector(dismissViewControllerAnimated:completion:) withSEL:@selector(mlf_dismissViewControllerAnimated:completion:)];
    });
}

- (void)mlf_viewDidDisappear:(BOOL)animated {
    [self mlf_viewDidDisappear:animated];
    
    if ([objc_getAssociatedObject(self, kHasBeenPoppedKey) boolValue]) {
        [self willDealloc];
    }
}

- (void)mlf_viewWillAppear:(BOOL)animated {
    [self mlf_viewWillAppear:animated];
    
    objc_setAssociatedObject(self, kHasBeenPoppedKey, @(NO), OBJC_ASSOCIATION_RETAIN);
}

- (void)mlf_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self mlf_dismissViewControllerAnimated:flag completion:completion];
    
    UIViewController *dismissedViewController = self.presentedViewController;
    if (!dismissedViewController && self.presentingViewController) {
        dismissedViewController = self;
    }
    
    if (!dismissedViewController) return;
    
    objc_setAssociatedObject(dismissedViewController, kHasBeenPoppedKey, @(YES), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.childViewControllers];
    [self willReleaseChild:self.presentedViewController];
    
    if (self.isViewLoaded) {
        [self willReleaseChild:self.view];
    }
    
    return YES;
}

@end

#endif
