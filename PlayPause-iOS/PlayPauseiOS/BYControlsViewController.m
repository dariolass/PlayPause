//
//  BYControlsViewController.m
//  PlayPauseiOS
//
//  Created by Dario Lass on 16.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYControlsViewController.h"
#import "BYNetworkClient.h"

@interface BYControlsViewController ()

@property (nonatomic, strong) BYNetworkClient   *networkClient;
@property (nonatomic, strong) UIButton          *sendButton;

- (void)buttonPressed:(UIButton*)sender;

- (IBAction)playpauseButtonPressed;
- (IBAction)backButtonPressed;
- (IBAction)forwardButtonPressed;
- (IBAction)muteButtonPressed;
- (IBAction)volumeUpButtonPressed;
- (IBAction)volumeDownButtonPressed;

@end

@implementation BYControlsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.networkClient = [[BYNetworkClient alloc]init];
        [self.networkClient startClient];
        
    }
    return self;
}


- (void)buttonPressed:(UIButton *)sender
{
    [self.networkClient sendData:[@"Hey there!" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (IBAction)playpauseButtonPressed
{
    [self.networkClient sendData:[@"playpause" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (IBAction)backButtonPressed
{
    [self.networkClient sendData:[@"back" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (IBAction)forwardButtonPressed
{
    [self.networkClient sendData:[@"forward" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (IBAction)muteButtonPressed
{
    [self.networkClient sendData:[@"mute" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (IBAction)volumeUpButtonPressed
{
    [self.networkClient sendData:[@"volumeUp" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (IBAction)volumeDownButtonPressed
{
    [self.networkClient sendData:[@"volumeDown" dataUsingEncoding:NSUTF8StringEncoding]];
}


@end
