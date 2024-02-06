//
//  UIWindow+MemoryLeak.h
//  Nova
//
//  Created by Jayden Liu on 2023/3/24.
//  Copyright © 2023 Jayden Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#if _INTERNAL_MLF_ENABLED

@interface UIWindow (MemoryLeak)

+ (void)nova_hookForMemoryLeakDetection;

@end

#endif
