//
//  MLeakAdapter.m
//  DoraemonLite
//
//  Created by Jayden Liu on 2022/7/14.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

#import "MLeakAdapter.h"
#import "UIApplication+MemoryLeak.h"
#import "UINavigationController+MemoryLeak.h"
#import "UITouch+MemoryLeak.h"
#import "UIViewController+MemoryLeak.h"
#import "UIWindow+MemoryLeak.h"

@implementation MLeakAdapter

+ (MLeakAdapter *)sharedInstance {
    static dispatch_once_t once;
    static MLeakAdapter *instance;
    dispatch_once(&once, ^{
        instance = [[MLeakAdapter alloc] init];
    });
    return instance;
}

- (void)hookForMemoryLeakDetectionIfNeeded {
    [UIApplication nova_hookForMemoryLeakDetection];
    [UINavigationController nova_hookForMemoryLeakDetection];
    [UITouch nova_hookForMemoryLeakDetection];
    [UIViewController nova_hookForMemoryLeakDetection];
    [UIWindow nova_hookForMemoryLeakDetection];
}

- (void)reportMemoryLeak:(MLeakedObjectProxy *)proxy {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(onMemoryLeak:)]) {
        [_delegate onMemoryLeak:proxy];
    }
}

@end
