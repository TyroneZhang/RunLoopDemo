//
//  RunLoopContext.h
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RunLoopSource;

NS_ASSUME_NONNULL_BEGIN

/**
 RunLoopContext is a container object used during registration of the input source.
 */
@interface RunLoopContext : NSObject

@property (readonly) CFRunLoopRef runLoop;
@property (readonly) RunLoopSource* source;

- (instancetype)initWithSource:(RunLoopSource*)src loop:(CFRunLoopRef)loop;

@end

NS_ASSUME_NONNULL_END
