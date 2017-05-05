//
//  ActivitiesDataManagerTests.swift
//  Patriot
//
//  Created by Ron Lisle on 5/4/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import XCTest
import PromiseKit


class ActivitiesDataManagerTests: XCTestCase {
    
    var dm: ActivitiesDataManager!
    var mockHardware: MockHwManager!
    
    override func setUp() {
        super.setUp()
        mockHardware = MockHwManager()
        dm = ActivitiesDataManager(hardware: mockHardware)
    }
    
    func testThatDataManagerInstantiated()
    {
        XCTAssertNotNil(dm)
    }
    
    
}
