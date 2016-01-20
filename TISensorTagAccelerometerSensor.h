//
//  TISensorTagAccelerometerSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 8/24/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagSensor.h"

/*!
 @description Contains acceleration data in G (i.e. 1G = 9.8 m/sec/sec) along the x, y, and z axes.
 @field x acceleration along the X-axis (i.e. side-to-side as the device faces you).
 @field y acceleration along the Y-axis (i.e. up-and-down as the device faces you).
 @field z acceleration along the Z-axis (i.e. forward and backward as the device faces you)
*/
struct AccelerationDataStruct
{
	double_t	x;
	double_t	y;
	double_t	z;
};

typedef struct AccelerationDataStruct AccelerationData;

/// @description TISensorTagAccelerometerSensor contains acceleration data from the sensor.
@interface TISensorTagAccelerometerSensor : TISensorTagSensor
{
	AccelerationData	acceleration;
}

/// @description Acceleration information along X, Y, and Z axes.
@property (readonly, assign) AccelerationData acceleration;
@property (readwrite, assign) uint8_t accuracy;

/// @returns Returns the TISensorTag Acceleration Service UUID, which is F000AA10-0451-4000-B000-000000000000
+ (CBUUID*)	serviceUUID;

/*!
 @description Initializes the accelerometer sensor with bluetooth service and device.
 @param service The CBService for the accelerometer sensor, probably found by comparing a discovered service's UUID to the serviceUUID.
 @param device The CBPeripheral for the bluetooth device
 @result An initialized TISensorTagAccelerometerSensor.
 @note If you're using the TISensorTag class, you don't need to call this.  By setting <code>accelerometerActive</code> in the TISensorTag object, one of these will be created for you.
*/
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device;

- (void) dealloc;

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
