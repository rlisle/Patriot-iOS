//
//  AppDelegate.swift
//  Patriot
//
//  This class starts up the application.
//  It creates the AppFactory and Flow objects.
//
//  Created by Ron Lisle on 4/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

//    #if DEBUG
//    var window: UIWindow? = FBTweakShakeWindow(frame: UIScreen.main.bounds)
//    #else
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
//    #endif

    var appFactory: AppFactory?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        appFactory = AppFactory(window: window!)
        
        //TODO: move to factory
        disableSleepWhilePluggedIn()
        
        return true
    }
    

    //TODO: move to factory
    func disableSleepWhilePluggedIn()
    {
        UIDevice.current.isBatteryMonitoringEnabled = true
        if UIDevice.current.batteryState != .unplugged
        {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

