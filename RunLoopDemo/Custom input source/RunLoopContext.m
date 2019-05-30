//
//  RunLoopContext.m
//  RunLoopDemo
//
//  Created by Demon_Yao on 2019/5/28.
//  Copyright © 2019 Tyrone Zhang. All rights reserved.
//

#import "RunLoopContext.h"

@implementation RunLoopContext

- (instancetype)initWithSource:(RunLoopSource *)src loop:(CFRunLoopRef)loop {
    if (self = [super init]) {
        _runLoop = loop;
        _source = src;
    }
    return self;
}

@end
