//
//  BYNetworkClient.h
//  PlayPauseiOS
//
//  Created by Dario Lass on 16.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYNetworkClient;

@protocol BYNetworkClientProtocol <NSObject>

- (void)networkClient:(BYNetworkClient*)networkClient didEstablishStreamToNetService:(NSNetService*)netService;
- (void)networkClientDidSendData:(BYNetworkClient*)networkClient;
- (void)networkClientConnectionDidFail:(BYNetworkClient*)networkClient;

@end

@interface BYNetworkClient : NSObject

- (void)startClient;
- (void)stop;

- (void)sendData:(NSData*)data toNetService:(NSNetService*)netService;

@property (nonatomic, readwrite) id <BYNetworkClientProtocol> delegate;

@end
