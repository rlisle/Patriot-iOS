//
//  ActivitiesDataManager.swift
//  rvcp
//
//  Created by Ron Lisle on 11/5/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit

protocol ActivitiesDisplaying
{
    func activitiesChanged()
    func activityDidChange(index: Int, percent: Int)
}


class ActivitiesDataManager
{
    var activities:     [ Activity ] = []
    var hardware:       HwManager?
    var delegate:       ActivitiesDisplaying?
    
    init()
    {
        activities.append(Activity(name: "booth", command: "booth", percent: 0))
        activities.append(Activity(name: "coffee", command: "coffee", percent: 0))
        activities.append(Activity(name: "computer", command: "computer", percent: 0))
        activities.append(Activity(name: "ronslight", command: "ronscouch", percent: 0))
        activities.append(Activity(name: "shelleyslight", command: "shelleyscouch", percent: 0))
        activities.append(Activity(name: "piano", command: "piano", percent: 0))
        activities.append(Activity(name: "tv", command: "tv", percent: 0))
        activities.append(Activity(name: "dishes", command: "dishes", percent: 0))
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
        let command = activities[at].command
        hardware?.sendActivityCommand(command: command, percent: percent)
    }
    
    
    func refreshActivities(supported: Set<String>)
    {
        var index = 0
        for name in supported
        {
            print("Adding activity \(name)")
            self.activities.append(Activity(name: name, command: name, percent: 0))
            
            //TODO: determine actual initial activity state. It might be on.
            index = index + 1
        }
        delegate?.activitiesChanged()
    }
}


extension ActivitiesDataManager: ActivityNotifying
{
    func supportedListChanged(list: Set<String>)
    {
        print("ActivitiesDataManager supportedListChanged: \(list)")
        //TODO: this needs to update the VC
        refreshActivities(supported: list)
        //delegate?.setActivitiesData(activities)
        
    }

    // Handle activity:percent events
    func activityChanged(event: String)
    {
        print("ActivityDataManager: ActivityChanged: \(event)")
        let splitArray = event.components(separatedBy: ":")
        let isOn = splitArray.last!.caseInsensitiveCompare("0") != .orderedSame
        let percent = isOn ? 100 : 0
        if let index = activities.index(where: {$0.name == splitArray.first})
        {
            activities[index].percent = percent
            delegate?.activityDidChange(index: index, percent: percent)
        }
    }
}
