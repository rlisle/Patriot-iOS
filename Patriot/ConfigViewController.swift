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
 
    let TransmitBeaconUUIDKey = "TransmitBeaconUUID"
    let TransmitBeaconMajorKey = "TransmitBeaconMajor"
    let TransmitBeaconMinorKey = "TransmitBeaconMinor"
    let TransmitBeaconSwitchKey = "TransmitBeaconSwitch"
    
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
        initializeDisplayValues()
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        unregisterForNotifications()
    }
    
    
    func registerForNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                    selector: #selector(self.textFieldDidChange),
                                    name: NSNotification.Name.UITextFieldTextDidChange,
                                    object: nil)
    }
    
    
    func initializeDisplayValues()
    {
        transmitBeaconUUID.text = UserDefaults.standard.string(forKey: TransmitBeaconUUIDKey)
        transmitBeaconMajor.text = UserDefaults.standard.string(forKey: TransmitBeaconMajorKey)
        transmitBeaconMinor.text = UserDefaults.standard.string(forKey: TransmitBeaconMinorKey)
        transmitBeaconSwitch.isOn = UserDefaults.standard.bool(forKey: TransmitBeaconSwitchKey)
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
        print("Transmit switch did change: \(sender.isOn)")
        saveBeaconSwitch(isOn: sender.isOn)
    }
    
    
    func textFieldDidChange(sender : AnyObject) {
        guard let notification = sender as? NSNotification,
            let textFieldChanged = notification.object as? UITextField else
        {
                return
        }
        if let textString = textFieldChanged.text
        {
            print("text changed = \(textString)")
            switch textFieldChanged
            {
                case self.transmitBeaconUUID:
                    print("UUID changed")
                    saveBeaconUUID(string: textString)
                    if isValidUUID(string: textString)
                    {
                        print("Is valid UUID")
                        transmitBeaconSwitch.isOn = true
                    }
                    break
                case self.transmitBeaconMajor:
                    print("major changed")
                    saveBeaconMajor(string: textString)
                    break
                case self.transmitBeaconMinor:
                    print("minor changed")
                    saveBeaconMinor(string: textString)
                    break
                default:
                    print("unknown text field")
                    break
            }
        }
    }
    
    
    fileprivate func isValidUUID(string: String) -> Bool
    {
        if string.characters.count != 32
        {
            return false
        }
        return true
    }
    
    
    fileprivate func saveBeaconUUID(string: String)
    {
        UserDefaults.standard.set(string, forKey: TransmitBeaconUUIDKey)
    }
    
    
    fileprivate func saveBeaconMajor(string: String)
    {
        UserDefaults.standard.set(string, forKey: TransmitBeaconMajorKey)
    }
    
    
    fileprivate func saveBeaconMinor(string: String)
    {
        UserDefaults.standard.set(string, forKey: TransmitBeaconMinorKey)
    }
    
    
    fileprivate func saveBeaconSwitch(isOn: Bool)
    {
        UserDefaults.standard.set(isOn, forKey: TransmitBeaconSwitchKey)
    }
}
