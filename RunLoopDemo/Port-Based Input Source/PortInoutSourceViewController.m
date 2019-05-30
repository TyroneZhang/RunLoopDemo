//
//  PortInoutSourceViewController.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/29.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "PortInoutSourceViewController.h"
#import "MyWorkerClass.h"
#import <Foundation/NSPort.h>
#import "TZThread.h"

#define kCheckinMessage 100

@interface PortInoutSourceViewController ()<NSPortDelegate>

@property (nonatomic, strong) NSPort *localPort;
@property (nonatomic, strong) NSPort *remotePort;
@property (assign) int tag;

@end

@implementation PortInoutSourceViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tag = 0;
    [self launchThread];
}

- (void)launchThread {
    self.localPort = [NSMachPort port];
    if (self.localPort) {
        self.localPort.delegate = self;
        [[NSRunLoop currentRunLoop] addPort:self.localPort forMode:NSDefaultRunLoopMode];
        
        [TZThread detachNewThreadSelector:@selector(LaunchThreadWithPort:) toTarget:[MyWorkerClass class] withObject:self.localPort];
    }
}

- (IBAction)mainToSub:(id)sender {
    self.tag += 1;
    NSString *msg = [NSString stringWithFormat: @"%d: msg from main thread", self.tag];
    NSData *data =  [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *arr = [NSMutableArray arrayWithObject: data];
    [self.remotePort sendBeforeDate:[NSDate date] msgid:kCheckinMessage components:arr from:self.localPort reserved:0];
}

- (IBAction)subToMain:(id)sender {
    self.tag += 1;
    NSString *msg = [NSString stringWithFormat: @"%d: msg from sub thread", self.tag];
    NSData *data =  [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *arr = [NSMutableArray arrayWithObject: data];
    [self.localPort sendBeforeDate:[NSDate date] msgid:kCheckinMessage components:arr from:self.remotePort reserved:0];
}

- (IBAction)stopSub:(id)sender {
    self.tag += 1;
    NSData *data =  [@"0" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *arr = [NSMutableArray arrayWithObject: data];
    [self.remotePort sendBeforeDate:[NSDate date] msgid:kCheckinMessage components:arr from:self.localPort reserved:0];
    self.remotePort = nil;
}

#pragma mark - NSPortDelegate

/*
 @interface NSPortMessage : NSObject {
 @private
 NSPort         *localPort;
 NSPort         *remotePort;
 NSMutableArray     *components;
 uint32_t        msgid;
 void        *reserved2;
 void        *reserved;
 }
 */
- (void)handlePortMessage:(id)message {
    id msgId = [message valueForKey: @"msgid"];
    if ([msgId intValue] == kCheckinMessage) {
        // Get the worker thread’s communications port.
        self.remotePort = [message valueForKey:@"remotePort"];
        NSMutableArray *components = [message valueForKey:@"components"];
        NSString *msg = [[NSString alloc] initWithData:components.firstObject encoding:NSUTF8StringEncoding];
        NSLog(@"\n===============================\n%@\n%@\n===============================", [NSThread currentThread], msg);
    } else {
        // Handle other messages.
    }
    
}

@end
