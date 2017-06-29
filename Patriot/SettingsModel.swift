//
//  SettingsModel.swift
//  Patriot
//
//  This object implements a model for persisting user settings.
//  It is expected to be injected into classes needing it.
//  Defaults are provided if not previously saved.
//
//  Created by Ron Lisle on 6/7/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation

// We'll use the default string rawValue for the key in the store
enum SettingsKey: String
{
    case beaconUUID
    case beaconMajor
    case beaconMinor
    case isBeaconTransmitOn
    case beaconIdentifier
}


protocol SettingsStore
{
    func getBool(forKey: SettingsKey) -> Bool?
    func set(_ bool: Bool?, forKey: SettingsKey)
    func getInt(forKey: SettingsKey) -> Int?
    func set(_ int: Int?, forKey: SettingsKey)
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
    
    
    func getInt(forKey key: SettingsKey) -> Int?
    {
        return userDefaults.integer(forKey: key.rawValue)
    }
    
    
    func set(_ int: Int?, forKey key: SettingsKey)
    {
        userDefaults.set(int, forKey: key.rawValue)
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

class Settings
{
    let store: SettingsStore
    
    var beaconUUID: String
    {
        get {
            if let uuid = store.getString(forKey: .beaconUUID)
            {
                return  uuid
            }
            let uuid = UUID().uuidString
            store.set(uuid, forKey: .beaconUUID)
            return uuid
        }
        set {
            store.set(newValue, forKey: .beaconUUID)
        }
    }
    
    var beaconMajor: Int
    {
        get {
            return store.getInt(forKey: .beaconMajor) ?? 1
        }
        set {
            store.set(newValue, forKey: .beaconMajor)
        }
    }
    
    
    var beaconMinor: Int {
        get {
            return store.getInt(forKey: .beaconMinor) ?? 1
        }
        set {
            store.set(newValue, forKey: .beaconMinor)
        }
    }
    
    
    var isBeaconTransmitOn: Bool {
        get {
            return store.getBool(forKey: .isBeaconTransmitOn) ?? false
        }
        set {
            store.set(newValue, forKey: .isBeaconTransmitOn)
        }
    }
    
    var beaconIdentifier: String {
        get {
            return store.getString(forKey: .beaconIdentifier) ?? "Unnamed"
        }
        set {
            store.set(newValue, forKey: .beaconIdentifier)
        }
    }
    
    
    init(store: SettingsStore)
    {
        self.store = store
    }
}
