//
//  Hardware.swift
//  rvcp
//
//  Created by Ron Lisle on 4/6/17
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

protocol Hardware {
    var  deviceDelegate:           DeviceNotifying? { get set }
    var  activityDelegate:         ActivityNotifying? { get set }

    /**
     * Send an activity
     */
    func sendActivityCommand(command: String, percent: Int)
    
    /**
     * Initiate async search for devices and supported events
     */
    func discoverDevices()
    
    /**
     * Get cached list of all device
     */
    func getAllDeviceNames() -> [String]
    
    /**
     * Get cached list of supported activities
     */
    func getAllSupportedNames() -> Set<String>
    
    /**
     * Get list of currently active activities from Master
     */
    func getCurrentActivities(completionHandler: @escaping([String]) -> Void)
}
