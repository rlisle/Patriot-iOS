//
//  AppDelegate.swift
//  Patriot
//
//  Created by Ron Lisle on 4/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let appFactory = AppFactory()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        disableSleepWhilePluggedIn()
        
        return true
    }
    
    
    func disableSleepWhilePluggedIn()
    {
        UIDevice.current.isBatteryMonitoringEnabled = true
        if UIDevice.current.batteryState != .unplugged
        {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

