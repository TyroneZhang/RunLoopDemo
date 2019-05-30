//
//  RunLoopSource.h
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunLoopSourceDelegate <NSObject>

- (void)receiveDataFromOtherThread:(NSData * _Nullable)data;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RunLoopSource : NSObject
{
    CFRunLoopSourceRef runLoopSource;
    NSMutableDictionary *commands;
}

@property (weak, nonatomic) id<RunLoopSourceDelegate> delegate;

- (instancetype)init;
- (void)addToCurrentRunLoop;
- (void)invalidate;

// Client interface for regitering commands to process
- (void)addCommand:(NSInteger)command withData:(NSData *)data;
- (void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runloop;

@end

NS_ASSUME_NONNULL_END
