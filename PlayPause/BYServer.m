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
    NSMutableArray *_streamArray;
}

@property (nonatomic, strong) NSNetService *representingNetService;

- (void)_acceptConnection:(int)fd;
- (void)_didReceiveData:(NSData *)data fromStream:(NSStream *)theStream;

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
                                                                  type:@"_coupled._tcp."
                                                                  name:[[NSHost currentHost] localizedName]
                                                                  port:port];
    [self.representingNetService setDelegate:self];
    
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
    
    NSInputStream *inputStream = (__bridge NSInputStream *)readStream;
    
    [inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [inputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
    if (!_streamArray) {
        _streamArray = [NSMutableArray arrayWithCapacity:1];
    }
    
    [_streamArray addObject:[NSArray arrayWithObject:inputStream]];
    
    CFRelease(readStream);
    //CFRelease(writeStream);
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    NSArray *array;
    
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"The stream has bytes to be read.");
            
            uint8_t buffer[100000];
            NSInteger bytesRead = [(NSInputStream *)theStream read:buffer maxLength:sizeof(buffer)];
            
            if (bytesRead > 0) {
                NSData *data = [NSData dataWithBytes:buffer length:bytesRead];
                [self _didReceiveData:data fromStream:theStream];
            }
            
            break;
        }
            
        case NSStreamEventErrorOccurred:
            NSLog(@"An error has occurred on the stream.");
            
            for (array in _streamArray) {
                if ([array containsObject:theStream]) {
                    for (id stream in array) {
                        [stream setDelegate:nil];
                        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                        [(NSStream *)stream close];
                    }
                }
            }
            
            [_streamArray removeObject:array];
            
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"The end of the stream has been reached.");
            
            for (array in _streamArray) {
                if ([array containsObject:theStream]) {
                    for (id stream in array) {
                        [stream setDelegate:nil];
                        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                        [(NSStream *)stream close];
                    }
                }
            }
            
            [_streamArray removeObject:array];
            
            break;
            
        default:
            break;
    }
}

- (void)stopServer {
    for (NSArray *array in _streamArray) {
        for (id stream in array) {
            [stream setDelegate:nil];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [(NSStream *)stream close];
        }
    }
    
    [_streamArray removeAllObjects];
    
    if (self.representingNetService) {
        [self.representingNetService stop];
        self.representingNetService = nil;
    }
    
    if (_netSocket != NULL) {
        CFSocketInvalidate(_netSocket);
        _netSocket = NULL;
    }
}

#pragma mark NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"PUBLISHED");
}

#pragma mark RECIEVE & SUBMIT

- (void)_didReceiveData:(NSData *)data fromStream:(NSStream *)theStream {
    //
    //this is were we gonna manage the recieved data
    //
}


@end
