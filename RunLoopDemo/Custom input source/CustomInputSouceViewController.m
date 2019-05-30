//
//  CustomInputSouceViewController.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/29.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "CustomInputSouceViewController.h"
#import "AppDelegate.h"

@interface CustomInputSouceViewController ()

@end

@implementation CustomInputSouceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)subThreadDoHeavyThing:(id)sender {
    
    [(AppDelegate *)UIApplication.sharedApplication.delegate makeSubThreadDownloadImg:@"http://pic37.nipic.com/20140110/17563091_221827492154_2.jpg"];
}

@end
