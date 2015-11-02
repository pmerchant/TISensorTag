//
//  TISensorTagHygrometerSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 8/2/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagHygrometerSensor.h"

@implementation TISensorTagHygrometerSensor

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"F000AA20-0451-4000-B000-000000000000"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = @{ kDataUUIDStringKey : @"F000AA21-0451-4000-B000-000000000000",
										 kConfigurationUUIDStringKey : @"F000AA22-0451-4000-B000-000000000000",
										 kPeriodUUIDStringKey : @"F000AA23-0451-4000-B000-000000000000" };
	
	if ((self = [self initWithService: service forDevice: device characteristics: characteristics]))
	{
		_humidity = 0;
		_temperature = 0;
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

- (void) setHygrometerValuesWithData: (NSData*) data
{
	uint16_t*	humidData = (uint16_t*) [data bytes];
	double_t	newHumidity;
	
	// The data returned from the SensorTag's Sensiron SHT21 consists of a 16-bit temperature and a 12-bit relative humidity.
	
	double_t humidTemp = -46.85 + 175.72/65536 *(double)((int16_t)*humidData);

	if (humidTemp != _temperature)
	{
		[self willChangeValueForKey: @"temperature"];
		_temperature = humidTemp;
		[self didChangeValueForKey: @"temperature"];
	}
	
	humidData++;	// Move 16 bits in to skip the temperature data
	
	newHumidity = -6.0 + 125.0/65536 * ((*humidData) & 0xFFFFC);
	
	if (newHumidity != _humidity)
	{
		[self willChangeValueForKey: @"humidity"];
		_humidity = newHumidity;
		[self didChangeValueForKey: @"humidity"];
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _dataCharacteristic])
	{
		[self setHygrometerValuesWithData: newValue];
	}
	else
		[super updatedValue: newValue forCharacteristic: characteristic];
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

@end
