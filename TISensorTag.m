//
//  TISensorTag.m
//  Movement
//
//  Created by Peter Merchant on 12/27/14.
//
//

#import "TISensorTag.h"

#import "TISensorTagBMP280BarometerSensor.h"

@implementation TISensorTag

@synthesize device;
@synthesize accelerometer;
@synthesize barometer;
@synthesize hygrometer;
@synthesize thermometer;
@synthesize gyroscope;
@synthesize buttons;
@synthesize deviceError;

- (id) initWithPeripheral: (CBPeripheral*) theDevice
{
	if ((self = [self init]))
	{
		device = theDevice;
		theDevice.delegate = self;
	}
	
	return self;
}

- (void) dealloc
{
	self.accelerometerActive = NO;
	self.thermometerActive = NO;
	self.hygrometerActive = NO;
	self.barometerActive = NO;
	self.gyroscopeActive = NO;
}

- (BOOL) isEqual: (TISensorTag*) otherSensorTag
{
	return ([device isEqual: otherSensorTag.device]);
}

- (NSString*) name
{
	return device.name;
}

- (NSString*) identifier
{
	return [device.identifier UUIDString];
}

#pragma mark Thermometer


- (BOOL) thermometerActive
{
	return (thermometer != NULL);
}

- (void) setThermometerActive: (BOOL) temperatureActive
{
	if (temperatureActive && thermometer == NULL)
		[self.device discoverServices: [NSArray arrayWithObjects: [TISensorTagThermometerSensor serviceUUID], nil]];
	else if (! temperatureActive && thermometer != NULL)
		thermometer = NULL;
}

#pragma mark Humidity

- (BOOL) hygrometerActive
{
	return (hygrometer == NULL);
}

- (void) setHygrometerActive: (BOOL) humidityActive
{
	if (humidityActive && hygrometer == NULL)
		[self.device discoverServices: [NSArray arrayWithObjects: [TISensorTagHygrometerSensor serviceUUID], nil]];
	else if (! humidityActive && hygrometer != NULL)
		hygrometer = NULL;	// Turn off hygrometer
}

#pragma mark Barometer

- (BOOL) barometerActive
{
	return (self.barometer != NULL);
}

- (void) setBarometerActive: (BOOL) barometricPressureActive
{
	if (! barometricPressureActive && self.barometer != NULL)
		barometer = NULL;
	else if (barometricPressureActive && self.barometer == NULL)
	{
		[self.device discoverServices: [NSArray arrayWithObjects: [TISensorTagBarometerSensor serviceUUID], nil]];
	}
}

#pragma mark Gyroscope

- (BOOL) gyroscopeActive
{
	return (self.gyroscope != NULL);
}

- (void) setGyroscopeActive: (BOOL) gyroscopeActive
{
	if (! gyroscopeActive && self.gyroscope != NULL)
		gyroscope = NULL;
	else if (gyroscopeActive && self.gyroscope == NULL)
		[self.device discoverServices: @[ [TISensorTagGyroscopeSensor serviceUUID] ]];
}

#pragma mark Buttons

- (BOOL) buttonsActive
{
	return (self.buttons != NULL);
}

- (void) setButtonsActive: (BOOL) buttonsActive
{
	if (! buttonsActive && self.buttons)
		buttons = NULL;
	else if (buttonsActive && self.buttons == NULL)
		[self.device discoverServices: [NSArray arrayWithObject: [TISensorTagButtonSensor serviceUUID]]];
}

#pragma mark Acceleration

- (BOOL) accelerometerActive
{
	return (accelerometer != NULL);
}

- (void) setAccelerometerActive: (BOOL) accelerationActive
{
	if (! accelerationActive && self.accelerometer)
		accelerometer = NULL;
	else if (accelerationActive && self.accelerometer == NULL)
		[self.device discoverServices: [NSArray arrayWithObject: [TISensorTagAccelerometerSensor serviceUUID]]];
}

#pragma mark CBPeripheral delegate protocol

- (void) peripheral: (CBPeripheral*) peripheral didDiscoverServices: (NSError*) error
{
	if (error)
	{
		NSLog(@"%@", error);
		return;
	}
		
	CBService*	eachService;
	
	for (eachService in device.services)
	{
		if ([eachService.UUID isEqual: [TISensorTagAccelerometerSensor serviceUUID]] &&
			accelerometer == NULL)
		{
			[self willChangeValueForKey: @"accelerometer"];
			accelerometer = [[TISensorTagAccelerometerSensor alloc] initWithService: eachService forDevice: device];
			[self didChangeValueForKey: @"accelerometer"];
		}
		else if ([eachService.UUID isEqual: [TISensorTagGyroscopeSensor serviceUUID]] && gyroscope == NULL)
		{
			[self willChangeValueForKey: @"gyroscope"];
			gyroscope = [[TISensorTagGyroscopeSensor alloc] initWithService: eachService forDevice: device];
			[self didChangeValueForKey: @"gyroscope"];
		}
		else if ([eachService.UUID isEqual: [TISensorTagBarometerSensor serviceUUID]] && barometer == NULL)
		{
			[self willChangeValueForKey: @"barometer"];
			if ([self.name isEqualToString: @"TI BLE Sensor Tag"])
				barometer = [[TISensorTagBarometerSensor alloc] initWithService: eachService forDevice: device];
			else if ([self.name isEqualToString: @"SensorTag 2.0"])
				barometer = [[TISensorTagBMP280BarometerSensor alloc] initWithService: eachService forDevice: device];
			[self didChangeValueForKey: @"barometer"];
		}
		else if ([eachService.UUID isEqual: [TISensorTagHygrometerSensor serviceUUID]] &&
				 hygrometer == NULL)
		{
			[self willChangeValueForKey: @"hygrometer"];
			hygrometer = [[TISensorTagHygrometerSensor alloc] initWithService: eachService forDevice: device];
			[self didChangeValueForKey: @"hygrometer"];
		}
		else if ([eachService.UUID isEqual: [TISensorTagThermometerSensor serviceUUID]] &&
				 thermometer == NULL)
		{
			[self willChangeValueForKey: @"thermometer"];
			thermometer = [[TISensorTagThermometerSensor alloc] initWithService: eachService forDevice: device];
			[self didChangeValueForKey: @"thermometer"];
		}
		else if ([eachService.UUID isEqual: [TISensorTagButtonSensor serviceUUID]] && buttons == NULL)
		{
			[self willChangeValueForKey: @"buttons"];
			buttons = [[TISensorTagButtonSensor alloc] initWithService: eachService forDevice: device];
			[self didChangeValueForKey: @"buttons"];
		}
	}
}

- (void) peripheral: (CBPeripheral*) peripheral didDiscoverCharacteristicsForService: (CBService*) service error: (NSError*) error
{
	CBCharacteristic*	eachCharacteristic;
	TISensorTagSensor*	foundSensor = NULL;
	
	if ([service.UUID isEqual: [TISensorTagBarometerSensor serviceUUID]])
		foundSensor = barometer;
	else if ([service.UUID isEqual: [TISensorTagHygrometerSensor serviceUUID]])
		foundSensor = hygrometer;
	else if ([service.UUID isEqual: [TISensorTagThermometerSensor serviceUUID]])
		foundSensor = thermometer;
	else if ([service.UUID isEqual: [TISensorTagGyroscopeSensor serviceUUID]])
		foundSensor = gyroscope;
	else if ([service.UUID isEqual: [TISensorTagAccelerometerSensor serviceUUID]])
		foundSensor = accelerometer;
	else if ([service.UUID isEqual: [TISensorTagButtonSensor serviceUUID]])
		foundSensor = buttons;
	else
		NSLog(@"Discovered characteristics for unknown service: %@", service);
	
	if (error)
	{
		[self willChangeValueForKey: @"deviceError"];
		deviceError = error;
		[self didChangeValueForKey: @"deviceError"];
	}
	
	if (foundSensor)
	{
		for (eachCharacteristic in service.characteristics)
			[foundSensor discoveredCharacteristic: eachCharacteristic];
	}
}

- (void) peripheral: (CBPeripheral*) peripheral didUpdateValueForCharacteristic: (CBCharacteristic*) characteristic error: (NSError*) error
{
	if (error)
	{
		[self willChangeValueForKey: @"deviceError"];
		deviceError = error;
		[self didChangeValueForKey: @"deviceError"];
	}
	
	[barometer updatedValue: characteristic.value forCharacteristic: characteristic];
	[hygrometer updatedValue: characteristic.value forCharacteristic: characteristic];
	[thermometer updatedValue: characteristic.value forCharacteristic: characteristic];
	[accelerometer updatedValue: characteristic.value forCharacteristic: characteristic];
	[gyroscope updatedValue: characteristic.value forCharacteristic: characteristic];
	[buttons updatedValue: characteristic.value forCharacteristic: characteristic];
}

- (void) peripheral: (CBPeripheral*) peripheral didWriteValueForCharacteristic: (CBCharacteristic*) characteristic error:(NSError*) error
{
	if (error)
	{
		[self willChangeValueForKey: @"deviceError"];
		deviceError = error;
		[self didChangeValueForKey: @"deviceError"];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error)
	{
		[self willChangeValueForKey: @"deviceError"];
		deviceError = error;
		[self didChangeValueForKey: @"deviceError"];
	}
}

@end