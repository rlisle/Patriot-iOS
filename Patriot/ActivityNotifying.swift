//
//  ActivityNotifying.swift
//  Patriot
//
//  Created by Ron Lisle on 12/10/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import Foundation


protocol ActivityNotifying: class
{
    func supportedListChanged()
    func activityChanged(name: String, percent: Int)
}
