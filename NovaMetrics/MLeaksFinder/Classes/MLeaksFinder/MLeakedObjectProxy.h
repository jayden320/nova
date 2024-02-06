//
//  MLeakedObjectProxy.h
//  MLeaksFinder
//
//  Created by 佘泽坡 on 7/15/16.
//  Copyright © 2016 zeposhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLeakedObjectProxy : NSObject

@property (nonatomic, strong) NSNumber *objectPtr;
@property (nonatomic, strong) NSArray *viewStack;

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs;
+ (void)addLeakedObject:(id)object;

@end
