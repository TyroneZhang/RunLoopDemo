//
//  MyWorkerClass.h
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/29.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyWorkerClass : NSObject

@property (nonatomic, assign) BOOL shouldExit;

+(void)LaunchThreadWithPort:(id)inData;

@end

NS_ASSUME_NONNULL_END
