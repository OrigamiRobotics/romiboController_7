//
//  ConnectionManager.m
//  ProximityApp
//
//  Copyright (c) 2012 Nordic Semiconductor. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager {
    CBCentralManager *cm;
}
@synthesize delegate = _delegate;

static ConnectionManager *sharedConnectionManager;

+ (ConnectionManager*) sharedInstance
{
    if (sharedConnectionManager == nil)
    {
        sharedConnectionManager = [[ConnectionManager alloc] initWithDelegate:nil];
    }
    return sharedConnectionManager;
}

- (ConnectionManager*) initWithDelegate:(id<ConnectionManagerDelegate>) delegate
{
    if (self = [super init])
    {
        _delegate = delegate;
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @YES};
        cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        
    }
    return self;
}

NSString * romibo_service_ID               = @"AE1E0001-9459-11E3-BAA8-0800200C9A66";
NSString * romibo_characteristic_Write_ID  = @"AE1E0002-9459-11E3-BAA8-0800200C9A66";
NSString * romibo_characteristic_Notify_ID = @"AE1E0003-9459-11E3-BAA8-0800200C9A66";

- (void) retrieveKnownPeripherals
{
    NSMutableArray *uuidArray = [[NSMutableArray alloc] init];
    [uuidArray addObject:(id) romibo_service_ID];

    NSLog(@"Trying to retrieve %ld peripherals: %@", (unsigned long)[uuidArray count], uuidArray);
    NSArray *retrievedPeripherals = [cm retrievePeripheralsWithIdentifiers:uuidArray];
    
    NSLog(@"retrieveKnownPeripherals returned: %@", retrievedPeripherals);
    
}


- (void) startScanForTags
{
    NSDictionary * scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
    NSArray * serviceArray = @[ProximityTag.romiboServiceUUID];

    // Make sure we start scan from scratch
    [cm stopScan];
    
    [cm scanForPeripheralsWithServices:serviceArray options:scanOptions];
}

- (void) stopScanForTags
{
    [cm stopScan];
}

- (void) connectToTag:(ProximityTag*) tag
{
    NSDictionary* connectOptions = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES};
    
    NSLog(@"Connecting to tag %@...", [tag name]);
    [cm connectPeripheral:[tag peripheral] options:connectOptions];
}

- (void) disconnectTag:(ProximityTag*) tag
{
    if (tag.peripheral)
    {
        NSLog(@"Disconnecting from tag %@...", [tag name]);
        [cm cancelPeripheralConnection:[tag peripheral]];
    }
    else 
    {
        NSLog(@"Not disconnecting from tag %@, since it appears to not be connected.", [tag name]);
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([central state] == CBCentralManagerStatePoweredOn)
    {
        [_delegate isBluetoothEnabled:YES];        
        NSLog(@"Central manager did update state.  Bluetooth Enabled: YES");
        
        [self retrieveKnownPeripherals];
    }
    else 
    {
        NSLog(@"Central manager did update state.  Bluetooth Enabled: NO");
       [_delegate isBluetoothEnabled:NO];
    }
}

- (void) centralManager:(CBCentralManager *)central
  didDiscoverPeripheral:(CBPeripheral *)peripheral
      advertisementData:(NSDictionary *)advertisementData
                   RSSI:(NSNumber *)RSSI
{
    // Abort if this device is already in the list
    // if([[ProximityTagStorage sharedInstance] tagWithUUID:[peripheral UUID]])
    //     return;
    
    NSLog(@"didDiscoverPeripheral: %@", peripheral);
    
    self.connectToTag = [[ProximityTag alloc] init];
    self.connectToTag.peripheral = peripheral;
    self.connectToTag.rssiLevel = [RSSI floatValue];
    
    // [[ProximityTagStorage sharedInstance] insertTag:tag];
    
    [self connectToTag:self.connectToTag];
    [self.delegate didDiscoverTag:self.connectToTag];
    
}

- (void) centralManager:(CBCentralManager *)central
 didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Did retrieve %lu peripherals.", (unsigned long)[peripherals count]);
}

- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", [peripheral name]);
    [self.connectToTag didConnect];
    
    self.connectedPeripheral = peripheral;
    
}

- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did disconnect peripheral, %@ with error %@. Trying to reconnect...", [peripheral name], error);
}


@end
