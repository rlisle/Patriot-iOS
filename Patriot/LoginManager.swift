//
//  LoggingIn.swift
//  Patriot
//
//  Created by Rons iMac on 5/13/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import Foundation

protocol LoginManager
{
    var isLoggedIn:  Bool  { get }
    var delegate: LoginNotifying? { get set }
    
    func login(user: String, password: String) -> Bool
    func logout()
}
