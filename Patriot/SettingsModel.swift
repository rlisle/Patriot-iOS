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

class SettingsModel
{
    var beaconUUID: String = "00000000-0000-0000-0000-000000000000"
    var beaconTransmit: Bool = false
    var beaconIdentifier: String = "PatriotBeacon"
}
