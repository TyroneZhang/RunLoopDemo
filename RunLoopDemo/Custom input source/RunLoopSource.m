//
//  RunLoopSource.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "RunLoopSource.h"
#import "AppDelegate.h"
#import "RunLoopContext.h"

@implementation RunLoopSource

- (instancetype)init {
    CFRunLoopSourceContext  context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
        RunLoopSourceScheduleRoutine,
        RunLoopSourceCancelRoutine,
        RunLoopSourcePerformRoutine};
    
    runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    commands = [NSMutableDictionary dictionaryWithCapacity:1];
    
    return self;
}

- (void)addToCurrentRunLoop {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}

// Client interface for regitering commands to process
- (void)addCommand:(NSInteger)command withData:(NSData *)data {
    NSLog(@"%s", __func__);
    @synchronized (commands) {
        commands[@(command)] = data;
    }
}

// Handler method
- (void)sourceFired {
    NSLog(@"%s", __func__);
    NSLog(@"current thread: %@\n handle the event", [NSThread currentThread]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(receiveDataFromOtherThread:)]) {
        [self.delegate receiveDataFromOtherThread:commands[@(1)]]; //这里拿key为1的数据，只是做测试，应该拿到对应的data才正确
    }
}

- (void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runloop {
    CFRunLoopSourceSignal(runLoopSource);
    CFRunLoopWakeUp(runloop);
}

- (void)invalidate {
    NSLog(@"%s", __func__);
    CFRunLoopSourceInvalidate(runLoopSource);
}

// These are the CFRunLoopSourceRef callback functions.

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode) {
    RunLoopSource *obj = (__bridge RunLoopSource *)info;
    RunLoopContext *context = [[RunLoopContext alloc] initWithSource:obj loop:rl];
    [(AppDelegate *)UIApplication.sharedApplication.delegate performSelectorOnMainThread:@selector(registerSource:) withObject:context waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine (void *info) {
    RunLoopSource *obj = (__bridge RunLoopSource*)info;
    [obj sourceFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode) {
    RunLoopSource *obj = (__bridge RunLoopSource*)info;
    RunLoopContext *context = [[RunLoopContext alloc] initWithSource:obj loop:rl];
    [(AppDelegate *)UIApplication.sharedApplication.delegate performSelectorOnMainThread:@selector(removeSource:) withObject:context waitUntilDone:NO];
}

@end
