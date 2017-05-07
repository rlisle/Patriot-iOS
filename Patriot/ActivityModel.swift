//
//  ActivityModel.swift
//  rvcp
//
//  Created by Ron Lisle on 10/7/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit


class Activity
{
    let name:       String
    var onImage:    UIImage
    var offImage:   UIImage
    var percent:    Int
    
    init(name: String, percent: Int = 0) {
        self.name    = name
        self.percent = percent
        self.onImage = #imageLiteral(resourceName: "LightOn")
        self.offImage = #imageLiteral(resourceName: "LightOff")
    }
}
