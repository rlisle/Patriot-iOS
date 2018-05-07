//
//  AppFactory.swift
//  Patriot
//
//  This module manages the creation and relationship between modules.
//  It is accessible from the AppDelegate.
//  It has a lifetime of the entire app.
//
//  Created by Ron Lisle on 11/4/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit
import PromiseKit

class AppFactory
{
    let window: UIWindow
    let hwManager = PhotonManager()
    let store = UserDefaultsSettingsStore()
    let settings: Settings
    
    init(window: UIWindow)
    {
        self.window = window
        settings = Settings(store: store)
    }
    
    func configureActivities(viewController: ViewController)
    {
        viewController.settings = settings
        let activitiesDataManager = ActivitiesDataManager(hardware: hwManager)
        viewController.dataManager = activitiesDataManager
        hwManager.activityDelegate = activitiesDataManager
        hwManager.deviceDelegate = activitiesDataManager
        activitiesDataManager.delegate = viewController

        loginToParticle()
    }
    
    func loginToParticle()
    {
        hwManager.login(user: settings.particleUser, password: settings.particlePassword).then { _ -> Void in
            
            self.hwManager.subscribeToEvents()
            _ = self.hwManager.discoverDevices()
            }.catch { error in
                print("ERROR: login failed: \(error)")
        }
    }
}
