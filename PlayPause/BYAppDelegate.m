//
//  BYAppDelegate.m
//  PlayPause
//
//  Created by Dario Lass on 13.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYAppDelegate.h"
#import "BYKeypressEmulator.h"

@interface BYAppDelegate ()

@property (nonatomic, strong) BYKeypressEmulator *keypressEmulator;

@end

@implementation BYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.keypressEmulator = [BYKeypressEmulator new];
}

@end
