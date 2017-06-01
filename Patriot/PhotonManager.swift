//
//  PhotonManager.swift
//  Patriot
//
//  This class manages the collection of Photon devices
//
//  Discovery will search for all the Photon devices on the network.
//  When a new device is found, it will be added to the photons collection
//  and a delegate or notification sent.
//  This is the anticipated way of updating displays, etc.
//
//  The current activity state will be gleaned from the exposed Activities
//  properties of one or more Photons initially, but then tracked directly
//  after initialization by subscribing to particle events.
//  Subscribing to particle events will also allow detecting new Photons
//  as they come online and start issuing 'alive' events.
//
//  This file uses the Particle SDK: 
//      https://docs.particle.io/reference/ios/#common-tasks
//
//  Created by Ron Lisle on 11/13/16.
//  Copyright © 2016, 2017 Ron Lisle. All rights reserved.
//

import Foundation
import Particle_SDK
import PromiseKit


protocol PhotonDelegate
{
    func device(named: String, hasDevices: Set<String>)
    func device(named: String, supports: Set<String>)
    func device(named: String, hasSeenActivities: [String: Int])
}

enum ParticleSDKError : Error
{
    case invalidUserPassword
    case invalidToken
}


class PhotonManager: NSObject, HwManager
{
    var subscribeHandler:   Any?
    var deviceDelegate:     DeviceNotifying?
    var activityDelegate:   ActivityNotifying?
    
    var photons: [String: Photon] = [: ]   // All the particle devices attached to logged-in user's account
    let eventName          = "patriot"
    var deviceNames        = Set<String>()      // Names exposed by the "Devices" variables
    var supportedNames     = Set<String>()      // Activity names exposed by the "Supported" variables
    var currentActivities:  [String: Int] = [: ] // List of currently on activities reported by Master
    

    /**
    * Login to the particle.io account
    * The particle SDK will use the returned token in subsequent calls.
    * We don't have to save it.
    */
    func login(user: String, password: String) -> Promise<Void>
    {
        return Promise { fulfill, reject in
            ParticleCloud.sharedInstance().login(withUser: user, password: password) { (error) in
                if let error = error {
                    return reject(error)
                }
                return fulfill()
            }
        }
    }


    @discardableResult func discoverDevices() -> Promise<Void>
    {
        return getAllPhotonDevices()
    }
    
    
    /**
     * Locate all the particle.io devices
     */
    func getAllPhotonDevices() -> Promise<Void>
    {
        return Promise { fulfill, reject in
            ParticleCloud.sharedInstance().getDevices { (devices: [ParticleDevice]?, error: Error?) in
                if error != nil {
                    print("Error: \(error!)")
                    reject(error!)
                }
                else
                {
                    self.addAllPhotonsToCollection(devices: devices)
                    .then { _ -> Void in
                        print("All photons added to collection")
                        self.activityDelegate?.supportedListChanged()
                        fulfill()
                    }.catch { error in
                        reject(error)
                    }
                }
            }
        }
    }


    func addAllPhotonsToCollection(devices: [ParticleDevice]?) -> Promise<Void>
    {
        self.photons = [: ]
        var promises = [Promise<Void>]()
        if let particleDevices = devices
        {
            for device in particleDevices
            {
                if isValidPhoton(device)
                {
                    if let name = device.name?.lowercased()
                    {
                        print("Adding photon \(name) to collection")
                        let photon = Photon(device: device)
                        photon.delegate = self
                        self.photons[name] = photon
                        self.deviceDelegate?.deviceFound(name: name)
                        let promise = photon.refresh()
                        promises.append(promise)
                    }
                }
            }
            return when(fulfilled: promises)
        }
        return Promise(error: NSError(domain: "No devices", code: 0, userInfo: nil))
    }
    
    
    func isValidPhoton(_ device: ParticleDevice) -> Bool
    {
        return device.connected
    }
    
    
    func getPhoton(named: String) -> Photon?
    {
        let lowerCaseName = named.lowercased()
        let photon = photons[lowerCaseName]
        
        return photon
    }

    
    func sendCommand(activity: String, percent: Int)
    {
        print("sendCommand: \(activity) percent: \(percent)")
        let data = activity + ":" + String(percent)
        print("Publishing event: \(eventName) data: \(data)")
        ParticleCloud.sharedInstance().publishEvent(withName: eventName, data: data, isPrivate: true, ttl: 60)
        { (error:Error?) in
            if let e = error
            {
                print("Error publishing event \(e.localizedDescription)")
            }
        }
    }
    
    func subscribeToEvents()
    {
        subscribeHandler = ParticleCloud.sharedInstance().subscribeToMyDevicesEvents(withPrefix: eventName, handler: { (event: ParticleEvent?, error: Error?) in
            if let _ = error {
                print("Error subscribing to events")
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    //print("Subscribe: received event with data \(String(describing: event?.data))")
                    if let eventData = event?.data {
                        let splitArray = eventData.components(separatedBy: ":")
                        let name = splitArray[0].lowercased()
                        if let percent: Int = Int(splitArray[1]), percent >= 0, percent <= 100
                        {
                            self.activityDelegate?.activityChanged(name: name, percent: percent)
                        }
                        else
                        {
//                            print("Event data is not a valid number")
                        }
                    }
                    
                })
            }
        })
    }
}


extension PhotonManager
{
//    private func parseSupportedNames(_ supported: String) -> Set<String>
//    {
//        print("6. Parsing supported names: \(supported)")
//        var newSupported: Set<String> = []
//        let items = supported.components(separatedBy: ",")
//        for item in items
//        {
//            let lcItem = item.localizedLowercase
//            print("7. New supported = \(lcItem)")
//            newSupported.insert(lcItem)
//        }
//        
//        return newSupported
//    }
    
    
//    func refreshCurrentActivities()
//    {
//        print("8. refreshCurrentActivities")
//        currentActivities = [: ]
//        for (name, photon) in photons
//        {
//            let particleDevice = photon.particleDevice
//            if particleDevice?.variables["Activities"] != nil
//            {
//                print("9.  reading Activities variable from \(name)")
//                particleDevice?.getVariable("Activities") { (result: Any?, error: Error?) in
//                    if error == nil
//                    {
//                        if let activities = result as? String, activities != ""
//                        {
//                            print("10. Activities = \(activities)")
//                            let items = activities.components(separatedBy: ",")
//                            for item in items
//                            {
//                                let parts = item.components(separatedBy: ":")
//                                self.currentActivities[parts[0]] = parts[1]
////                                self.activityDelegate?.activityChanged(event: item)
//                            }
//                        }
//                    } else {
//                        print("Error reading Supported variable. Skipping this device.")
//                    }
//                    print("11. Updated Supported names = \(self.supportedNames)")
//                    self.activityDelegate?.supportedListChanged()
//                }
//            }
//        }
//    }
}


// These methods report the capabilities of each photon asynchronously
extension PhotonManager: PhotonDelegate
{
    func device(named: String, hasDevices: Set<String>)
    {
        print("device named \(named) hasDevices \(hasDevices)")
        deviceNames = deviceNames.union(hasDevices)
    }
    
    
    func device(named: String, supports: Set<String>)
    {
        print("device named \(named) supports \(supports)")
        supportedNames = supportedNames.union(supports)
    }
    
    
    func device(named: String, hasSeenActivities: [String: Int])
    {
        print("device named \(named) hasSeenActivities \(hasSeenActivities)")
        hasSeenActivities.forEach { (k,v) in currentActivities[k] = v }
    }
}


extension PhotonManager
{
    func readVariable(device: ParticleDevice, name: String) -> Promise<String>
    {
        return Promise { fulfill, reject in
            device.getVariable("Supported")
            { (result: Any?, error: Error?) in
                if let variable = result as? String
                {
                    fulfill(variable)
                }
                else
                {
                    reject(error!)
                }
            }
        }
    }
}
