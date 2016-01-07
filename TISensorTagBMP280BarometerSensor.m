//
//  TISensorTagBarometerSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 7/14/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagBMP280BarometerSensor.h"

@implementation TISensorTagBMP280BarometerSensor

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"F000AA40-0451-4000-B000-000000000000"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = @{ kDataUUIDStringKey : @"F000AA41-0451-4000-B000-000000000000",
										 kConfigurationUUIDStringKey : @"F000AA42-0451-4000-B000-000000000000",
										 kPeriodUUIDStringKey : @"F000AA44-0451-4000-B000-000000000000" };
	
	if ((self = [self initWithService: service forDevice: device characteristics: characteristics]))
	{
		_pressure = 0;
		_temperature = 0;
	}
	
	return self;
}

- (void) dealloc
{
	if (_configurationCharacteristic)
	{
		// We have a calibration characteristic.  Set up the calibration data.
		uint8_t	value = 0x00;
		
		[self writeConfiguration: [NSData dataWithBytesNoCopy: &value length: sizeof(value) freeWhenDone: NO]];
	}
}

- (void) setBarometerValuesWithData: (NSData*) data
{
	NSAssert((data.length >= 6), @"Did not receive enough data from device: %lu", (unsigned long)data.length);

	int32_t		tempBytes = 0;
	int32_t		pressBytes = 0;
	
	// The data is three bytes of temperature in celsius followed by three bytes of pressure in hPa.
	
	[data getBytes: &tempBytes range: NSMakeRange(0, 3)];
	[data getBytes: &pressBytes range: NSMakeRange(3, 3)];
	
	double_t	newValue = (double_t) CFSwapInt32LittleToHost(tempBytes) / 100.0;
	
	if (newValue != _temperature)
	{
		[self willChangeValueForKey: @"temperature"];
		_temperature = newValue;
		[self didChangeValueForKey: @"temperature"];
	}
	
	newValue = (double_t) CFSwapInt32LittleToHost(pressBytes);
	
	if (newValue != _pressure)
	{
		[self willChangeValueForKey: @"pressure"];
		_pressure = newValue;
		[self didChangeValueForKey: @"pressure"];
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _dataCharacteristic])
	{
		[self setBarometerValuesWithData: [characteristic value]];
	}
	else
		[super updatedValue: newValue forCharacteristic: characteristic];
}

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic
{
	[super discoveredCharacteristic: characteristic];
	
	if (_configurationCharacteristic)
	{
		uint8_t	value = 0x01;
		
		[self writeConfiguration: [NSData dataWithBytes: &value length: sizeof(value)]];
	}
}

@end
