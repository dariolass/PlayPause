//
//  BYNetworkClient.h
//  PlayPauseiOS
//
//  Created by Dario Lass on 16.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYNetworkClient : NSObject

- (void)startClient;
- (void)stop;

- (void)sendData:(NSData*)data;

@end
