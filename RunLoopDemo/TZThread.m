//
//  TZThread.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "TZThread.h"

void runLoopObserverCallBack (CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch (activity)
    {
        case kCFRunLoopEntry:
            NSLog(@"RunLoop Entry...");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"RunLoop Before Timers...");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"RunLoop Before Sources...");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"RunLoop Before Waiting...");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"RunLoop After Waiting...");
            break;
        case kCFRunLoopExit:
            NSLog(@"RunLoop Exit...");
            break;
            
        default:
            break;
    }
}

@implementation TZThread

- (void)dealloc {
    NSLog(@"===== realease tzthread.");
}

- (void)main {
    [self configureRunLoopObserver];
}

- (void)configureRunLoopObserver {
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopObserverContext context = {0,(__bridge void *)(self) , NULL , NULL , NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(
                                                            kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    if (observer) {
        CFRunLoopAddObserver([currentRunLoop getCFRunLoop], observer, kCFRunLoopDefaultMode);
    }
}


@end
