//
//  TISensorTagDeviceTests.m
//  TISensorTagDeviceTests
//
//  Created by Peter Merchant on 9/23/15.
//  Copyright © 2015 Peter Merchant. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TISensorTagDevice/TISensorTagDevice.h"

@interface TISensorTagDeviceTests : XCTestCase
{
	TISensorTagManager*	manager;
	TISensorTag*		tag;
}
@end

@implementation TISensorTagDeviceTests

- (void)setUp
{
    [super setUp];

	manager = [[TISensorTagManager alloc] init];
	
	[manager addObserver: self forKeyPath: @"list" options: NSKeyValueObservingOptionNew context: NULL];
	[manager startLooking];
}

- (void)tearDown
{
	[manager stopLooking];
	[manager removeObserver: self forKeyPath: @"list"];
	
	[super tearDown];
}

- (void)testExample
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if ([keyPath isEqualToString: @"list"])
	{
		
	}
}
@end
