//
//  TISensorTagSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 7/11/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagSensor.h"

NSString*	kConfigurationUUIDStringKey = @"kConfigurationUUIDStringKey";
NSString*	kCalibrationUUIDStringKey = @"kCalibrationUUIDStringKey";
NSString*	kDataUUIDStringKey = @"kDataUUIDStringKey";
NSString*	kPeriodUUIDStringKey = @"kPeriodUUIDStringKey";

@implementation TISensorTagSensor

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device characteristics: (NSDictionary*) characteristics
{
	if ((self = [self init]))
	{
		NSMutableArray*	cbCharacteristics = NULL;
		
		_device = device;
		_service = service;
		_characteristics = characteristics;
		
		// Try to discover the characteristics for the service
		
		if (characteristics)
		{
			NSString*		eachCharacteristicUUID;

			cbCharacteristics = [NSMutableArray array];
	
			for (eachCharacteristicUUID in characteristics.allValues)
			{
				[cbCharacteristics addObject: [CBUUID UUIDWithString: eachCharacteristicUUID]];
			}
		}
		
		[device discoverCharacteristics: cbCharacteristics forService: service];
	}
	
	return self;
}

#pragma mark - Accessors

- (NSTimeInterval) period
{
	while (! _periodCharacteristic)
		sleep(1);
	
	if (_periodCharacteristic)
	{
		_period = -1;
		[_device readValueForCharacteristic: _periodCharacteristic];
		
		int	count = 0;
		while (_period < 0 && count++ < 10)
			sleep(1);
	}
	
	return _period;
}

- (void) setPeriod: (NSTimeInterval) period
{
	if (_periodCharacteristic)
	{
		int	milliseconds = period * 1000;
		
		if (milliseconds < 100)
			milliseconds = 100;
		else if (milliseconds > 2550)
			milliseconds = 2550;
		
		uint8_t	data = milliseconds / 10;
		
		[self writePeriod: [NSData dataWithBytes: &data length: 1]];
	}
	
	_period = period;
}

- (void) writeData: (NSData*) data
{
	[_device writeValue: [NSData dataWithBytes: &data length: 1] forCharacteristic: _dataCharacteristic type: CBCharacteristicWriteWithResponse];
}

- (void) writePeriod: (NSData*) data
{
	[_device writeValue: data forCharacteristic: _periodCharacteristic type: CBCharacteristicWriteWithResponse];
}

- (void) writeCalibration: (NSData*) data
{
	[_device writeValue: data forCharacteristic: _calibrationCharacteristic type: CBCharacteristicWriteWithResponse];
}

- (void) writeConfiguration: (NSData*) data
{
	[_device writeValue: data forCharacteristic: _configurationCharacteristic type: CBCharacteristicWriteWithResponse];
}

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic
{
	NSString*	characteristicUUIDString = characteristic.UUID.UUIDString;
	
	if ([characteristicUUIDString isEqualToString: [_characteristics objectForKey: kConfigurationUUIDStringKey]])
		_configurationCharacteristic = characteristic;
	else if ([characteristicUUIDString isEqualToString: [_characteristics objectForKey: kCalibrationUUIDStringKey]])
	{
		_calibrationCharacteristic = characteristic;
	}
	else if ([characteristicUUIDString isEqualToString: [_characteristics objectForKey: kDataUUIDStringKey]])
	{
		_dataCharacteristic = characteristic;
		[_device setNotifyValue: YES forCharacteristic: characteristic];
	}
	else if ([characteristicUUIDString isEqualToString: [_characteristics objectForKey: kPeriodUUIDStringKey]])
	{
		_periodCharacteristic = characteristic;
		
		self.period = _period;	// Tacky
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBUUID*) characteristic
{
	if ([characteristic isEqual: _periodCharacteristic])
	{
		uint8_t	newCentiseconds = *((uint8_t*) newValue.bytes);
		
		self.period = newCentiseconds / 100;
	}
}

@end
