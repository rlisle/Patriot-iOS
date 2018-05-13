//
//  LoginManager.swift
//  Patriot
//
//  This is the protocol for the login manager
//  It will be implemented by the specific login needed
//  (eg. ParticleLogin)
//
//  Created by Ron Lisle on 5/13/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import Foundation

protocol LoginManager
{
    var isLoggedIn:  Bool  { get }
    
    func login(user: String, password: String, completion: @escaping (Error?) -> Void) -> Bool
    func logout()
}
