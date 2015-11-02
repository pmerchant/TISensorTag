//
//  TISensorTagManager.h
//  Movement
//
//  Created by Peter Merchant on 1/1/15.
//
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

@class TISensorTag;

/// @description A TISensorTagManager will manage a collection of TISensorTags via bluetooth and changes will be reported via Key-Value Observing.
@interface TISensorTagManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
@protected
	NSMutableArray*		sensorTags;
	dispatch_queue_t	queue;
	CBCentralManager*	bluetoothManager;
	NSMutableArray*		foundPeripherals;
}


/// @description Contains a list of TISensorTags which are available to be queried.  This list supports a "to-many" relationship.
@property (readonly, retain) NSArray* list;

/*!
 @description Returns an initialized TISensorTagManager.
 
 There will generally be one TISensorTagManager for an application with whatever components using Key-Value Observing to detect any additions or deletions from the list.
 
 @note The TISensorTagManager returned will not begin checking bluetooth for TISensorTags until it receives a @c startLooking message.
*/
+ (TISensorTagManager*) sharedManager;

- (id) init;

/// @description Causes TISensorTagManager to begin tracking TISensorTags which may appear/disappear.
- (void) startLooking;

/// @description Causes TISensorTagManager to stop tracking TISensorTags which may appear/disappear.  The list will contain whatever was last known, however any changes to the TISensorTags will not be shown (eg, turning off a TISensorTag will not cause the list to change and an attempt to communicate with the turned off device will fail.)
- (void) stopLooking;


/*!
 @method sensorTagWithIdentifier:
 @description Returns the sensor tag from the list of sensor tags having the appropriate identifier.
 @param identifier UUID String containing the SensorTag's identifier.
 @result The found SensorTag or NULL if the SensorTag with that identifier is not found.
 */
- (TISensorTag*) sensorTagWithIdentifier: (NSString*) identifier;

@end
