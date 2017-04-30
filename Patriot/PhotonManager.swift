//
//  PhotonManager.swift
//  rvcp
//
//  This class manages the collection of Photon devices
//
//  Discovery will search for all the Photon devices on the network.
//  When a new device is found, it will be added to the photons collection
//  and a delegate or notification sent.
//  This is the anticipated way of updating displays, etc.
//
//  It will subscribe to particle events in order to track activity changes
//  in addition to new Photons coming online.
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


enum ParticleSDKError : Error
{
    case invalidUserPassword
    case invalidToken
}


class PhotonManager: NSObject
{
    // Singleton pattern. Use sharedInstance instead of instantiating a new objects.
    static let sharedInstance = PhotonManager()

    var deviceDelegate:     DeviceNotifying?
    var activityDelegate:   ActivityNotifying?
    
    var photons: [String: Photon] = [: ]   // All the particle devices attached to logged-in user's account
    let eventName          = "patriot"
    var deviceNames:        [String] = []       // Names exposed by the "Devices" variables
    var supportedNames:     Set<String> = []    // Activity names exposed by the "Supported" variables
    var currentActivities:  [String] = []       // List of currently on activities reported by Master
    var master:             Photon?
    

    /**
    * Login to your particle.io account
    * The particle SDK will use the returned token in subsequent calls.
    * We don't have to save it.
    */
    func loginToParticleCloud(user: String, password: String, completionHandler: @escaping(Error?) -> Void)
    {
        print("loginToParticleCloud")
        ParticleCloud.sharedInstance().login(withUser: user, password: password, completion: completionHandler)
    }


    func performDiscovery()
    {
        print("PhotonManager performDiscovery")
//        self.getAllPhotonDevices().then { allPhotons in
//            self.refreshCurrentActivities()
//            self.refreshDeviceNames()
//            self.refreshSupportedNames()
//        }
    }
    
    
    /**
     * Locate all the particle.io devices
     */
    func getAllPhotonDevices() -> Promise<[String: Photon]>
    {
        return Promise { fulfill, reject in
            print("getAllPhotonDevices")
            ParticleCloud.sharedInstance().getDevices { (devices: [ParticleDevice]?, error: Error?) in
                guard error == nil else {
                    reject(error!)
                    
                    return
                }
                self.addAllPhotonsToCollection(devices: devices)
                fulfill(self.photons)
            }
        }
    }


    func addAllPhotonsToCollection(devices: [ParticleDevice]?)
    {
        self.photons = [: ]
        if let particleDevices = devices
        {
            for device in particleDevices
            {
                if self.isValidPhoton(device)
                {
                    if let name = device.name?.lowercased()
                    {
                        self.photons[name] = Photon(device: device)
                        deviceDelegate?.deviceFound(name: name)
                    }
                }
            }
        }
    }
    
    
    func isValidPhoton(_ device: ParticleDevice) -> Bool
    {
        return device.connected
    }
    
    
    func getMasterDevice(name: String)
    {
        master = self.getPhoton(named: name)
    }
    
    
    func getPhoton(named: String) -> Photon?
    {
        let lowerCaseName = named.lowercased()
        let photon = photons[lowerCaseName]
        
        return photon
    }
}


extension PhotonManager: Hardware
{
    func discoverDevices()
    {
        print("discoveryDevices")
        performDiscovery()
    }
    
    
    func getAllDeviceNames() -> [String]
    {
        print("getAllDeviceNames returning \(deviceNames)")
        
        return self.deviceNames
    }
    
    
    func getAllSupportedNames() -> Set<String>
    {
        print("getAllSupportedNames returning \(supportedNames)")
        
        return supportedNames
    }

    
    //TODO: either remove the callback, or else initiate a read
    //TODO: convert to promise
    func getCurrentActivities(completionHandler: @escaping ([String]) -> Void)
    {
        print("getCurrentActivities returning \(currentActivities)")
        completionHandler(currentActivities)
    }
    
    
    func sendActivityCommand(command: String, percent: Int)
    {
        print("sendActivityCommand: \(command) percent: \(percent)")
        let data = command + ":" + String(percent)
        print("Setting activity: \(data)")
        ParticleCloud.sharedInstance().publishEvent(withName: eventName, data: data, isPrivate: false, ttl: 60)
        { (error:Error?) in
            if let e = error
            {
                print("Error publishing event \(e.localizedDescription)")
            }
        }
    }
}

extension PhotonManager
{
//    /**
//     * Read the Devices variable from each Photon and add to deviceNames
//     * TODO: provide a completion callback or flag
//     */
//    func refreshDeviceNames()
//    {
//        print("refreshDeviceNames")
//        deviceNames = []
//        for (name, photon) in photons
//        {
//            let particleDevice = photon.particleDevice
//            if particleDevice?.variables["Devices"] != nil
//            {
//                print("  reading Devices variable from \(name)")
//                particleDevice?.getVariable("Devices") { (result: Any?, error: Error?) in
//                    if error == nil
//                    {
//                        if let devices = result as? String, devices != ""
//                        {
//                            self.deviceNames += self.parseDeviceNames(devices)
//                            print("  Updated device names = \(self.deviceNames)")
//                        }
//                    } else {
//                        print("  Error reading devices variable.")
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    private func parseDeviceNames(_ devices: String) -> [String]
//    {
//        print("Parsing devices: \(devices)")
//        var newDevices: [String] = []
//        let items = devices.components(separatedBy: ",")
//        for item in items
//        {
//            let itemComponents = item.components(separatedBy: ":")
//            let lcDevice = itemComponents[0].localizedLowercase
//            newDevices.append(lcDevice)
//            self.deviceDelegate?.deviceFound(name: lcDevice)
//        }
//        
//        return newDevices
//    }
    
    
    func refreshSupportedNames()
    {
        print("refreshSupportedNames")
        supportedNames = []
        for (name, photon) in photons
        {
            let particleDevice = photon.particleDevice
            if particleDevice?.variables["Supported"] != nil
            {
                print("  reading Supported variable from \(name)")
                particleDevice?.getVariable("Supported") { (result: Any?, error: Error?) in
                    if error == nil
                    {
                        if let supported = result as? String, supported != ""
                        {
                            self.supportedNames = self.supportedNames.union(self.parseSupportedNames(supported))
                        }
                    } else {
                        print("Error reading Supported variable. Skipping this device.")
                    }
                    print("Updated Supported names = \(self.supportedNames)")
                    self.activityDelegate?.supportedListChanged(list: self.supportedNames)
                }
            }
        }
    }
    
    
    private func parseSupportedNames(_ supported: String) -> Set<String>
    {
        print("Parsing supported names: \(supported)")
        var newSupported: Set<String> = []
        let items = supported.components(separatedBy: ",")
        for item in items
        {
            let lcItem = item.localizedLowercase
            print("New supported = \(lcItem)")
            newSupported.insert(lcItem)
        }
        
        return newSupported
    }
    
    
    func refreshCurrentActivities()
    {
        print("refreshCurrentActivities")
        currentActivities = []
        master?.particleDevice.getVariable("Activities")
        { (result:Any?, error:Error?) in
            if error == nil
            {
                if let activities = result as? String
                {
                    print("Activities = \(activities)")
                    let items = activities.components(separatedBy: ",")
                    for item in items
                    {
                        self.currentActivities += [item]
                        self.activityDelegate?.activityChanged(event: item)
                    }
                }
                
            } else {
                print("Error reading activities variable")
            }
        }
    }
}
