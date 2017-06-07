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
    @IBOutlet weak var transmitBeaconSwitch: UISwitch!
    @IBOutlet weak var transmitBeaconUUID: VSTextField!
    @IBOutlet weak var transmitBeaconMajor: UITextField!
    @IBOutlet weak var transmitBeaconMinor: UITextField!
    
    fileprivate let swipeInteractionController = Interactor()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transmitBeaconUUID.formatting = .uuid
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleUnwindRecognizer))
        screenEdgeRecognizer.edges = .right
        view.addGestureRecognizer(screenEdgeRecognizer)
    }


    func handleUnwindRecognizer(_ recognizer: UIScreenEdgePanGestureRecognizer)
    {
        if recognizer.state == .began
        {
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionReveal
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: nil)
            dismiss(animated: false, completion: nil)
        }
    }
    
    
    @IBAction func transmitBeaconDidChange(_ sender: UISwitch)
    {
        // 
    }
}
