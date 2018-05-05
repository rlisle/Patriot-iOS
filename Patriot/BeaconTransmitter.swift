//
//  BeaconTransmitter.swift
//  Patriot
//
//  Created by Ron Lisle on 6/14/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

// iOS 10 changed the name of the state variable, but the values are the same
// So we'll copy the states to this enum that can be used in either iOS 10 or before
enum BeaconTransmittingState
{
    case poweredOff
    case poweredOn
    case resetting
    case unauthorized
    case unknown
    case unsupported
    case transmitting
    case error
}
    
    
protocol BeaconTransmitting
{
    var state: BeaconTransmittingState { get }
    func enableTransmitting(_ enable: Bool)
}


class BeaconTransmitter: NSObject
{
    var state: BeaconTransmittingState
    
    //TODO: change to subset protocol (eg. BeaconSettings)
    var settings: Settings
    
    fileprivate var peripheralManager: CBPeripheralManager?
    
    fileprivate let identifier = Bundle.main.bundleIdentifier!
    fileprivate let major: CLBeaconMajorValue = 1
    fileprivate let minor: CLBeaconMinorValue = 0
    
    init(settings: Settings)
    {
        state = .unknown
        self.settings = settings
    }
}


extension BeaconTransmitter: BeaconTransmitting
{
    func enableTransmitting(_ enable: Bool)
    {
        if enable == true
        {
            print("BEACON TRANSMITTER: Started")
            let queue = DispatchQueue.global()
            peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        }
        else
        {
            if peripheralManager != nil
            {
                print("BEACON TRANSMITTER: Stopped")
                peripheralManager!.stopAdvertising()
                peripheralManager = nil
                state = .poweredOff
            }
        }
    }
}

extension BeaconTransmitter: CBPeripheralManagerDelegate
{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        peripheral.stopAdvertising()
        print("The peripheral state is ")
        switch peripheral.state
        {
        case .poweredOff:
            print("Powered off")
            state = .poweredOff
        case .poweredOn:
            print("Powered on")
            state = .poweredOn
        case .resetting:
            print("Resetting")
            state = .resetting
        case .unauthorized:
            print("Unauthorized")
            state = .unauthorized
        case .unknown:
            print("Unknown")
            state = .unknown
        case .unsupported:
            print("Unsupported")
            state = .unsupported
        }
        
        if state == .poweredOn
        {
            guard let uuid = UUID(uuidString: settings.beaconUUID) else
            {
                print("Invalid transmit beacon UUID")
                
                return
            }
            let major = CLBeaconMajorValue(settings.beaconMajor)
            let minor = CLBeaconMinorValue(settings.beaconMinor)
            let identifier = settings.beaconIdentifier
            let region = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
            if let dataToBeAdvertised = region.peripheralData(withMeasuredPower: nil) as? [String: Any]
            {
                peripheral.startAdvertising(dataToBeAdvertised)
            }
            else
            {
                print("Unable to start beacon")
                state = .error
            }
        }
    }
    

    // Either the transmitter turned on or it didn't
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        state = (error == nil) ? .transmitting : .error
    }
}

