//
//  HeavyTaskThread.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/29.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "HeavyTaskThread.h"
#import "RunLoopSource.h"

void runLoopObserverCallBack (CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

@interface HeavyTaskThread()<RunLoopSourceDelegate>

@property (strong, nonatomic) RunLoopSource *source;

@end

@implementation HeavyTaskThread

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)main {
    self.source = [[RunLoopSource alloc] init];
    [self.source addToCurrentRunLoop];
    self.source.delegate = self;
    
    [self configureRunLoopObserver];
    
    [[NSRunLoop currentRunLoop] run];
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

- (void)receiveDataFromOtherThread:(NSData *)data {
    NSLog(@"i get the data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //  then do something
}

@end
