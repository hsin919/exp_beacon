exp_beacon
==========

A beacon sample based on http://www.appcoda.com/ios7-programming-ibeacons-tutorial/

This sample shows how to create a periperal.
You can customize the beacon by changing the following lines.

````objective-c
static NSString * const kUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
static NSString * const kServiceUUID = @"E28E86A2-45A2-4E39-B0F0-045446794698";
static NSString * const kCharacteristicUUID = @"4FBAF52F-925F-4958-86EF-68984BEFB5C7";
static NSString * const serviceName = @"iPhone";
````

A beacon will be created by clicking the green button.
Message "Buy one iPhone6 Plus got one free !!!!" will be send if a central is connected to this sample app by clicking the green button again.

````objective-c
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
            NSString *str = @"Buy one iPhone6 Plus got one free !!!!";
            NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [self.peripheralManager updateValue:data forCharacteristic:self.customCharacteristic onSubscribedCentrals:self.centralArray];
        }
    }
    
}
````

The sample code of the central can be found [here](https://github.com/hsin919/ibeacon-swift-tutorial)
