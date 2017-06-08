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

enum SettingsKey: String
{
    case beaconUUID
    case beaconTransmitOn
    case beaconIdentifier
}


protocol SettingsStore
{
    func set(_ bool: Bool, forKey: SettingsKey)
    func set(_ string: String, forKey: SettingsKey)
}


class UserDefaultsSettingsStore: SettingsStore
{
    func set(_ bool: Bool, forKey: SettingsKey)
    {
    
    }
    
    
    func set(_ string: String, forKey: SettingsKey)
    {
    
    }
}

class SettingsModel
{
//    var beaconUUID: String = "00000000-0000-0000-0000-000000000000"
//    var beaconTransmit: Bool = false
//    var beaconIdentifier: String = "PatriotBeacon"
    let store: SettingsStore
    
    init(store: SettingsStore)
    {
        self.store = store
    }
}
