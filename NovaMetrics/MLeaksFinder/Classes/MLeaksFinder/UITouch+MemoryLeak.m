//
//  UITouch+MemoryLeak.m
//  MLeaksFinder
//
//  Created by 佘泽坡 on 8/31/16.
//  Copyright © 2016 zeposhe. All rights reserved.
//

#import "UITouch+MemoryLeak.h"
#import <objc/runtime.h>

#if _INTERNAL_MLF_ENABLED

extern const void *const kLatestSenderKey;

@implementation UITouch (MemoryLeak)

+ (void)nova_hookForMemoryLeakDetection {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(setView:) withSEL:@selector(mlf_setView:)];
    });
}

- (void)mlf_setView:(UIView *)view {
    [self mlf_setView:view];
    
    if (view) {
        objc_setAssociatedObject([UIApplication sharedApplication],
                                 kLatestSenderKey,
                                 @((uintptr_t)view),
                                 OBJC_ASSOCIATION_RETAIN);
    }
}

@end

#endif
