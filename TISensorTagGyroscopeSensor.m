//
//  TISensorTagGyroscopeSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 9/14/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagGyroscopeSensor.h"

@implementation TISensorTagGyroscopeSensor

@synthesize orientation;
@synthesize activeSensors;

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"F000AA50-0451-4000-B000-000000000000"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = @{ kDataUUIDStringKey : @"F000AA51-0451-4000-B000-000000000000",
										 kConfigurationUUIDStringKey : @"F000AA52-0451-4000-B000-000000000000",
										 kPeriodUUIDStringKey : @"F000AA53-0451-4000-B000-000000000000" };
	
	if ((self = [self initWithService: service forDevice: device characteristics: characteristics]))
	{
		orientation.xRate = 0;
		orientation.yRate = 0;
		orientation.zRate = 0;
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

- (void) setActiveSensors: (uint8_t) newActiveSensors
{
	if (newActiveSensors != activeSensors && newActiveSensors <= (kActivateXSensor & kActivateYSensor & kActivateZSensor))
	{
		activeSensors = newActiveSensors;
		[self writeConfiguration: [NSData dataWithBytesNoCopy: &activeSensors length: sizeof(activeSensors) freeWhenDone: NO]];
	}
}

- (void) setOrientationFromData: (NSData*) data
{
	GyroscopeData	newData = { 0, 0, 0 };
	int16_t*		rawValue = (int16_t*)[data bytes];
	
	if (activeSensors & kActivateXSensor)
		newData.xRate = (double)(CFSwapInt16LittleToHost(*rawValue)) / (65536 / 500);
	rawValue++;
	if (activeSensors & kActivateYSensor)
		newData.yRate = (double)(CFSwapInt16LittleToHost(*rawValue)) / (65536 / 500);
	rawValue++;
	if (activeSensors & kActivateZSensor)
		newData.zRate = (double)(CFSwapInt16LittleToHost(*rawValue)) / (65536 / 500);
	
	if (newData.xRate != orientation.xRate || newData.yRate != orientation.yRate || newData.zRate != orientation.zRate)
	{
		[self willChangeValueForKey: @"orientation"];
		orientation = newData;
		[self didChangeValueForKey: @"orientation"];
	}
}

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic
{
	[super discoveredCharacteristic: characteristic];
	
	if ([characteristic isEqual: _configurationCharacteristic])
	{
		[self writeConfiguration: [NSData dataWithBytesNoCopy: &activeSensors length: sizeof(activeSensors) freeWhenDone:NO]];
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _dataCharacteristic])
	{
		[self setOrientationFromData: newValue];
	}
	else
		[super updatedValue: newValue forCharacteristic: characteristic];
}

@end
