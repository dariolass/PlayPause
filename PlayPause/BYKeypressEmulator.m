//
//  BYKeypressEmulator.m
//  PlayPause
//
//  Created by Dario Lass on 10.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYKeypressEmulator.h"
#import "BYServer.h"

@interface BYKeypressEmulator ()

@property (nonatomic, strong) BYServer *recievingServer;

@end

@implementation BYKeypressEmulator

- (id)init
{
    self = [super init];
    if (self) {
        self.recievingServer = [[BYServer alloc]init];
        [self.recievingServer startServer];
    }
    return self;
}

- (void)dealloc
{
    self.recievingServer = nil;
}

@end
