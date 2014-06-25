//
//  BYKeypressEmulator.m
//  PlayPause
//
//  Created by Dario Lass on 10.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYKeypressEmulator.h"
#import "BYServer.h"
#import <IOKit/hidsystem/IOHIDLib.h>
#import <IOKit/hidsystem/ev_keymap.h>

@interface BYKeypressEmulator () <BYServerDelegate>

@property (nonatomic, strong) BYServer *recievingServer;

@end

@implementation BYKeypressEmulator

- (id)init
{
    self = [super init];
    if (self) {
        self.recievingServer = [[BYServer alloc]init];
        [self.recievingServer startServer];
        self.recievingServer.delegate = self;
    }
    return self;
}

static io_connect_t get_event_driver(void)
{
    static  mach_port_t sEventDrvrRef = 0;
    mach_port_t masterPort, service, iter;
    kern_return_t    kr;
    
    if (!sEventDrvrRef)
    {
        // Get master device port
        kr = IOMasterPort( bootstrap_port, &masterPort );
        
        kr = IOServiceGetMatchingServices( masterPort, IOServiceMatching( kIOHIDSystemClass ), &iter );
        
        service = IOIteratorNext( iter );
        
        kr = IOServiceOpen( service, mach_task_self(),
                           kIOHIDParamConnectType, &sEventDrvrRef );
        
        IOObjectRelease( service );
        IOObjectRelease( iter );
    }
    return sEventDrvrRef;
}


static void HIDPostAuxKey( const UInt8 auxKeyCode )
{
    NXEventData   event;
    kern_return_t kr;
    IOGPoint      loc = { 0, 0 };
    
    UInt32      evtInfo = auxKeyCode << 16 | NX_KEYDOWN << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
    
    evtInfo = auxKeyCode << 16 | NX_KEYUP << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
}

- (void)server:(BYServer *)server didRecieveMessage:(NSString *)message
{
    if ([message isEqualToString:@"playpause"]) {
        HIDPostAuxKey(NX_KEYTYPE_PLAY);
    } else if ([message isEqualToString:@"back"]) {
        HIDPostAuxKey(NX_KEYTYPE_REWIND);
    } else if ([message isEqualToString:@"forward"]) {
        HIDPostAuxKey(NX_KEYTYPE_FAST);
    } else if ([message isEqualToString:@"mute"]) {
        HIDPostAuxKey(NX_KEYTYPE_MUTE);
    } else if ([message isEqualToString:@"volumeDown"]) {
        HIDPostAuxKey(NX_KEYTYPE_SOUND_DOWN);
    } else if ([message isEqualToString:@"volumeUp"]) {
        HIDPostAuxKey(NX_KEYTYPE_SOUND_UP);
    }
}

- (void)dealloc
{
    self.recievingServer = nil;
}

@end
