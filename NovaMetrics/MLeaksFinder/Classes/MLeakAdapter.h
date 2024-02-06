//
//  MLeakAdapter.h
//  DoraemonLite
//
//  Created by Jayden Liu on 2022/7/14.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLeakedObjectProxy.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLeakReporterDelegate

- (void)onMemoryLeak:(MLeakedObjectProxy *)proxy;

@end

@interface MLeakAdapter : NSObject

+ (MLeakAdapter *)sharedInstance;

@property (nonatomic, weak) id delegate;

- (void)hookForMemoryLeakDetectionIfNeeded;
- (void)reportMemoryLeak:(MLeakedObjectProxy *)proxy;

@end

NS_ASSUME_NONNULL_END
