//
//  TISensorTagManager.m
//  Movement
//
//  Created by Peter Merchant on 1/1/15.
//
//

#import "TISensorTagManager.h"

#import "TISensorTag.h"

@implementation TISensorTagManager

+ (TISensorTagManager*) sharedManager
{
	static dispatch_once_t onceToken;
	static TISensorTagManager*	sManager;
	
	dispatch_once(&onceToken, ^{ sManager = [[TISensorTagManager alloc] init]; });
	
	return sManager;
}

- (id) init
{
	if ((self = [super init]))
	{
		sensorTags = [NSMutableArray array];
		queue = dispatch_queue_create("TISensorTagManager Queue", DISPATCH_QUEUE_SERIAL);
		bluetoothManager = [[CBCentralManager alloc] initWithDelegate: self queue: queue];
	}
	
	return self;
}

- (void) startLooking
{
	if (bluetoothManager.state == CBCentralManagerStatePoweredOn)
		[bluetoothManager scanForPeripheralsWithServices: NULL options: NULL];
}

- (void) stopLooking
{
	[bluetoothManager stopScan];
}

- (TISensorTag*) sensorTagWithIdentifier: (NSString*) identifier;
{
	NSUInteger	foundIndex = [sensorTags indexOfObjectWithOptions: NSEnumerationConcurrent
												   passingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
													   return ([((TISensorTag*)obj).identifier isEqualToString: identifier]);
												   }];
	
	if (foundIndex != NSNotFound)
		return sensorTags[foundIndex];
	else
		return NULL;
}

#pragma mark KVO Support

- (NSArray*) list
{
	return sensorTags;
}

- (NSUInteger) countOfList
{
	return [sensorTags count];
}

- (TISensorTag*) objectInListAtIndex: (NSUInteger) index
{
	return [sensorTags objectAtIndex: index];
}

#pragma mark CBCentralManager delegate methods

- (void) centralManagerDidUpdateState: (CBCentralManager*) central
{
	if (central.state == CBCentralManagerStatePoweredOn)
	{
		[self startLooking];
	}
}

- (void) centralManager: (CBCentralManager*) central didDiscoverPeripheral: (CBPeripheral*) peripheral advertisementData: (NSDictionary*) advertisementData RSSI: (NSNumber*) RSSI
{
	peripheral.delegate = self;
	[central connectPeripheral: peripheral options: NULL];

	if (foundPeripherals)
		[foundPeripherals addObject: peripheral];
	else
		foundPeripherals = [NSMutableArray arrayWithObject: peripheral];
}

- (void) centralManager: (CBCentralManager*) central didConnectPeripheral: (CBPeripheral*) peripheral
{
	[peripheral discoverServices: [NSArray arrayWithObject: [CBUUID UUIDWithString: @"F000CCC0-0451-4000-B000-000000000000"]]];
}

- (void)centralManager: (CBCentralManager*)central didDisconnectPeripheral: (CBPeripheral*) peripheral error: (NSError*) error
{
	TISensorTag*	eachSensorTag;
	
	for (eachSensorTag in sensorTags)
	{
		if ([eachSensorTag.name isEqualToString: [peripheral name]] &&
			[eachSensorTag.identifier isEqualToString: [[peripheral identifier] UUIDString]])
		{
			NSIndexSet* removeIndexSet = [NSIndexSet indexSetWithIndex: [sensorTags indexOfObject: eachSensorTag]];
			
			[self willChange: NSKeyValueChangeRemoval valuesAtIndexes: removeIndexSet forKey: @"list"];
			[sensorTags removeObject: eachSensorTag];
			[self didChange: NSKeyValueChangeRemoval valuesAtIndexes: removeIndexSet forKey: @"list"];
			break;
		}
	}
}

#pragma  mark - CBPeripheral delegate

-(void) peripheral: (CBPeripheral*) peripheral didDiscoverServices: (NSError*) error
{
	BOOL	found = NO;
	CBUUID*	ourServiceUUID = [CBUUID UUIDWithString: @"F000CCC0-0451-4000-B000-000000000000"];
	
	for (CBService*	eachService in peripheral.services)
	{
		if ([eachService.UUID isEqual: ourServiceUUID])
		{
			found = YES;
			break;
		}
	}
	
	if (found)
	{
		BOOL	duplicateTag = NO;
		
		TISensorTag*	eachSensorTag;
		
		for (eachSensorTag in sensorTags)
		{
			if ([eachSensorTag.name isEqualToString: [peripheral name]] &&
				 [eachSensorTag.identifier isEqualToString: [[peripheral identifier] UUIDString]])
			{
				duplicateTag = YES;
				break;
			}
		}
		
		if (! duplicateTag)
		{
			NSIndexSet*	addIndexSet = [NSIndexSet indexSetWithIndex: [sensorTags count]];
			
			[self willChange: NSKeyValueChangeInsertion valuesAtIndexes: addIndexSet forKey: @"list"];
            [sensorTags addObject: [[TISensorTag alloc] initWithPeripheral: peripheral]];
			[self didChange: NSKeyValueChangeInsertion valuesAtIndexes: addIndexSet forKey: @"list"];
		}
	}
	else
		[bluetoothManager cancelPeripheralConnection: peripheral];
	
	[foundPeripherals removeObject: peripheral];
}


@end
