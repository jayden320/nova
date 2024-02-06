//
//  VCProfilerAdapter.h
//  Nova
//
//  Created by Jayden Liu on 2022/7/22.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VCProfilerDelegate <NSObject>

- (void)trackViewDidLoad:(UIViewController *)viewController;
- (void)trackViewWillAppear:(UIViewController *)viewController;
- (void)trackViewDidAppear:(UIViewController *)viewController;

@end


@interface VCProfilerAdapter : NSObject

@property (nonatomic, weak) id<VCProfilerDelegate> delegate;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
