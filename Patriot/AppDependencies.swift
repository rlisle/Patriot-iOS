//
//  AppDependencies.swift
//  Patriot
//
//  This module contains relationships between modules.
//  It is accessible from the AppDelegate.
//
//  Created by Ron Lisle on 11/4/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit
import PromiseKit


class AppDependencies
{
    let hardware = PhotonManager()
    
    func configureActivities(viewController: ViewController)
    {
        let activitiesDataManager = ActivitiesDataManager(hardware: hardware)
        hardware.activityDelegate = activitiesDataManager
        hardware.deviceDelegate = activitiesDataManager
        activitiesDataManager.delegate = viewController
        
        //TODO: move to interactor. Here for initial testing only.
        hardware.login(user: Secret.LoginEmail, password: Secret.LoginPassword).then { _ -> Void in
            self.hardware.subscribeToEvents()
            //Allow this to proceed asynchronously
            self.hardware.discoverDevices()
        }.catch { error in
            //TODO: handle error
            print("ERROR: login failed: \(error)")
        }
    }
}
