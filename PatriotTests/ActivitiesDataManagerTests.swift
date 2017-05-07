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
    
    var changedList: [ Activity ]?
    var changedActivities: [String: Int]?
    
    override func setUp() {
        super.setUp()
        changedList = nil
        changedActivities = nil
        mockHardware = MockHwManager()
        dm = ActivitiesDataManager(hardware: mockHardware)
        mockHardware.activityDelegate = dm
        mockHardware.deviceDelegate = dm
        dm.delegate = self
    }
    
    func testThatDataManagerInstantiated()
    {
        XCTAssertNotNil(dm)
    }
    
    func test_ThatSupportedListChanged_UpdatesActivities()
    {
        let list: Set<String> = ["test1", "test2", "test3"]
        mockHardware.sendDelegateSupportedListChanged(names: list)
        XCTAssertNotNil(changedList)
        XCTAssertEqual(changedList?.count, 3)
    }

    
    func test_ThatSupportedListChanged_ActivityDataCorrect()
    {
        let list: Set<String> = ["test1"]
        mockHardware.sendDelegateSupportedListChanged(names: list)
        XCTAssertNotNil(changedList)
        XCTAssertEqual(changedList?.count,1)
        if let activity = changedList?[0] {
            XCTAssertEqual(activity.name,"test1")
            XCTAssertEqual(activity.percent,0)
        }
    }
    
}


extension ActivitiesDataManagerTests: ActivityNotifying
{
    func supportedListChanged()
    {
        changedList = dm.activities
    }
    
    
    func activityChanged(name: String, percent: Int)
    {
        if changedActivities == nil
        {
            changedActivities = [: ]
        }
        changedActivities?[name] = percent
    }
}
