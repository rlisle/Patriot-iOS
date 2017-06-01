//
//  ConfigViewController.swift
//  Patriot
//
//  Created by Ron Lisle on 5/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit

class ConfigViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeMenu(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
