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
 
    let settings = Settings(store: UserDefaultsSettingsStore())
    var beaconXmitData: BeaconXmitData?
    
    fileprivate let swipeInteractionController = InteractiveTransition()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("config viewDidLoad")
        
        transmitBeaconUUID.formatting = .uuid
        beaconXmitData = BeaconXmitData(store: settings)
        
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
        guard let xmitData = beaconXmitData else
        {
            fatalError("beaconXmitData was not set")
        }
        transmitBeaconUUID.text = xmitData.uuid
        transmitBeaconMajor.text = String(xmitData.major)
        transmitBeaconMinor.text = String(xmitData.minor)
        transmitBeaconSwitch.isOn = xmitData.isEnabled
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
        beaconXmitData?.isEnabled = sender.isOn
        if sender.isOn
        {
            activateBeaconIfDataIsValid()
        }
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
                    uuidDidChange(string: textString)
                    break
                case self.transmitBeaconMajor:
                    print("major changed")
                    beaconMajorDidChange(string: textString)
                    break
                case self.transmitBeaconMinor:
                    print("minor changed")
                    beaconMinorDidChange(string: textString)
                    break
                default:
                    print("unknown text field")
                    break
            }
        }
    }
    
    
    fileprivate func uuidDidChange(string: String)
    {
        let stringWithoutDashes = string.replacingOccurrences(of: "-", with: "")
        beaconXmitData?.uuid = stringWithoutDashes
        activateBeaconIfDataIsValid()
    }
    

    fileprivate func beaconMajorDidChange(string: String)
    {
        if let value = Int(string)
        {
            beaconXmitData?.major = value
            activateBeaconIfDataIsValid()
        }
    }
    
    
    fileprivate func beaconMinorDidChange(string: String)
    {
        if let value = Int(string)
        {
            beaconXmitData?.minor = value
            activateBeaconIfDataIsValid()
        }
    }
    
    
    fileprivate func activateBeaconIfDataIsValid()
    {
        print("activateBeaconIfDataIsValid")
        guard beaconXmitData != nil else {
            fatalError("beaconXmitData not set")
        }
        if beaconXmitData!.isDataValid()
        {
            print("Is valid beacon data")
            //TODO: enable beacon
        }
        else
        {
            print("Disabling xmit beacon")
            //TODO: disable beacon
        }
    }
}
