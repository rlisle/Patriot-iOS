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
    
    var activitiesViewController: ViewController?
    var activitiesDataManager: ActivitiesDataManager?
    
    
    func configureActivities(viewController: ViewController)
    {
        activitiesViewController = viewController
        activitiesDataManager = ActivitiesDataManager()
        var hardware = PhotonManager.sharedInstance
        activitiesDataManager?.hardware = hardware
        hardware.activityDelegate = activitiesDataManager
        
        //TODO: move to interactor. Here for initial testing only.
        hardware.login(user: Secret.LoginEmail, password: Secret.LoginPassword).then { _ -> Void in
            hardware.discoverDevices()
        }
    }
}
