//
//  ObserverViewController.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "ObserverViewController.h"

@interface ObserverViewController ()

@end

@implementation ObserverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createObserver];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"");
}

- (void)createObserver {
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopObserverContext context = {
        0,
        NULL,
        NULL,
        NULL,
        NULL
    };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, cfRunLoopObserverCallBack, &context);
    
    if (observer)
    {
        CFRunLoopRef    cfLoop = [myRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
    
    NSInteger    loopCount = 10;
    do
    {
        // Run the run loop 10 times to let the timer fire.
        [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        loopCount--;
    }
    while (loopCount);
}

/*
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
     kCFRunLoopEntry = (1UL << 0),          // 1
     kCFRunLoopBeforeTimers = (1UL << 1),   // 2
     kCFRunLoopBeforeSources = (1UL << 2),  // 4
     kCFRunLoopBeforeWaiting = (1UL << 5),  // 32
     kCFRunLoopAfterWaiting = (1UL << 6),   // 64
     kCFRunLoopExit = (1UL << 7),           // 128
     kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 */
void cfRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    NSLog(@"runloop activity: %lu", activity);
}
- (void)timerCallback:(NSTimer *)timer {
    static int time = 0;
    if (time >= 3) {
        [timer invalidate];
    }
    NSLog(@"timer callback");
    time += 1;
}


@end
