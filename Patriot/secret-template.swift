//
//  secret-template.swift
//  Patriot
//
//  This file contains Particle.io login credentials.
//  1. Enter your credentials
//  2. Rename the file from secret-template to secret
//  3. Add this file to the Patriot target
//  4. Add this file to the IntegrationTests if adding a test device
//
//  Created by Ron Lisle on 4/8/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation


struct Secret
{
    //A separate test account for running integration tests
    static let TestEmail        = "<YourTestParticleLogin>"
    static let TestPassword     = "<YourTestParticlePW>"
    static let TestDeviceId     = "<YourTestDeviceId>"
}
