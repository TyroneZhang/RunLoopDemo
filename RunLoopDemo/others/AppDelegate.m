//
//  AppDelegate.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "RunLoopContext.h"
#import "HeavyTaskThread.h"
#import "RunLoopSource.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSMutableArray* sourcesToPing;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self startAHeavyTaskThread];
    
    return YES;
}

/// 开启一个处理繁重任务的子线程
- (void)startAHeavyTaskThread {
    HeavyTaskThread *thread = [[HeavyTaskThread alloc] init];
    [thread start];
}

- (NSMutableArray *)sourcesToPing {
    if (!_sourcesToPing) {
        _sourcesToPing = [NSMutableArray arrayWithCapacity:1];
    }
    return _sourcesToPing;
}

- (void)registerSource:(RunLoopContext *)sourceInfo {
    if (!self.sourcesToPing) {
        self.sourcesToPing = [NSMutableArray arrayWithCapacity:1];
    }
    [self.sourcesToPing addObject:sourceInfo];
}

- (void)removeSource:(RunLoopContext *)sourceInfo {
    id objToRemove = nil;
    for(RunLoopContext* context in _sourcesToPing) {
        if ([context isEqual: sourceInfo]) {
            objToRemove = context;
            break;
        }
    }
    if (objToRemove) {
        [self.sourcesToPing removeObject:objToRemove];
    }
}

- (void)makeSubThreadDownloadImg:(NSString *)imgPath {
    RunLoopContext *context = self.sourcesToPing.firstObject;
    if (context) {
        [context.source addCommand:1 withData:[imgPath dataUsingEncoding:NSUTF8StringEncoding]];
        [context.source fireAllCommandsOnRunLoop:context.runLoop];
    }
}


@end
