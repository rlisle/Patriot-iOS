//
//  ConfigViewController.swift
//  Patriot
//
//  Created by Ron Lisle on 5/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit

class ConfigViewController: UITableViewController
{
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleUnwindRecognizer))
        screenEdgeRecognizer.edges = .right
        view.addGestureRecognizer(screenEdgeRecognizer)
    }


    func handleUnwindRecognizer(_ recognizer: UIScreenEdgePanGestureRecognizer)
    {
        if recognizer.state == .began
        {
            print("unwind begin")
            dismiss(animated: true, completion: nil)
        }
    }
}
