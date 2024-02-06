//
//  NSObject+MemoryLeak.h
//  MLeaksFinder
//
//  Created by zeposhe on 12/12/15.
//  Copyright © 2015 zeposhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MemoryLeak)

- (BOOL)willDealloc;

- (void)willReleaseChild:(id)child;
- (void)willReleaseChildren:(NSArray *)children;

- (NSArray *)viewStack;

+ (void)ml_addClassNamesToWhitelist:(NSArray *)classNames;

+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL;

@end
