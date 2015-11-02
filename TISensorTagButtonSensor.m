//
//  TISensorTagButtonSensor.m
//  TisNobler
//
//  Created by Peter Merchant on 8/22/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "TISensorTagButtonSensor.h"

#define kButton1Down	0x01
#define kButton2Down	0x02

@implementation TISensorTagButtonSensor

@synthesize button1Down;
@synthesize button2Down;

+ (CBUUID*)	serviceUUID
{
	return [CBUUID UUIDWithString: @"FFE0"];
}

- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device
{
	NSDictionary*	characteristics = [NSDictionary dictionaryWithObject: @"FFE1" forKey: kDataUUIDStringKey];

	if ((self = [super initWithService: service forDevice: device characteristics: characteristics]))
	{
		button1Down = NO;
		button2Down = NO;
	}
	
	return self;
}

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic
{
	[super discoveredCharacteristic: characteristic];

	if ([characteristic.UUID.UUIDString isEqual: [_characteristics objectForKey: kDataUUIDStringKey]])
	{
		if (! characteristic.isNotifying)
		{
			[_device setNotifyValue: YES forCharacteristic: characteristic];
		}
	}
}

- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic
{
	if ([characteristic isEqual: _dataCharacteristic])
	{
		BOOL		newButton1;
		BOOL		newButton2;
		uint8_t*	buttonValues = (uint8_t*) [newValue bytes];
		
		newButton1 = ((*buttonValues & kButton1Down) == kButton1Down);
		newButton2 = ((*buttonValues & kButton2Down) == kButton2Down);
		
		if (newButton1 != button1Down)
		{
			[self willChangeValueForKey: @"button1Down"];
			button1Down = newButton1;
			[self didChangeValueForKey: @"button1Down"];
		}
		if (newButton2 != button2Down)
		{
			[self willChangeValueForKey: @"button2Down"];
			button2Down = newButton2;
			[self didChangeValueForKey: @"button2Down"];
		}
	}
}

@end
