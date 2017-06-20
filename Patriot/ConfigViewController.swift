//
//  ConfigViewController.swift
//  Patriot
//
//  When the Beacon UUID, major, and minor are invalid,
//  the enable switch will be off and disabled.
//
//  So after making changes, the switch will need to be turned on.
//  At that point, the data will be read and activated.
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
    
    fileprivate let swipeInteractionController = InteractiveTransition()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transmitBeaconUUID.formatting = .uuid
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleUnwindRecognizer))
        screenEdgeRecognizer.edges = .right
        view.addGestureRecognizer(screenEdgeRecognizer)
    }


    override func viewDidAppear(_ animated: Bool)
    {
        registerForNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        unregisterForNotifications()
    }
    
    
    func registerForNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                    selector: #selector(textFieldDidChange),
                                    name: NSNotification.Name.UITextFieldTextDidChange,
                                    object: nil)
    }
    
    
    func unregisterForNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
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
        print("Transmit switch did change: \(transmitBeaconSwitch.isOn)")
    }
    
    
    @objc func textFieldDidChange(sender : AnyObject) {
        guard let notification = sender as? NSNotification,
            let textFieldChanged = notification.object as? UITextField,
            textFieldChanged == self.transmitBeaconUUID else
        {
                return
        }
        print("UUID changed: \(transmitBeaconUUID.text)")
        //TODO: handle text
    }
}
