//
//  KeepThreadBusyViewController.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "KeepThreadBusyViewController.h"
#import "TZThread.h"

@interface KeepThreadBusyViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (assign) BOOL finished;

@end

@implementation KeepThreadBusyViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)threadWithoutRunLoop:(id)sender {
    TZThread *thread = [[TZThread alloc] initWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"Never excute here.");
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = @"thread will finished!";
        });
    }];
    [thread start];
}

- (IBAction)treadWithRunLoop:(id)sender {
    self.finished = NO;
    static NSInteger time = 0;
    TZThread *thread = [[TZThread alloc] initWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            time += 1;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = [NSString stringWithFormat:@"%@\n%ld", self.textView.text, (long)time];
            });
            if (self.finished) {
                [timer invalidate];//  [TZThread exit] would not release the timer, and the timer will lead to memeory leak.
            }
        }];
        NSLog(@"thread %@ would never finished!", [TZThread currentThread]);
        CFRunLoopRun();
    }];
    [thread start];
}

- (IBAction)stopRunLoop:(id)sender {
    self.finished = YES;
}

@end
