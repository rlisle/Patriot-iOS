//
//  ActivityDisplayModel.swift
//  Patriot
//
//  Created by Ron Lisle on 11/5/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit


struct ActivityDisplayData : Equatable
{
    let name:       String
    let onImage:    UIImage
    let offImage:   UIImage
    var percent     = 0
}


func == (leftSide: ActivityDisplayData, rightSide: ActivityDisplayData) -> Bool
{
    let onImagesAreEqual  = leftSide.onImage.isEqual(rightSide.onImage)
    let offImagesAreEqual = leftSide.offImage.isEqual(rightSide.offImage)
    let namesAreEqual     = (leftSide.name == rightSide.name)
    let percentsAreEqual  = (leftSide.percent == rightSide.percent)
    
    return onImagesAreEqual && offImagesAreEqual && namesAreEqual && percentsAreEqual
}
