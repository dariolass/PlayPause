//
//  BYServer.h
//  PlayPause
//
//  Created by Dario Lass on 12.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BYServer;

@protocol BYServerDelegate <NSObject>

- (void)server:(BYServer*)server didRecieveMessage:(NSString*)message;

@end

@interface BYServer : NSObject

- (void)startServer;
- (void)stopServer;

@property (nonatomic, readwrite) id <BYServerDelegate> delegate;

@end
