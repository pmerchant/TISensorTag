//
//  TISensorTagBarometerSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 7/14/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagBarometerSensor.h"

@implementation TISensorTagBarometerSensor

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"F000AA40-0451-4000-B000-000000000000"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = @{ kDataUUIDStringKey : @"F000AA41-0451-4000-B000-000000000000",
										 kConfigurationUUIDStringKey : @"F000AA42-0451-4000-B000-000000000000",
										 kCalibrationUUIDStringKey : @"F000AA43-0451-4000-B000-000000000000",
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
		uint8_t	value = 0x02;
		
		[self writeConfiguration: [NSData dataWithBytesNoCopy: &value length: sizeof(value) freeWhenDone: NO]];
	}
}

- (int) pressureAltitude
{
	double_t	currentMillibars = _pressure / 100;
	
	return (1-(pow(currentMillibars / 1013.25, 0.190284))) * 145366.45;
}

- (void) calibrateBarometerWithData: (NSData*) calibrationData
{
	uint8_t*	eachDataByte = (uint8_t*) [calibrationData bytes];
	
	self->calCoefs.c1 = CFSwapInt16LittleToHost(*((uint16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c2 = CFSwapInt16LittleToHost(*((uint16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c3 = CFSwapInt16LittleToHost(*((uint16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c4 = CFSwapInt16LittleToHost(*((uint16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c5 = CFSwapInt16LittleToHost(*((int16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c6 = CFSwapInt16LittleToHost(*((int16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c7 = CFSwapInt16LittleToHost(*((int16_t*) eachDataByte));
	eachDataByte += 2;
	self->calCoefs.c8 = CFSwapInt16LittleToHost(*((int16_t*) eachDataByte));
}

- (void) setBarometerValuesWithData: (NSData*) data
{
	NSAssert((data.length >= 4), @"Did not receive enough data from device: %lu", (unsigned long)data.length);
	
	uint8_t scratchVal[4];
	[data getBytes:&scratchVal length:4];
	int16_t temp;
	uint16_t pressure;
	
	temp = (scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00);
	pressure = (scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00);
	long long tempTemp = temp;
	
	int64_t bartemp, val;
	val = ((int64_t)(calCoefs.c1 * temp) * 100);
	bartemp = (val >> 24);
	val = ((int64_t)calCoefs.c2 * 100);
	bartemp += (val >> 10);
	double_t dBarTemp = bartemp / 100.0;
	
	if (dBarTemp != _temperature)
	{
		[self willChangeValueForKey: @"temperature"];
		_temperature = dBarTemp;
		[self didChangeValueForKey: @"temperature"];
	}
	
	// Barometer calculation
	
	long long S = calCoefs.c3 + ((calCoefs.c4 * (long long)tempTemp)/((long long)1 << 17)) + ((calCoefs.c5 * ((long long)tempTemp * (long long)tempTemp))/(long long)((long long)1 << 34));
	long long O = (calCoefs.c6 * ((long long)1 << 14)) + (((calCoefs.c7 * (long long)tempTemp)/((long long)1 << 3))) + ((calCoefs.c8 * ((long long)tempTemp * (long long)tempTemp))/(long long)((long long)1 << 19));
	long long Pa = (((S * (long long)pressure) + O) / (long long)((long long)1 << 14));
	
	if (Pa != _pressure)
	{
		[self willChangeValueForKey: @"pressure"];
		_pressure = Pa;
		[self didChangeValueForKey: @"pressure"];
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _calibrationCharacteristic])
	{
		[self calibrateBarometerWithData: [characteristic value]];
		
		uint8_t	value = 0x01;
		
		[self writeConfiguration: [NSData dataWithBytes: &value length: sizeof(value)]];
	}
	else if ([characteristic isEqual: _dataCharacteristic])
	{
		[self setBarometerValuesWithData: [characteristic value]];
	}
	else
		[super updatedValue: newValue forCharacteristic: characteristic];
}

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic
{
	[super discoveredCharacteristic: characteristic];
	
	if (([characteristic isEqual: _calibrationCharacteristic] || [characteristic isEqual: _configurationCharacteristic]) &&
		(_configurationCharacteristic && _calibrationCharacteristic))
	{
		// We have a calibration characteristic.  Set up the calibration data.
		uint8_t	value = 0x02;
		
		[self writeConfiguration: [NSData dataWithBytes: &value length: sizeof(value)]];
		[_device readValueForCharacteristic: _calibrationCharacteristic];
	}
}

@end
