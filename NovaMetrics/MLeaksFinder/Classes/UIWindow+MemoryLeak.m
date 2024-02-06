//
//  UIWindow+MemoryLeak.m
//  Nova
//
//  Created by Jayden Liu on 2023/3/24.
//  Copyright © 2023 Jayden Liu. All rights reserved.
//

#import "UIWindow+MemoryLeak.h"
#import "NSObject+MemoryLeak.h"

@implementation UIWindow (MemoryLeak)

+ (void)nova_hookForMemoryLeakDetection {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(setRootViewController:) withSEL:@selector(mlf_setRootViewController:)];
    });
}

- (void)mlf_setRootViewController:(UIViewController *)rootViewController {
    [self.rootViewController willDealloc];
    [self mlf_setRootViewController:rootViewController];
}

@end
