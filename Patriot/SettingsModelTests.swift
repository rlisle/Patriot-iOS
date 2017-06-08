//
//  SettingsModelTests.swift
//  Patriot
//
//  Created by Ron Lisle on 6/8/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import XCTest

class SettingsModelTests: XCTestCase
{
    var settings: SettingsModel!
    
    override func setUp()
    {
        super.setUp()
        
        settings = SettingsModel()
    }
    
    func testSettingsInstantiated()
    {
        XCTAssertNotNil(settings)
    }
    
}
