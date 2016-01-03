//
//  TISensorTagBarometerSensor.h
//  TISNobler
//
//  Created by Peter Merchant.
//  Copyright (c) 2016 Peter Merchant. All rights reserved.
//

#import "TISensorTagDevice/TISensorTagBarometerSensor.h"

/// @description TISensorTagBMP280BarometerSensor contains barometer and temperature data from the TI SensorTag 2.0's BMP280 barometric sensor.
@interface TISensorTagBMP280BarometerSensor : TISensorTagBarometerSensor

- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
