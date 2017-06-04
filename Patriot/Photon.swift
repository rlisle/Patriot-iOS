//
//  Photon.swift
//  Patriot
//
//  This class provides the interface to a Photon device.
//
//  The photon will be interrogated to identify the devices and activities
//  that it supports:
//
//      deviceNames     is a list of all the devices exposed on the Photon
//      supportedNames  is a list of all activities supported by the Photon
//      activities      is a list exposed by some Photons tracking current
//                      activity state based on what it has heard.
//
//  This file uses the Particle SDK:
//      https://docs.particle.io/reference/ios/#common-tasks
//
//  Created by Ron Lisle on 4/17/17
//  Copyright © 2016, 2017 Ron Lisle. All rights reserved.
//

import Foundation
import Particle_SDK
import PromiseKit


enum PhotonError : Error
{
    case DeviceVariable
    case SupportedVariable
    case ActivitiesVariable
    case PublishVariable
    case ReadVariable
    case unknown
}


// Public interface
class Photon: HwController
{
    let uninitializedString = "uninitialized"
    
    var devices: Set<String>?           // Cached list of device names exposed by Photon
    var supported: Set<String>?         // Cached list of supported activities
    var activities: [String: Int]?      // Optional list of current activities and state
    var publish: String                 // Publish event name that this device monitors
    
    var delegate: PhotonDelegate?       // Notifies manager when status changes
    

    internal let particleDevice: ParticleDevice! // Reference to Particle-SDK device object
    
    
    var name: String
    {
        get {
            return particleDevice.name ?? "unknown"
        }
    }
    
    
    required init(device: ParticleDevice)
    {
        particleDevice  = device
        publish         = uninitializedString
    }

    /**
     * Refresh is expected to be called once after init
     * or in the unlikely event that the Photon reboots.
     */
    func refresh() -> Promise<Void>
    {
        print("refreshing \(name)")
        let publishPromise = readPublishName()
        let devicesPromise = refreshDevices()
        let supportedPromise = self.refreshSupported()
        let activitiesPromise = self.refreshActivities()
        let promises = [ publishPromise, devicesPromise, supportedPromise, activitiesPromise ]
        return when(fulfilled: promises)
    }
}

extension Photon
{
    func refreshDevices() -> Promise<Void>
    {
        devices = nil
        return readVariable("Devices")
        .then { result -> Void in
            self.devices = []
            self.parseDeviceNames(result!)
        }
    }
    
    
    private func parseDeviceNames(_ deviceString: String)
    {
        let items = deviceString.components(separatedBy: ",")
        guard items.count > 0 else {
            return
        }
        devices = Set<String>()
        for item in items
        {
            let itemComponents = item.components(separatedBy: ":")
            let lcDevice = itemComponents[0].localizedLowercase
            devices?.insert(lcDevice)
        }
        delegate?.device(named: self.name, hasDevices: devices!)
    }
    
    
    func refreshSupported() -> Promise<Void>
    {
        supported = nil
        return readVariable("Supported")
        .then { result -> Void in
            self.supported = []
            self.parseSupported(result!)
        }
    }
    
    
    private func parseSupported(_ supportedString: String)
    {
        print("parseSupported: \(supportedString)")
        let items = supportedString.components(separatedBy: ",")
        guard items.count > 0 else {
            return
        }
        supported = Set<String>()
        for item in items
        {
            let lcSupported = item.localizedLowercase
            supported?.insert(lcSupported)
        }
        print("calling device \(self.name) supports \(supported!)")
        delegate?.device(named: self.name, supports: supported!)
    }
    

    func refreshActivities() -> Promise<Void>
    {
        activities = nil
        return readVariable("Activities")
        .then { result -> Void in
            self.activities = [:]
            if let result = result, result != "" {
                self.parseActivities(result)
            }
        }
    }
    
    
    private func parseActivities(_ activitiesString: String)
    {
        let items = activitiesString.components(separatedBy: ",")
        guard items.count > 0 else {
            return
        }
        activities = [: ]
        for item in items
        {
            let itemComponents = item.components(separatedBy: ":")
            let lcActivity = itemComponents[0].localizedLowercase
            let lcValue = itemComponents[1].lowercased()
            activities![lcActivity] = Int(lcValue) ?? 0
        }
        delegate?.device(named: self.name, hasSeenActivities: activities!)
    }


    func readPublishName() -> Promise<Void>
    {
        return readVariable("PublishName")
        .then { result -> Void in
            self.publish = result ?? self.uninitializedString
        }
    }


    func readVariable(_ name: String) -> Promise<String?>
    {
        return Promise { fulfill, reject in
            guard particleDevice.variables[name] != nil else
            {
                print("Variable \(name) doesn't exist on photon \(self.name)")
                
                return fulfill(nil)
            }
            particleDevice.getVariable(name) { (result: Any?, error: Error?) in
                if let error = error {
                    reject(error)
                }
                else
                {
                    fulfill(result as? String)
                }
            }
        }
    }
}
