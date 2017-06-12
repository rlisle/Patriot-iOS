//
//  SettingsModel.swift
//  Patriot
//
//  This object implements a model for persisting user settings.
//  It is expected to be injected into classes needing it.
//
//  Created by Ron Lisle on 6/7/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation

// We'll use the default string rawValue for the key in the store
enum SettingsKey: String
{
    case beaconUUID
    case beaconTransmitOn
    case beaconIdentifier
}


protocol SettingsStore
{
    func getBool(forKey: SettingsKey) -> Bool?
    func set(_ bool: Bool?, forKey: SettingsKey)
    func getString(forKey: SettingsKey) -> String?
    func set(_ string: String?, forKey: SettingsKey)
}


class UserDefaultsSettingsStore: SettingsStore
{
    let userDefaults = UserDefaults.standard
    
    func getBool(forKey key: SettingsKey) -> Bool?
    {
        return userDefaults.bool(forKey: key.rawValue)
    }
    
    
    func set(_ bool: Bool?, forKey key: SettingsKey)
    {
        userDefaults.set(bool, forKey: key.rawValue)
    }
    
    
    func getString(forKey key: SettingsKey) -> String?
    {
        return userDefaults.string(forKey: key.rawValue)
    }
    
    
    func set(_ string: String?, forKey key: SettingsKey)
    {
        userDefaults.set(string, forKey: key.rawValue)
    }
}

class SettingsModel
{
//    var beaconUUID: String = "00000000-0000-0000-0000-000000000000"
//    var beaconTransmit: Bool = false
//    var beaconIdentifier: String = "PatriotBeacon"
    let store: SettingsStore
    
    var beaconUUID: String? {
        get {
            return store.getString(forKey: .beaconUUID)
        }
        set {
            store.set(newValue, forKey: .beaconUUID)
        }
    }
    
    
    init(store: SettingsStore)
    {
        self.store = store
    }
}
