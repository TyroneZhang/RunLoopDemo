//
//  RLModesViewController.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "RLModesViewController.h"

@interface RLModesViewController ()

@property(assign) NSInteger time;

@end

@implementation RLModesViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.time = 0;
//    [self runLoopModesInMainThread];
//    [self runLoopModesInSubthreadThatWithoutRunLoop];
//    [self runLoopModesInSubthread];
    [self timerInMainThread];
}

- (void)runLoopModesInMainThread {
    CFRunLoopRef rl = CFRunLoopGetMain();
    CFArrayRef modes = CFRunLoopCopyAllModes(rl);
    CFRunLoopMode currMode = CFRunLoopCopyCurrentMode(rl);
    NSLog(@"================== Main Thread =================");
    NSLog(@"currmode = %@", currMode);
    NSLog(@"all modes = %@", modes);
}


/**
 未开启子线程的runloop
 */
- (void)runLoopModesInSubthreadThatWithoutRunLoop {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"would never exute here.");
        }];
        CFRunLoopRef rl = CFRunLoopGetCurrent();
        CFArrayRef modes = CFRunLoopCopyAllModes(rl);
        CFRunLoopMode currMode = CFRunLoopCopyCurrentMode(rl);
        NSLog(@"================== Sub Thread 0==============");
        NSLog(@"currmode = %@", currMode);
        NSLog(@"all modes = %@", modes);
        NSLog(@"thread will end immediately.");
    }];
    [thread start];
}

/**
 1. scheduledTimerWithTimeInterval:方法默认将timer加入到了当前线程的default模式；
 2. 主线程中，滑动textView时，timer停止回调；
 3. 解决2.中问题有方案一、方案二。
 */
- (void)timerInMainThread {
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
       CFRunLoopRef rl = CFRunLoopGetCurrent();
       CFRunLoopMode currMode = CFRunLoopCopyCurrentMode(rl);
       NSLog(@"currmode = %@", currMode);
       self.time += 1;
       if (self.time > 10) {
           [timer invalidate];
       }
    }];
    // 解决方案一：
    [[NSRunLoop currentRunLoop] addTimer:timer forMode: UITrackingRunLoopMode];
}


/**
 解决方案二：
 将timer操作加入子线程
 */
- (void)runLoopModesInSubthread {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            CFRunLoopRef rl = CFRunLoopGetCurrent();
            CFArrayRef modes = CFRunLoopCopyAllModes(rl);
            CFRunLoopMode currMode = CFRunLoopCopyCurrentMode(rl);
            NSLog(@"================== Sub Thread 2==============");
            NSLog(@"currmode = %@", currMode);
            NSLog(@"all modes = %@", modes);
            self.time += 1;
            if (self.time > 10) {
                [timer invalidate];
            }
        }];
        CFRunLoopRun();
        NSLog(@"would never exute here.");
    }];
    [thread start];
}

@end
