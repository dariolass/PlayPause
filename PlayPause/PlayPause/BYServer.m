//
//  BYServer.m
//  PlayPause
//
//  Created by Dario Lass on 12.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYServer.h"
#import <sys/socket.h>
#import <netinet/in.h>

@interface BYServer () <NSNetServiceDelegate, NSStreamDelegate> {
    CFSocketRef _netSocket;
    NSMutableData *_data;
    NSMutableArray *_streamArray;
    NSNumber *bytesRead;
}

@property (nonatomic, strong) NSNetService *representingNetService;
@property (nonatomic, strong) NSStream *inputStream;

- (void)_acceptConnection:(int)fd;
- (void)didReceiveData:(NSData *)data fromStream:(NSStream *)theStream;

@end

@implementation BYServer

- (void)startServer {
    struct sockaddr_in addr;
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    int port = 0;
    
    memset(&addr, 0, sizeof(addr));
    
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = 0;
    addr.sin_addr.s_addr = INADDR_ANY;
    
    bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
    listen(fd, 5);
    
    socklen_t addrLen = sizeof(addr);
    
    getsockname(fd, (struct sockaddr *)&addr, &addrLen);
    
    port = ntohs(addr.sin_port);
    CFSocketContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    
    _netSocket = CFSocketCreateWithNative(NULL,
                                          fd,
                                          kCFSocketAcceptCallBack,
                                          AcceptCallback,
                                          &context);
    CFRelease(_netSocket);
    
    fd = -1;
    NSLog(@"port: %d", port);
    
    CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(NULL, _netSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    
    self.representingNetService = [[NSNetService alloc] initWithDomain:@""
                                                                  type:@"_playpause._tcp."
                                                                  name:[[NSHost currentHost] localizedName]
                                                                  port:port];
    [self.representingNetService setDelegate:self];
    NSDictionary *TXTDict = @{@"HostName": [[NSHost currentHost] localizedName]};
    [self.representingNetService setTXTRecordData:[NSNetService dataFromTXTRecordDictionary:TXTDict]];
    [self.representingNetService publish];
}

static void AcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    BYServer *obj = (__bridge BYServer *)info;
    [obj _acceptConnection:*(int *)data];
    //    NSLog(@"Callback of socket");
}

- (void)_acceptConnection:(int)fd {
    CFReadStreamRef readStream;
    
    CFStreamCreatePairWithSocket(NULL, fd, &readStream, NULL);
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    
    [self.inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [self.inputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    
    CFRelease(readStream);
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
        {
            if(!_data) {
                _data = [NSMutableData data];
            }
            NSInteger bufferSize = 512;
            uint8_t buffer[bufferSize];
            NSInteger len = 0;
            len = [(NSInputStream *)theStream read:buffer maxLength:bufferSize];
//            NSLog(@"len: %li", len);
            if(len) {
                [_data appendBytes:(const void *)buffer length:len];
                // bytesRead is an instance variable of type NSNumber.
                bytesRead = [NSNumber numberWithLong:[bytesRead intValue]+len];
                // NSLog(@"len: %li bytesRead: %li", (long)len, [bytesRead longValue]);
            } else if (len == 0){
                [self didReceiveData:_data fromStream:theStream];
            }
            break;
        }
        case NSStreamEventErrorOccurred:
            NSLog(@"An error has occurred on the stream.");
            break;
            
        case NSStreamEventEndEncountered:
            [self stopServer];
            break;
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
        default:
            break;
    }
}

- (void)stopServer {
    [self.inputStream setDelegate:nil];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream close];
    
//    if (self.representingNetService) {
//        [self.representingNetService stop];
//        self.representingNetService = nil;
//    }
//    
//    if (_netSocket != NULL) {
//        CFSocketInvalidate(_netSocket);
//        _netSocket = NULL;
//    }
}

#pragma mark NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"NSNetService PUBLISHED, Server started");
}

#pragma mark RECIEVE & SUBMIT

- (void)didReceiveData:(NSData *)data fromStream:(NSStream *)theStream
{
//    NSLog(@"Data Recieved! (%lu bytes read)", (unsigned long)data.length);
//    NSLog(@"%@", [[NSImage alloc]initWithData:_data].description);
    NSLog(@"Message: %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    [self.delegate server:self didRecieveMessage:[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    //don't forget
    data = nil;
    _data = nil;
}


@end
