//
//  TISensorTagThermometerSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 8/2/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagThermometerSensor.h"

@implementation TISensorTagThermometerSensor

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"F000AA00-0451-4000-B000-000000000000"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = @{ kDataUUIDStringKey : @"F000AA01-0451-4000-B000-000000000000",
										 kConfigurationUUIDStringKey : @"F000AA02-0451-4000-B000-000000000000",
										 kPeriodUUIDStringKey : @"F000AA03-0451-4000-B000-000000000000" };
		
	if ((self = [self initWithService: service forDevice: device characteristics: characteristics]))
	{
		_infraredTemperature = 0;
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

- (void) setTemperatureValuesFromData: (NSData*) data
{
	uint16_t*	tempData = (uint16_t*)[data bytes];
	
	// Temperature data from the TI TMP006 has the infrared and ambient temperature in the form:
	// <Infrared 16-bit Little-Endian><Ambient 16-bit Little-Endian>
	
	// First, we get the ambient temperature
	tempData++;	// go to the next 16 bits
	
	double_t	newAmbient = (*tempData) / 128.0;
	NSLog(@"ambient Temp = %.2f", newAmbient);
	if (newAmbient != _temperature)
	{
		[self willChangeValueForKey: @"temperature"];
		_temperature = newAmbient;
		[self didChangeValueForKey: @"temperature"];
	}
	
	// Now we get the infrared temperature.  Calculating that is dependent on the ambient temperature, which is why we got it first.
	// The below formula is copied from the TI SensorTag wiki @ http://processors.wiki.ti.com/index.php/SensorTag_User_Guide#IR_Temperature_Sensor
	
	tempData--;	// go back to the first 16 bits
	
	char scratchVal[data.length];
	int16_t objTemp;
	[data getBytes:&scratchVal length:data.length];
	objTemp = (scratchVal[0] & 0xff)| ((scratchVal[1] << 8) & 0xff00);
	
	long double Vobj2 = (double)objTemp * .00000015625;
	long double Tdie2 = (double)newAmbient + 273.15;
	long double S0 = 6.4*pow(10,-14);
	long double a1 = 1.75*pow(10,-3);
	long double a2 = -1.678*pow(10,-5);
	long double b0 = -2.94*pow(10,-5);
	long double b1 = -5.7*pow(10,-7);
	long double b2 = 4.63*pow(10,-9);
	long double c2 = 13.4f;
	long double Tref = 298.15;
	long double S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2));
	long double Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2);
	long double fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2);
	long double Tobj = pow(pow(Tdie2,4) + (fObj/S),.25);
	Tobj = (Tobj - 273.15);
	
	if (Tobj != _infraredTemperature)
	{
		[self willChangeValueForKey: @"infraredTemperature"];
		_infraredTemperature = Tobj;
		[self didChangeValueForKey: @"infraredTemperature"];
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _dataCharacteristic])
	{
		[self setTemperatureValuesFromData: newValue];
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
		
		[self writeConfiguration: [NSData dataWithBytes: &value length: sizeof(value)]];
	}
}

@end
