//
//  SettingsExtension.swift
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
//TODO: This is not extensible. Cases cannot be extended.
//      Use strings + unit tests
enum SettingsKey: String
{
    case particleUser
    case particlePassword
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
    
    init(store: SettingsStore)
    {
        self.store = store
    }
}


extension Settings
{
    var particleUser: String
    {
        get {
            return store.getString(forKey: .particleUser) ?? ""
        }
        set {
            store.set(newValue, forKey: .particleUser)
        }
    }
    
    
    var particlePassword: String {
        get {
            return store.getString(forKey: .particlePassword) ?? ""
        }
        set {
            store.set(newValue, forKey: .particlePassword)
        }
    }
}
