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

    
    func testParticleUserReadsValueFromStore()
    {
        mockStore.string = "user@test.com"
        XCTAssertEqual(settings.particleUser, mockStore.string)
    }


    func testSetParticleUserWritesValueToStore()
    {
        let testString = "user2@test.com"
        settings.particleUser = testString
        XCTAssertEqual(testString, mockStore.string)
    }


    func testParticlePasswordReadsValueFromStore()
    {
        mockStore.string = "user3@test.com"
        XCTAssertEqual(settings.particlePassword, mockStore.string)
    }


    func testSetParticlePasswordWritesValueToStore()
    {
        let testString = "password"
        settings.particlePassword = testString
        XCTAssertEqual(testString, mockStore.string)
    }
}
