//
//  TISensorTagButtonSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 8/22/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagSensor.h"

/// @description TISensorTagButtonSensor contains button state data for the TI SensorTag's buttons.
@interface TISensorTagButtonSensor : TISensorTagSensor

/// @description YES if button #1 is down, NO if it is up.
@property (readonly, assign) BOOL button1Down;
/// @description YES if button #2 is down, NO if it is up.
@property (readonly, assign) BOOL button2Down;

///@returns Returns the TISensorTag's' Simple Keys Service (FFE1)
+ (CBUUID*)	serviceUUID;

/*!
 @description Initializes the button sensor with bluetooth service and device.
 @param service The CBService for the simple keys service, probably found by comparing a discovered service's UUID to the serviceUUID.
 @param device The CBPeripheral for the bluetooth device
 @result An initialized TISensorTagButtonSensor.
 @note If you're using the TISensorTag class, you don't need to call this.  By setting <code>buttonsActive</code> in the TISensorTag object, one of these will be created for you.
 */
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device;

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
