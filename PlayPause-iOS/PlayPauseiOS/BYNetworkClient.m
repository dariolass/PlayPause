//
//  BYNetworkClient.m
//  PlayPauseiOS
//
//  Created by Dario Lass on 16.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYNetworkClient.h"

@interface BYNetworkClient () <NSStreamDelegate> {
    NSInteger byteIndex;
}

@property (nonatomic, strong)       NSNetService        *netService;
//@property (nonatomic, readwrite)    uint8_t             buffer;
@property (nonatomic, strong)       NSMutableData       *data;
@property (nonatomic, readwrite)    BOOL                ongoingTransmission;

- (void)closeStream;

@end

@implementation BYNetworkClient

- (void)startClient
{
    
}

- (void)sendData:(NSData *)data toNetService:(NSNetService *)netService
{
    NSOutputStream *outputStream;
    BOOL success = [netService getInputStream:NULL outputStream:&outputStream];
    if (!success) {
        if ([self.delegate respondsToSelector:@selector(networkClientConnectionDidFail:)]) [self.delegate networkClientConnectionDidFail:self];
    } else {
        if ([self.delegate respondsToSelector:@selector(networkClient:didEstablishStreamToNetService:)]) [self.delegate networkClient:self didEstablishStreamToNetService:netService];
    }
    if (self.ongoingTransmission) return;
    self.data = [data mutableCopy];
    outputStream.delegate = self;
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            self.ongoingTransmission = YES;
            NSInteger bufferSize = 1024;
            uint8_t *totalBytes = (uint8_t *)[_data bytes];
            totalBytes += byteIndex; // instance variable to move pointer
            NSInteger totalByteCount = [_data length];
//            NSLog(@"totalByteCount: %li", (unsigned long)totalByteCount);
            NSInteger len = ((totalByteCount - byteIndex >= bufferSize) ? bufferSize : (totalByteCount-byteIndex));
            uint8_t buf[len];
            (void)memcpy(buf, totalBytes, len);
            len = [(NSOutputStream*)aStream write:(const uint8_t *)buf maxLength:len];
//            NSLog(@"length of written byte chunk: %li", (unsigned long)len);
            byteIndex += len;
//            NSLog(@"byteIndex: %li", (unsigned long)byteIndex);
            break;
        }
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventEndEncountered:
            [aStream close];
            aStream.delegate = nil;
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            self.ongoingTransmission = NO;
            byteIndex = 0;
            self.data = nil;
            if ([self.delegate respondsToSelector:@selector(networkClientDidSendData:)]) [self.delegate networkClientDidSendData:self];
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventHasBytesAvailable:
            assert(NO); //Mustn't happen on an output stream
            break;
        default:
            break;
    }
}

- (void)closeStream
{
    
}

- (void)stop
{
    return;
}

@end
