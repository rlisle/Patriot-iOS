//
//  Colors.swift
//  rvcp
//
//  Created by Ron Lisle on 11/20/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit


class Colors
{
    let colorTop = UIColor.gray.cgColor
    let colorBottom = UIColor.darkGray.cgColor
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom ]
        gl.locations = [ 0.0, 1.0 ]
    }
}
