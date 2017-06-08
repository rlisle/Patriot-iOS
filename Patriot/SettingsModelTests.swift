//
//  SettingsModelTests.swift
//  Patriot
//
//  Created by Ron Lisle on 6/8/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import XCTest

class MockSettingsStore: SettingsStore
{
    var key: SettingsKey?
    var bool: Bool?
    var string: String?
    
    func set(_ bool: Bool, forKey: SettingsKey)
    {
        key = forKey
        self.bool = bool
    }
    
    
    func set(_ string: String, forKey: SettingsKey)
    {
        key = forKey
        self.string = string
    }
}


class SettingsModelTests: XCTestCase
{
    var settings: SettingsModel!
    var mockStore: MockSettingsStore!
    
    override func setUp()
    {
        super.setUp()
        
        mockStore = MockSettingsStore()
        settings = SettingsModel(store: mockStore)
    }

    
    func testSettingsInstantiated()
    {
        XCTAssertNotNil(settings)
    }
    

}
