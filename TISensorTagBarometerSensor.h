//
//  TISensorTagBarometerSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 7/14/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagDevice/TISensorTagSensor.h"

typedef struct BarometerCalibrationCoefficients
{
	uint16_t	c1;
	uint16_t	c2;
	uint16_t	c3;
	uint16_t	c4;
	int16_t		c5;
	int16_t		c6;
	int16_t		c7;
	int16_t		c8;
} BarometerCalibrationCoefficients;

/// @description TISensorTagBarometerSensor contains barometer and temperature data from the TI SensorTag's barometric sensor.
@interface TISensorTagBarometerSensor : TISensorTagSensor
{
	double_t	_pressure;
	double_t	_temperature;
	
@protected
	BarometerCalibrationCoefficients	calCoefs;
}

/// @description Barometric pressure in Pascals
@property (readonly) double_t pressure;
/// @description Temperature in Celsius
@property (readonly) double_t temperature;

/// @returns Returns the TISensorTag Barometer Service UUID (F000AA40-0451-4000-B000-000000000000).
+ (CBUUID*)	serviceUUID;

/*!
 @description Initializes the barometric sensor with bluetooth service and device.
 @param service The CBService for the barometric sensor, probably found by comparing a discovered service's UUID to the serviceUUID.
 @param device The CBPeripheral for the bluetooth device
 @result An initialized TISensorTagAccelerometerSensor.
 @note If you're using the TISensorTag class, you don't need to call this.  By setting <code>barometerActive</code> in the TISensorTag object, one of these will be created for you.
 */
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device;
- (void) dealloc;

- (int) pressureAltitude;

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
