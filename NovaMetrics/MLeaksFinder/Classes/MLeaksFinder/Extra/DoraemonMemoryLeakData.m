//
//  DoraemonMemoryLeakData.m
//  DoraemonKit
//
//  Created by didi on 2019/10/7.
//

#import "MLeaksFinder.h"
#import "DoraemonMemoryLeakData.h"

#define STRING_NOT_NULL(str) ((str==nil)?@"":str)

@interface DoraemonMemoryLeakData()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DoraemonMemoryLeakData

+ (DoraemonMemoryLeakData *)shareInstance{
    static dispatch_once_t once;
    static DoraemonMemoryLeakData *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonMemoryLeakData alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)addObject:(id)object{
    NSString *className = NSStringFromClass([object class]);
    NSNumber *classPtr = @((uintptr_t)object);
    NSArray *viewStack = [object viewStack];
    NSString *retainCycle = [self getRetainCycleByObject:object];
    
    NSDictionary *info = @{
        @"className":STRING_NOT_NULL(className),
        @"classPtr":STRING_NOT_NULL(classPtr),
        @"viewStack":STRING_NOT_NULL(viewStack),
        @"retainCycle":STRING_NOT_NULL(retainCycle)
    };
    [_dataArray addObject:info];
}

- (void)removeObjectPtr:(NSNumber *)objectPtr{
    for (NSInteger i=_dataArray.count-1; i == 0; i--) {
        NSDictionary *dic = _dataArray[i];
        if ([dic[@"classPtr"] isEqualToNumber:objectPtr]) {
            [_dataArray removeObjectAtIndex:i];
        }
    }
}

- (NSString *)getRetainCycleByObject:(id)object{
    NSString *result;
#if _INTERNAL_MLF_RC_ENABLED
    FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
    [detector addCandidate:object];
    NSSet *retainCycles = [detector findRetainCyclesWithMaxCycleLength:20];
    
    BOOL hasFound = NO;
    for (NSArray *retainCycle in retainCycles) {
        NSInteger index = 0;
        for (FBObjectiveCGraphElement *element in retainCycle) {
            if (element.object == object) {
                NSArray *shiftedRetainCycle = [self shiftArray:retainCycle toIndex:index];
                
                result = [NSString stringWithFormat:@"%@", shiftedRetainCycle];
                hasFound = YES;
                break;
            }
            
            ++index;
        }
        if (hasFound) {
            break;
        }
    }
    if (!hasFound) {
        result = @"Fail to find a retain cycle";
    }
#endif
    return result;
}

@end
