//
//  TISensorTagHygrometerSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 8/2/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagSensor.h"

/// @description TISensorTagHygrometerSensor contains humidity and temperature information from the TI SensorTag's gyroscopic sensor.
@interface TISensorTagHygrometerSensor : TISensorTagSensor
{
	double_t	_humidity;
	double_t	_temperature;
}

/// @description Humidity in percent (0-100)
@property (readonly) double_t humidity;
/// @description Temperature in Celsius
@property (readonly) double_t temperature;

/// @returns Returns the TISensorTag Hygrometer Service UUID (F000AA20-0451-4000-B000-000000000000).
+ (CBUUID*)	serviceUUID;

/*!
 @description Initializes the hygrometer sensor with bluetooth service and device.
 @param service The CBService for the hygrometer sensor, probably found by comparing a discovered service's UUID to the serviceUUID.
 @param device The CBPeripheral for the bluetooth device
 @result An initialized TISensorTagHygrometerSensor.
 @note If you're using the TISensorTag class, you don't need to call this.  By setting <code>hygrometerActive</code> in the TISensorTag object, one of these will be created for you.
 */
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device;
- (void) dealloc;

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
