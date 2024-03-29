//
//  UIViewController+VCDetector.h
//  MTHawkeyeDemo
//
//  Created by 潘名扬 on 2018/6/4.
//  Copyright © 2018年 Punmy. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <UIKit/UIKit.h>


@interface MTHFakeKVOObserver : NSObject
@end


#pragma mark -

@interface MTHFakeKVORemover : NSObject

@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) NSString *className;

@end


#pragma mark -

@interface UIViewController (VCDetector)

+ (void)pmy_swizzleViewControllerLifecycle;

@end
