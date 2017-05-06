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

typealias CompletionPassingSet = (Set<String>) -> Void
typealias CompletionPassingDict = ([String: String]) -> Void


// This protocol represents each microcontroller
// Currently these are Particle.io Photons, but they
// might be something different in the future.
protocol HwController
{
    var devices: Set<String>?           { get }
    var supported: Set<String>?         { get }
    var activities: [String: String]?   { get }
    var publish: String                 { get }
    var name: String                    { get }
    init(device: ParticleDevice)
    func refresh() -> Promise<Void>
}

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
    var devices: Set<String>?           // Cached list of device names exposed by Photon
    var supported: Set<String>?         // Cached list of supported activities
    var activities: [String: String]?   // Optional list of current activities and state
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
        publish         = "uninitialized"
    }

    /**
     * Refresh is expected to be called once after init
     * or in the unlikely event that the Photon reboots.
     */
    func refresh() -> Promise<Void>
    {
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
        for item in items
        {
            let itemComponents = item.components(separatedBy: ":")
            let lcDevice = itemComponents[0].localizedLowercase
            devices?.insert(lcDevice)
        }
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
        let items = supportedString.components(separatedBy: ",")
        for item in items
        {
            let lcSupported = item.localizedLowercase
            supported?.insert(lcSupported)
        }
    }
    

    func refreshActivities() -> Promise<Void>
    {
        activities = nil
        return readVariable("Activities")
        .then { result -> Void in
            self.activities = [:]
            self.parseActivities(result!)
        }
    }
    
    
    private func parseActivities(_ activitiesString: String)
    {
        let items = activitiesString.components(separatedBy: ",")
        for item in items
        {
            let itemComponents = item.components(separatedBy: ":")
            let lcActivity = itemComponents[0].localizedLowercase
            let lcValue = itemComponents[1].lowercased()
            activities![lcActivity] = lcValue
        }
    }


    func readPublishName() -> Promise<Void>
    {
        return readVariable("PublishName")
        .then { result -> Void in
            self.publish = result!
        }
    }


    func readVariable(_ name: String) -> Promise<String?>
    {
        return Promise { fulfill, reject in
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
