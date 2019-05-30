//
//  MyWorkerClass.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/29.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "MyWorkerClass.h"

#define kCheckinMessage 100

@interface MyWorkerClass()<NSPortDelegate>

@end

@implementation MyWorkerClass

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (void)LaunchThreadWithPort:(id)inData {
    NSPort* distantPort = (NSPort *)inData;
    
    MyWorkerClass*  workerObj = [[self alloc] init];
    workerObj.shouldExit = NO;
    [workerObj sendCheckinMessage:distantPort];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    while (!workerObj.shouldExit);
    
    NSLog(@"will release");
}

- (void)sendCheckinMessage:(NSPort*)outPort {
    NSPort *remotePort = outPort;
    NSPort *myPort = [NSMachPort port];
    myPort.delegate = self;
    [[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];
    
    [remotePort sendBeforeDate:[NSDate date] msgid:kCheckinMessage components:nil from:myPort reserved:0];
}

- (void)handlePortMessage:(id)message {
    id msgId = [message valueForKey: @"msgid"];
    if ([msgId intValue] == kCheckinMessage) {
        NSMutableArray *components = [message valueForKey:@"components"];
        NSString *msg = [[NSString alloc] initWithData:components.firstObject encoding:NSUTF8StringEncoding];
        if ([msg isEqualToString:@"0"]) {
            self.shouldExit = YES;
            NSPort *localPort = [message valueForKey:@"localPort"];
            [[NSRunLoop currentRunLoop] removePort:localPort forMode:NSDefaultRunLoopMode];
        }
        NSLog(@"\n****************************\n%@\n%@\n****************************", [NSThread currentThread], msg);
    } else {
        // Handle other messages.
    }
    
}

@end
