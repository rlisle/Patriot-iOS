//
//  ActivityModel.swift
//  rvcp
//
//  Created by Ron Lisle on 10/7/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import Foundation


struct Activity
{
    let name:    String
    let command: String
    var percent: Int
    
    init(name: String, command: String, percent: Int) {
        self.name    = name
        self.command = command
        self.percent = percent
    }
}
