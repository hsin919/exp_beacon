//
//  ViewController.m
//  Beacon
//
//  Created by Christopher Ching on 2013-11-28.
//  Copyright (c) 2013 AppCoda. All rights reserved.
//

#import "ViewController.h"

static NSString * const kUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
static NSString * const kServiceUUID = @"E28E86A2-45A2-4E39-B0F0-045446794698";
static NSString * const kCharacteristicUUID = @"4FBAF52F-925F-4958-86EF-68984BEFB5C7";

@interface ViewController ()

@property (nonatomic, strong) CBMutableCharacteristic *customCharacteristic;
@property (nonatomic, strong) CBMutableService *customService;
@property (nonatomic, strong) NSMutableArray *centralArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Create a NSUUID object
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kUUID];
    
    time_t t;
    srand((unsigned) time(&t));
    // Initialize the Beacon Region
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                  major:rand()
                                                                  minor:rand()
                                                             identifier:@"SomeIdentifier"];
    
    self.centralArray = [[NSMutableArray alloc] init];
    
    self.peripheralManager = nil;
}

- (void)setupService
{
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    [self.customService setCharacteristics:@[self.customCharacteristic]];
    [self.peripheralManager addService:self.customService];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonClicked:(id)sender {
    
    if(self.peripheralManager == nil)
    {
        // Get the beacon data to advertise
        self.myBeaconData = [self.myBeaconRegion peripheralDataWithMeasuredPower:nil];
        
        // Start the peripheral manager
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    }
    else
    {
        if([self.centralArray count]>0)
        {
            NSLog(@"Update value to %@", self.centralArray);
            [self.peripheralManager updateValue:nil forCharacteristic:self.customCharacteristic onSubscribedCentrals:self.centralArray];
        }
    }
    
}

#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
    if (error) {
        NSLog(@"Couldn't turn on advertising: %@", error);
        return;
    }
    
    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising.");
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        
        // Update our status label
        self.statusLabel.text = @"Broadcasting...";
        
        // Start broadcasting
        //[self.peripheralManager startAdvertising:self.myBeaconData];
        [self setupService];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        // Update our status label
        self.statusLabel.text = @"Stopped";
        
        // Bluetooth isn't on. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        self.statusLabel.text = @"Unsupported";
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
    if(error == nil)
    {
        NSLog(@"add service success");
        
        [self.peripheralManager startAdvertising:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"ICServer", CBAdvertisementDataLocalNameKey,
                                                  @[[CBUUID UUIDWithString:kServiceUUID]], CBAdvertisementDataServiceUUIDsKey,
                                                  nil]];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%s", __FUNCTION__);
    if(![self.centralArray containsObject:central])
    {
        [self.centralArray addObject:central];
    }
}

@end
