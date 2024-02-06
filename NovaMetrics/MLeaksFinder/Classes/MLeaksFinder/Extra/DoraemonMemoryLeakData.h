//
//  DoraemonMemoryLeakData.h
//  DoraemonKit
//
//  Created by didi on 2019/10/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DoraemonLeakManagerBlock)(NSDictionary *leakInfo);

@interface DoraemonMemoryLeakData : NSObject

+ (DoraemonMemoryLeakData *)shareInstance;

- (void)addObject:(id)object;

- (void)removeObjectPtr:(NSNumber *)objectPtr;

@end

NS_ASSUME_NONNULL_END
