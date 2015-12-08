//
//  TISensorTag.h
//  Movement
//
//  Created by Peter Merchant on 12/27/14.
//
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "TISensorTagBarometerSensor.h"
#import "TISensorTagHygrometerSensor.h"
#import "TISensorTagThermometerSensor.h"
#import "TISensorTagButtonSensor.h"
#import "TISensorTagAccelerometerSensor.h"
#import "TISensorTagGyroscopeSensor.h"

/*!
 @class TISensorTag
 @description Class for accessing data from a TI Sensor Tag.  The available data is ambient temperature, infrared temperature, humidity, and acceleration.
 @note Other capabilities, such as barometric pressure, signal strength, and gyroscope are not implemented (yet).
*/
@interface TISensorTag : NSObject <CBPeripheralDelegate>
{
@protected
	CBPeripheral*		device;
	NSError*			deviceError;
	
	TISensorTagAccelerometerSensor*	accelerometer;
	TISensorTagGyroscopeSensor*		gyroscope;
	TISensorTagBarometerSensor*		barometer;
	TISensorTagHygrometerSensor*	hygrometer;
	TISensorTagThermometerSensor*	thermometer;
	TISensorTagButtonSensor*		buttons;
}

/*!
 @property device
 @description CBPeripheral representing the device.
*/
@property (readonly, strong)			CBPeripheral*		device;

/*!
 @property deviceError
 @description An NSError with the last error that the device had.  This is best accessed through KVO.
 */
@property (readonly, strong)			NSError*	deviceError;
/*!
 @property accelerometerActive
 @description Boolean value for whether the accelerometer is active. Assigning a value to this will turn the accelerometer on or off (YES or NO, respectively).
 @note Assigning a YES value to accelerometerActive will begin the process of turning the accelerometer on.  However, before using the accelerometer class, you should verify that it is not NULL because it may take some time to activate the accelerometer.  You can either poll or use KVO to determine whether the accelerometer is running.
*/
@property (readwrite, assign, getter=accelerometerActive, setter=setAccelerometerActive:) BOOL accelerometerActive;
/*!
 @property accelerometer
 @description Accelerometer supports the TISensorTag's acceleration sensor, giving access to acceleration data.
 */
@property (readonly, strong)	TISensorTagAccelerometerSensor* accelerometer;

/*!
 @property thermometerActive
 @description Boolean value for whether the accelerometer is active. Assigning a value to this will turn the thermometer on or off (YES or NO, respectively).
 @note Assigning a YES value to thermometerActive will begin the process of turning the thermometer on.  However, before using the thermometer class, you should verify that it is not NULL because it may take some time to activate the thermometer.  You can either poll or use KVO to determine whether the thermometer is running.
 */
@property (readwrite, assign, getter=thermometerActive, setter=setThermometerActive:)	BOOL	thermometerActive;
/*!
 @property thermometer
 @description Thermometer supports the TISensorTag's therometer sensor, giving access to ambient temperature
 and infrared/object temperature
 */
@property (readonly)			TISensorTagThermometerSensor* thermometer;

/*!
 @property barometerActive
 @description Boolean value for whether the barometer is active. Assigning a value to this will turn the barometer on or off (YES or NO, respectively).
 @note Assigning a YES value to barometerActive will begin the process of turning the barometer on.  However, before using the barometer class, you should verify that it is not NULL because it may take some time to activate the barometer.  You can either poll or use KVO to determine whether the barometer is running.
 */
@property (readwrite, assign, getter=barometerActive, setter=setBarometerActive:)	BOOL	barometerActive;
/*!
 @property barometer
 @description Barometer supports the TISensorTag's barometric sensor, giving access to ambient temperature
 and barometric pressure.
 */
@property (readonly)			TISensorTagBarometerSensor* barometer;

/*!
 @property hygrometerActive
 @description Boolean value for whether the hygrometer is active. Assigning a value to this will turn the hygrometer on or off (YES or NO, respectively).
 @note Assigning a YES value to hygrometerActive will begin the process of turning the hygrometer on.  However, before using the hygrometer class, you should verify that it is not NULL because it may take some time to activate the hygrometer.  You can either poll or use KVO to determine whether the hygrometer is running.
 */
@property (readwrite, assign, getter=hygrometerActive, setter=setHygrometerActive:)	BOOL	hygrometerActive;
/*!
 @property hygrometer
 @description Hygrometer supports the TISensorTag's humidity sensor, giving access to ambient temperature
 and relative humidity.
 */
@property (readonly)			TISensorTagHygrometerSensor* hygrometer;

/*!
 @property gyroscopeActive
 @description Boolean value for whether the gyroscope is active. Assigning a value to this will turn the gyroscope on or off (YES or NO, respectively).
 @note Assigning a YES value to gyroscopeActive will begin the process of turning the gyroscope on.  However, before using the gyroscope class, you should verify that it is not NULL because it may take some time to activate the gyroscope.  You can either poll or use KVO to determine whether the hygrometer is running.
 */
@property (readwrite, assign, getter=gyroscopeActive, setter=setGyroscopeActive:)	BOOL	gyroscopeActive;
/*!
 @property gyroscope
 @description Gyroscope supports the TISensorTag's gyroscope sensor, giving access to the sensor's angle.
 */
@property (readonly)			TISensorTagGyroscopeSensor* gyroscope;

/*!
 @property buttonsActive
 @description Boolean value for whether the button notification is active.
 @note Assigning a YES value to buttonsActive will begin the process of turning the button sensor on.  However, before using the button class, you should verify that it is not NULL because it may take some time to activate the button sensor.  You can either poll or use KVO to determine whether the button sensor is running.
 */
@property (readwrite, assign, getter=buttonsActive, setter=setButtonsActive:) BOOL buttonsActive;
/*!
 @property buttons
 @description Buttons supports the two buttons on the front of the device.
*/
@property (readonly)			TISensorTagButtonSensor* buttons;

/*!
 @property name
 @description TI SensorTag device name (which will be TI SensorTag)
*/
@property (readonly)			NSString*			name;
/*!
 @property identifier
 @description UUID String which uniquely identifies the device.
 */
@property (readonly)			NSString*			identifier;

- (id) initWithPeripheral: (CBPeripheral*) theDevice;
- (void) dealloc;

- (BOOL) isEqual: (TISensorTag*) otherSensorTag;

@end
