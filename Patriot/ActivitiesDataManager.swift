//
//  ActivitiesDataManager.swift
//  rvcp
//
//  Created by Ron Lisle on 11/5/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit


class ActivitiesDataManager
{
    var activities:     [ Activity ] = []
    let hardware:       HwManager
    weak var delegate:  ActivityNotifying?
    
    init(hardware: HwManager)
    {
        self.hardware = hardware
//        activities.append(Activity(name: "booth", command: "booth", percent: 0))
//        activities.append(Activity(name: "coffee", command: "coffee", percent: 0))
//        activities.append(Activity(name: "computer", command: "computer", percent: 0))
//        activities.append(Activity(name: "ronslight", command: "ronscouch", percent: 0))
//        activities.append(Activity(name: "shelleyslight", command: "shelleyscouch", percent: 0))
//        activities.append(Activity(name: "piano", command: "piano", percent: 0))
//        activities.append(Activity(name: "tv", command: "tv", percent: 0))
//        activities.append(Activity(name: "dishes", command: "dishes", percent: 0))
    }


    func isActivityOn(at: Int) -> Bool
    {
//        return activities[at].percent > 0
return false
    }

    
    func toggleActivity(at: Int)
    {
        let isOn = isActivityOn(at: at)
        setActivity(at: at, percent: isOn ? 0 : 100)
    }

    
    func setActivity(at: Int, percent: Int)
    {
        activities[at].percent = percent
        let name = activities[at].name
        hardware.sendCommand(activity: name, percent: percent)
    }
    
    
    func refreshActivities(supported: Set<String>)
    {
        print("refreshActivities: \(supported)")
        for name in supported
        {
            print("ActivitiesDM: Adding activity \(name)")
            self.activities.append(Activity(name: name, percent: 0))
            
            //TODO: determine actual initial activity state. It might be on.
            
        }
        delegate?.supportedListChanged()
    }
}


extension ActivitiesDataManager: ActivityNotifying
{
    func supportedListChanged()
    {
        print("ActivitiesDataManager supportedListChanged")
        let list = hardware.supportedNames
        refreshActivities(supported: list)
    }

    // Handle activity:percent events
    func activityChanged(name: String, percent: Int)
    {
        print("ActivityDataManager: ActivityChanged: \(name)")
        if let index = activities.index(where: {$0.name == name})
        {
            print("   index of activity = \(index)")
            activities[index].percent = percent
        }
        delegate?.activityChanged(name: name, percent: percent)
    }
}


extension ActivitiesDataManager: DeviceNotifying
{
    func deviceFound(name: String)
    {
        print("Device found: \(name)")
        //Currently not really doing anything with this.
        //This will become important once we allow the app to 
        //configure/program device activites
    }
    
    
    func deviceLost(name: String)
    {
        print("Device lost: \(name)")
        //Ditto above
    }
}
