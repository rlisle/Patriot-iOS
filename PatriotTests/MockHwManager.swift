//
//  MockHwManager.swift
//  Patriot
//
//  Created by Ron Lisle on 5/5/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation
import PromiseKit


class MockHwManager: HwManager
{
    var deviceDelegate:         DeviceNotifying?
    var activityDelegate:       ActivityNotifying?
    var photons:                [String: Photon]    = [: ]
    var eventName:              String              = "unspecified"
    var deviceNames:            Set<String>         = []
    var supportedNames =        Set<String>()
    var currentActivities:      [String: Int]       = [: ]


    func login(user: String, password: String) -> Promise<Void>
    {
        return Promise(value: ())
    }
    
    
    func discoverDevices() -> Promise<Void>
    {
        return Promise(value: ())
    }
    
    
    func sendCommand(activity: String, percent: Int)
    {
    }
}


//MARK: Testing Methods

extension MockHwManager
{
    func sendDelegateSupportedListChanged(names: Set<String>)
    {
        supportedNames = names
        activityDelegate?.supportedListChanged()
    }
}


