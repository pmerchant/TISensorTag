//
//  TISensorTagThermometerSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 8/2/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagSensor.h"

/// @description TISensorTagThermometerSensor contains temperature (ambient and infrared) information from the TI SensorTag's temperature sensor.
@interface TISensorTagThermometerSensor : TISensorTagSensor
{
@protected
	double_t	_infraredTemperature;
	double_t	_temperature;
}

/// @description Temperature in celsius from the infrared sensor
@property (readonly) double_t infraredTemperature;
/// @description Temperature in celsius from the ambient sensor
@property (readonly) double_t temperature;

/// @returns Returns the TISensorTag Temperature Service UUID (F000AA00-0451-4000-B000-000000000000).
+ (CBUUID*)	serviceUUID;

/*!
 @description Initializes the thermometer sensor with bluetooth service and device.
 @param service The CBService for the temperature sensor, probably found by comparing a discovered service's UUID to the serviceUUID.
 @param device The CBPeripheral for the bluetooth device
 @result An initialized TISensorTagThermometerSensor.
 @note If you're using the TISensorTag class, you don't need to call this.  By setting <code>thermometerActive</code> in the TISensorTag object, one of these will be created for you.
 */
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device;
- (void) dealloc;

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
