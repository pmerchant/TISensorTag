//
//  TISensorTagAccelerometerSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 8/24/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagAccelerometerSensor.h"

@interface TISensorTagAccelerometerSensor ()

- (void) setAccelerationFromData: (NSData*) data;

@end

@implementation TISensorTagAccelerometerSensor

@synthesize acceleration;

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"F000AA10-0451-4000-B000-000000000000"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = @{ kDataUUIDStringKey : @"F000AA11-0451-4000-B000-000000000000",
										 kConfigurationUUIDStringKey : @"F000AA12-0451-4000-B000-000000000000",
										 kPeriodUUIDStringKey : @"F000AA13-0451-4000-B000-000000000000" };
	
	if ((self = [self initWithService: service forDevice: device characteristics: characteristics]))
	{
		acceleration.x = 0;
		acceleration.y = 0;
		acceleration.z = 0;
	}
	
	return self;
}

- (void) dealloc
{
	if (_configurationCharacteristic)
	{
		uint8_t	value = 0x01;
		
		[self writeConfiguration: [NSData dataWithBytesNoCopy: &value length: sizeof(value) freeWhenDone:NO]];
	}
}

- (void) setAccelerationFromData: (NSData*) data
{	
	AccelerationData	newAccel;
	int8_t*				eachElement = (int8_t*) [data bytes];
	
	newAccel.x = ((*eachElement) / 64.0) * 4;
	eachElement++;
	newAccel.y = ((*eachElement) / 64.0) * 4;
	eachElement++;
	newAccel.z = ((*eachElement) / 64.0) * 4;
	
	if (newAccel.x != acceleration.x || newAccel.y != acceleration.y || newAccel.z != acceleration.z)
	{
		[self willChangeValueForKey: @"acceleration"];
		acceleration = newAccel;
		[self didChangeValueForKey: @"acceleration"];
	}
}

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic
{
	[super discoveredCharacteristic: characteristic];
	
	if ([characteristic isEqual: _configurationCharacteristic])
	{
		uint8_t	value = 0x01;
		
		[self writeConfiguration: [NSData dataWithBytesNoCopy: &value length: sizeof(value) freeWhenDone:NO]];
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _dataCharacteristic])
	{
		[self setAccelerationFromData: newValue];
	}
}

@end
