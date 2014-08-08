//
//  BYControlsViewController.m
//  PlayPauseiOS
//
//  Created by Dario Lass on 16.06.14.
//  Copyright (c) 2014 Bytolution. All rights reserved.
//

#import "BYControlsViewController.h"
#import "BYNetworkClient.h"

@interface BYControlsViewController () <UITableViewDataSource, UITableViewDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate, BYNetworkClientProtocol>

@property (nonatomic, strong)			BYNetworkClient		*networkClient;
@property (nonatomic, strong) IBOutlet	UITableView			*tableView;
@property (nonatomic, strong)			NSMutableArray		*availibleNetServices;
@property (nonatomic, strong)			NSNetServiceBrowser	*netServiceBrowser;
@property (nonatomic, strong)			NSNetService		*activeNetService;

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
		self.networkClient.delegate = self;
        [self.networkClient startClient];
		if (!self.availibleNetServices) self.availibleNetServices = [NSMutableArray new];
		self.netServiceBrowser = [[NSNetServiceBrowser alloc]init];
        self.netServiceBrowser.delegate = self;
		[self.netServiceBrowser searchForServicesOfType:@"_playpause._tcp." inDomain:@"local"];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	if (![self.availibleNetServices containsObject:aNetService]) [self.availibleNetServices addObject:aNetService];
	aNetService.delegate = self;
//	[aNetService resolveWithTimeout:5];
	if (!moreComing) [self.tableView reloadData];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSDictionary *TXTRecordDataDict = [NSNetService dictionaryFromTXTRecordData:sender.TXTRecordData];
	NSLog(@"%@", [[NSString alloc] initWithData:[TXTRecordDataDict objectForKey:@"HostName"] encoding:NSUTF8StringEncoding]);
	NSLog(@"%@", sender.name);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	if ([self.availibleNetServices containsObject:aNetService]) [self.availibleNetServices removeObject:aNetService];
	if (!moreComing) [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.availibleNetServices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL_ID"];
	if (!cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL_ID"];
	}
	cell.textLabel.text = [(NSNetService*)self.availibleNetServices[indexPath.row] name];
	if ([(NSNetService*)self.availibleNetServices[indexPath.row] isEqual:self.activeNetService]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.activeNetService = self.availibleNetServices[indexPath.row];
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)networkClient:(BYNetworkClient *)networkClient didEstablishStreamToNetService:(NSNetService *)netService
{
	self.view.backgroundColor = [UIColor colorWithRed:0.64 green:0.99 blue:0.66 alpha:1];
}

- (void)networkClientDidSendData:(BYNetworkClient *)networkClient
{
	[UIView animateWithDuration:0.1 animations:^{
		self.view.backgroundColor = [UIColor colorWithRed:0.47 green:0.97 blue:0.5 alpha:1];
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.1 animations:^{
			self.view.backgroundColor = [UIColor colorWithRed:0.64 green:0.99 blue:0.66 alpha:1];
		}];
	}];
}

- (void)networkClientConnectionDidFail:(BYNetworkClient *)networkClient
{
	[UIView animateWithDuration:0.1 animations:^{
		self.view.backgroundColor = [UIColor colorWithRed:0.99 green:0.69 blue:0.71 alpha:1];
	}];
}

- (IBAction)playpauseButtonPressed
{
    [self.networkClient sendData:[@"playpause" dataUsingEncoding:NSUTF8StringEncoding] toNetService:self.activeNetService];
}
- (IBAction)backButtonPressed
{
    [self.networkClient sendData:[@"back" dataUsingEncoding:NSUTF8StringEncoding] toNetService:self.activeNetService];
}
- (IBAction)forwardButtonPressed
{
    [self.networkClient sendData:[@"forward" dataUsingEncoding:NSUTF8StringEncoding] toNetService:self.activeNetService];
}
- (IBAction)muteButtonPressed
{
    [self.networkClient sendData:[@"mute" dataUsingEncoding:NSUTF8StringEncoding] toNetService:self.activeNetService];
}
- (IBAction)volumeUpButtonPressed
{
    [self.networkClient sendData:[@"volumeUp" dataUsingEncoding:NSUTF8StringEncoding] toNetService:self.activeNetService];
}
- (IBAction)volumeDownButtonPressed
{
    [self.networkClient sendData:[@"volumeDown" dataUsingEncoding:NSUTF8StringEncoding] toNetService:self.activeNetService];
}


@end
