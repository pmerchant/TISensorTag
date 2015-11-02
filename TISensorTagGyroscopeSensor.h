//
//  TISensorTagGyroscopeSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 9/14/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagSensor.h"

/*!
 @description Contains gyroscopic data in degrees per second.
 */
struct GyroscopeDataStruct
{
	double_t	xRate;
	double_t	yRate;
	double_t	zRate;
};
typedef struct GyroscopeDataStruct GyroscopeData;

/*!
 @enum Gyroscopic Sensor Activation Constants
 @description Bit-ORed values for the ActiveSensors field below.
 @constant kDeactivateSensors Deactivate all sensors.
 @constant kActivateXSensor Activate the X-Axis sensor.
 @constant kActivateYSensor Activate the Y-Axis sensor.
 @constant kActivateZSensor Activate the Z-Axis sensor.
*/
enum
{
	kDeactivateSensors		= 0,
	kActivateXSensor		= 1 << 0,
	kActivateYSensor		= 1 << 1,
	kActivateZSensor		= 1 << 2
};

typedef uint8_t	ActiveSensorBitField;

/// @description TISensorTagGyroscopeSensor contains orientation information from the TI SensorTag's gyroscopic sensor.
@interface TISensorTagGyroscopeSensor : TISensorTagSensor
{
	GyroscopeData			orientation;
	ActiveSensorBitField	activeSensors;
}

/// @description contains the current orientation information from the gyroscopic sensor.
@property (readonly, assign) GyroscopeData orientation;
/// @description contains which sensors are turned on or off as a bit field.  To turn on all sensors, set this value to <code>kActivateXSensor | kActivateYSensor | kActivateZSensor</code>.
@property (nonatomic, readwrite, assign, setter=setActiveSensors:) uint8_t activeSensors;

/// @returns Returns the TISensorTag Gyroscopic Service UUID (F000AA50-0451-4000-B000-000000000000).
+ (CBUUID*)	serviceUUID;

/*!
 @description Initializes the gyroscopic sensor with bluetooth service and device.
 @param service The CBService for the gyroscopic sensor, probably found by comparing a discovered service's UUID to the serviceUUID.
 @param device The CBPeripheral for the bluetooth device
 @result An initialized TISensorTagGyroscopeSensor.
 @note If you're using the TISensorTag class, you don't need to call this.  By setting <code>gyroscopeActive</code> in the TISensorTag object, one of these will be created for you.
 */
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device;
- (void) dealloc;

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
