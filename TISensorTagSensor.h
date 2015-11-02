//
//  TISensorTagSensor.h
//  TisNobler
//
//  Created by Peter Merchant on 7/11/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

/*!
 @const kConfigurationUUIDStringKey
 @description Constant for use in <code>initWithService:forDevice:characteristics</code> characteristics dictionary for the service's configuration UUID.
*/
extern NSString*	kConfigurationUUIDStringKey;
/*!
 @const kCalibrationUUIDStringKey
 @description Constant for use in <code>initWithService:forDevice:characteristics</code> characteristics dictionary for the service's calibration UUID.
*/
extern NSString*	kCalibrationUUIDStringKey;
/*!
 @const kDataUUIDStringKey
 @description Constant for use in <code>initWithService:forDevice:characteristics</code> characteristics dictionary for the service's data UUID.
 */
extern NSString*	kDataUUIDStringKey;
/*!
 @const kPeriodUUIDStringKey
 @description Constant for use in <code>initWithService:forDevice:characteristics</code> characteristics dictionary for the service's period UUID.
 */
extern NSString*	kPeriodUUIDStringKey;

/*!
 @description The TISensorTagSensor class is a "base class" which encapsulate a sensor on a TI SensorTag.  It supports setting the period information as well as data, configuration, and calibration communication.
*/
@interface TISensorTagSensor : NSObject
{
@protected
	CBPeripheral*		_device;
	CBService*			_service;
	NSDictionary*		_characteristics;
	
	CBCharacteristic*	_configurationCharacteristic;
	CBCharacteristic*	_calibrationCharacteristic;
	CBCharacteristic*	_dataCharacteristic;
	CBCharacteristic*	_periodCharacteristic;
	
	NSTimeInterval		_period;
}

/*!
 @property period
 @description How often the device should send a new reading.  May be dependent on the particular sensor, but generally is good for between 0.1 seconds and 2.55 seconds.  Anything other than those will round to the closest value.
*/
@property (readwrite, assign) NSTimeInterval period;

/*!
 @description Initializes a service in a particular TISensorTag.
 @param service The CBService for the bluetooth service.
 @param device The CBPeripheral for the bluetooth device
 @param characteristics An NSDictionary containing the UUIDs of the characteristics that the service works with.  These will usually include keys <code>kConfigurationUUIDStringKey</code> and <code>kDataUUIDStringKey</code>.  If applicable, it should also have keys for <code>kCalibrationUUIDStringKey</code> and <code>kPeriodUUIDStringKey</code>.
 @result An initialized TISensorTagSensor.
*/
- (id) initWithService: (CBService*) service forDevice: (CBPeripheral*) device characteristics: (NSDictionary*) characteristics;

/*!
 @method
 @description Writes data for the <code>kDataUUIDStringKey</code> characteristic.
 @param data The data to write.
*/
- (void) writeData: (NSData*) data;
/*!
 @method
 @description Writes data for the <code>kPeriodUUIDStringKey</code> characteristic.
 @param data The data to write.
 */
- (void) writePeriod: (NSData*) data;
/*!
 @method
 @description Writes data for the <code>kCalibrationUUIDStringKey</code> characteristic.
 @param data The data to write.
 */
- (void) writeCalibration: (NSData*) data;
/*!
 @method
 @description Writes data for the <code>kConfigurationUUIDStringKey</code> characteristic.
 @param data The data to write.
 */
- (void) writeConfiguration: (NSData*) data;

/*!
 @method
 @description This method is called by Core Bluetooth when a characteristic is discovered.
 @param characteristic The discovered characteristic.
 @note When overriding this, you should call super if you are not doing anything with this.  You can override this if you wish to do something special when the characteristic is discovered (for example, setting initial configurations or calibrations.
*/
- (void) discoveredCharacteristic: (CBCharacteristic*) characteristic;
/*!
 @method
 @description This method is called by Core Bluetooth when a value changes for a characteristic.
 @param newValue New value for the characteristic.
 @param characteristic The characteristic with the new value.
 @note When overriding this, you should call super if you are not doing anything with this.  You should override this to take an appropriate action when a value changes for a characteristic.
*/
- (void) updatedValue: (NSData*) newValue forCharacteristic: (CBCharacteristic*) characteristic;

@end
