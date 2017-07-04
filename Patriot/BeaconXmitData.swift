//
//  BeaconXmitData.swift
//  Patriot
//
//  This model extends Settings to provide persisted 
//  settings with specific defaults.
//
//  Created by Ron Lisle on 6/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation

class BeaconXmitData
{
    let store: Settings
    
    var identifier: String {
        get {
            return store.beaconIdentifier
        }
        set {
            store.beaconIdentifier = newValue
        }
    }
    
    var uuid: String {
        get {
            return store.beaconUUID
        }
        set {
            store.beaconUUID = newValue
        }
    }

    var major: Int {
        get {
            return store.beaconMajor
        }
        set {
            store.beaconMajor = newValue
        }
    }
    
    var minor: Int {
        get {
            return store.beaconMinor
        }
        set {
            store.beaconMinor = newValue
        }
    }
    
    var isEnabled: Bool {
        get {
            return store.isBeaconTransmitOn
        }
        set {
            store.isBeaconTransmitOn = newValue
        }
    }

    
    init(store: Settings)
    {
        self.store = store
    }

    
    func isDataValid() -> Bool
    {
        return isValidUUID() && isValidMajor() && isValidMinor()
    }
    
    
    fileprivate func isValidUUID() -> Bool
    {
        if uuid.characters.count != 32
        {
            return false
        }
        return true
    }
    
    
    fileprivate func isValidMajor() -> Bool
    {
        if major >= 0 && major <= 255
        {
            return true
        }
        return false
    }
    
    
    fileprivate func isValidMinor() -> Bool
    {
        if minor >= 0 && minor <= 255
        {
            return true
        }
        return false
    }
}
