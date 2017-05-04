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
        print("p1. Photon refresh")
        return refreshDevices()
        .then {_ -> Promise<Void> in
            print("p2. ...refreshActivities")
            return self.refreshActivities()
        }.then { _ in
            print("p3. ...refreshSupported")
            return self.refreshSupported()
//            }.then {_ in
//                print("...fulfill")
//                fulfill()
            }
// Would prefer this, but can't figure out how to get compiler to accept it.
//            firstly {
//                return refreshDevices()
//            }.then { _ in
//                let supportedPromise = self.refreshSupported()
//                let activitiesPromise = self.refreshActivities()
//                return when(fulfilled: supportedPromise, activitiesPromise)
//            }
//        }
    }
}

extension Photon
{
    func refreshDevices() -> Promise<Void>
    {
        return Promise { fulfill, reject in
            devices = []
            particleDevice.getVariable("Devices") { (result: Any?, error: Error?) in
                if error == nil
                {
                    if let hwDevices = result as? String, hwDevices != ""
                    {
                        self.parseDeviceNames(hwDevices)
                        fulfill()
                    }
                } else {
                    print("  Error reading devices variable.")
                    reject(PhotonError.DeviceVariable)
                }
            }
        }
    }
    
    
    private func parseDeviceNames(_ deviceString: String)
    {
        print("p4. Parsing devices: \(deviceString)")
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
        return Promise { fulfill, reject in
            supported = []
            particleDevice.getVariable("Supported") { (result: Any?, error: Error?) in
                if error == nil
                {
                    print("p5.   refreshSupported no error, result = \(result!)")
                    if let hwSupported = result as? String, hwSupported != ""
                    {
                        self.parseSupported(hwSupported)
                        fulfill()
                    }
                } else {
                    print("  Error reading supported variable.")
                    reject(PhotonError.SupportedVariable)
                }
            }
        }
    }
    
    
    private func parseSupported(_ supportedString: String)
    {
        print("p6. Parsing supported: \(supportedString)")
        let items = supportedString.components(separatedBy: ",")
        for item in items
        {
            let lcSupported = item.localizedLowercase
            supported?.insert(lcSupported)
        }
    }
    

    func refreshActivities() -> Promise<Void>
    {
        return Promise { fulfill, reject in
            guard particleDevice.variables["Activities"] != nil else
            {
                fulfill()
                
                return
            }
            activities = [: ]
            particleDevice.getVariable("Activities") { (result: Any?, error: Error?) in
                if error == nil
                {
                    print("p7. Refresh activities read \(result)")
                    if let hwActivities = result as? String, hwActivities != "" {
                        self.parseActivities(hwActivities)
                    }
                    print("p8. Activities result: \(self.activities)")
                    fulfill()
                } else {
                    print("  Error reading activities variable: \(error!)")
                    reject(PhotonError.ActivitiesVariable)
                }
            }
        }
    }
    
    
    private func parseActivities(_ activitiesString: String)
    {
        print("p9. Parsing activities: \(activitiesString)")
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
        return Promise { fulfill, reject in
            particleDevice.getVariable("Publish") { (result: Any?, error: Error?) in
                if error == nil
                {
                    print("p10. Publish name = \(result!)")
                    self.publish = result as! String
                    fulfill()
                } else {
                    print("  Error reading publish variable.")
                    reject(PhotonError.PublishVariable)
                }
            }
        }
    }

    func readVariable(name: String) -> Promise<String?>
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
