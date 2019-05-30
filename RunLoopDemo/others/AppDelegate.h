//
//  AppDelegate.h
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RunLoopContext;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)registerSource:(RunLoopContext *)sourceInfo;

- (void)removeSource:(RunLoopContext *)sourceInfo;

- (void)makeSubThreadDownloadImg:(NSString *)imgPath;


@end

