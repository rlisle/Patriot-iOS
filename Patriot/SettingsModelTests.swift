//
//  SettingsModelTests.swift
//  Patriot
//
//  Created by Ron Lisle on 6/8/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import XCTest
@testable import Patriot

class MockSettingsStore: SettingsStore
{
    var key: SettingsKey?
    var bool: Bool?
    var intValue: Int?
    var string: String?

    func getBool(forKey: SettingsKey) -> Bool?
    {
        key = forKey
        
        return bool
    }
    
    
    func set(_ bool: Bool?, forKey: SettingsKey)
    {
        key = forKey
        self.bool = bool
    }
    
    
    func getInt(forKey: SettingsKey) -> Int?
    {
        key = forKey
        
        return intValue
    }
    
    
    func set(_ intValue: Int?, forKey: SettingsKey)
    {
        key = forKey
        self.intValue = intValue
    }
    
    
    func getString(forKey: SettingsKey) -> String?
    {
        return string
    }
    
    
    func set(_ string: String?, forKey: SettingsKey)
    {
        key = forKey
        self.string = string
    }
}


class SettingsModelTests: XCTestCase
{
    var settings: Settings!
    var mockStore: MockSettingsStore!
    
    override func setUp()
    {
        super.setUp()
        
        mockStore = MockSettingsStore()
        settings = Settings(store: mockStore)
    }

    
    func testBeaconUUIDReadsValueFromStore()
    {
        mockStore.string = "00000000-0000-0000-0000-000000000000"
        XCTAssertEqual(settings.beaconUUID, mockStore.string)
    }


    func testSetBeaconUUIDWritesValueToStore()
    {
        let testString = "00000001-0002-0003-0004-000000000005"
        settings.beaconUUID = testString
        XCTAssertEqual(testString, mockStore.string)
    }


    func testBeaconTransmitReadsValueFromStore()
    {
        mockStore.bool = true
        XCTAssertTrue(settings.isBeaconTransmitOn)
    }


    func testSetBeaconTransmitWritesTrueValueToStore()
    {
        settings.isBeaconTransmitOn = true
        XCTAssertNotNil(mockStore.bool)
        XCTAssertTrue(mockStore.bool!)
    }


    func testSetBeaconTransmitWritesFalseValueToStore()
    {
        settings.isBeaconTransmitOn = false
        XCTAssertNotNil(mockStore.bool)
        XCTAssertFalse(mockStore.bool!)
    }
    
    
    func testBeaconIdentifierReadsValueFromStore()
    {
        mockStore.string = "PatriotBeacon"
        XCTAssertEqual(settings.beaconIdentifier, mockStore.string)
    }


    func testSetBeaconIdentifierWritesValueToStore()
    {
        let testString = "PatriotBeacon"
        settings.beaconIdentifier = testString
        XCTAssertEqual(testString, mockStore.string)
    }



}
