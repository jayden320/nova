//
//  VCProfilerAdapter.m
//  Nova
//
//  Created by Jayden Liu on 2022/7/22.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

#import "VCProfilerAdapter.h"

@implementation VCProfilerAdapter

+ (instancetype)shared {
    static id __sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] init];
    });
    return __sharedInstance;
}

@end
