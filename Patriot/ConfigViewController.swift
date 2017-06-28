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

class BeaconXmitData
{
    static let TransmitBeaconUUIDKey = "TransmitBeaconUUID"
    static let TransmitBeaconMajorKey = "TransmitBeaconMajor"
    static let TransmitBeaconMinorKey = "TransmitBeaconMinor"
    static let TransmitBeaconSwitchKey = "TransmitBeaconSwitch"
    
    var identifier: String = "Unnamed"
    var uuid: String = ""
    var major: Int = 1
    var minor: Int = 1
    var isEnabled: Bool = false
    
    func isDataValid() -> Bool
    {
        return isValidUUID() && isValidMajor() && isValidMinor()
    }
    
    
    fileprivate func isValidUUID() -> Bool
    {
        if uuid.characters.count != 32
        {
            return false
        }
        return true
    }
    
    
    fileprivate func isValidMajor() -> Bool
    {
        if major >= 0 && major <= 255
        {
            return true
        }
        return false
    }
    
    
    fileprivate func isValidMinor() -> Bool
    {
        if minor >= 0 && minor <= 255
        {
            return true
        }
        return false
    }
    
    
    func loadFromStore(_ store: Settings)
    {
        uuid = store.beaconUUID
        identifier = store.beaconIdentifier
        major = store.beaconMajor
        minor = store.beaconMinor
        isEnabled = store.isBeaconTransmitOn
    }
}


class ConfigViewController: UITableViewController
{
    @IBOutlet weak var transmitBeaconSwitch: UISwitch!
    @IBOutlet weak var transmitBeaconUUID: VSTextField!
    @IBOutlet weak var transmitBeaconMajor: UITextField!
    @IBOutlet weak var transmitBeaconMinor: UITextField!
 
    let settings = Settings(store: UserDefaultsSettingsStore())
    var beaconXmitData = BeaconXmitData()
    
    fileprivate let swipeInteractionController = InteractiveTransition()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("config viewDidLoad")
        
        transmitBeaconUUID.formatting = .uuid
        beaconXmitData.loadFromStore(settings)
        
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
        print("config viewWillDisappear")
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
        
        transmitBeaconUUID.text = beaconXmitData.uuid
        transmitBeaconMajor.text = String(beaconXmitData.major)
        transmitBeaconMinor.text = String(beaconXmitData.minor)
        transmitBeaconSwitch.isOn = beaconXmitData.isEnabled
        activateBeaconIfDataIsValid()
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
        beaconXmitData.isEnabled = sender.isOn
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
    
    
    fileprivate func uuidDidChange(string: String)
    {
        beaconXmitData.uuid = string
        activateBeaconIfDataIsValid()
    }
    
    
    fileprivate func activateBeaconIfDataIsValid()
    {
        print("activateBeaconIfDataIsValid")
        if beaconXmitData.isDataValid()
        {
            print("Is valid beacon data")
            transmitBeaconSwitch.isEnabled = true
        }
        else
        {
            print("Disabling xmit beacon")
            transmitBeaconSwitch.isEnabled = false
        }
    }
}
