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
    @IBOutlet weak var particleUser: UITextField!
    @IBOutlet weak var particlePassword: UITextField!
    @IBOutlet weak var loginStatus: UILabel!
    
    let settings = Settings(store: UserDefaultsSettingsStore())
    
    fileprivate let swipeInteractionController = InteractiveTransition()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("config viewDidLoad")

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
        particleUser.text = settings.particleUser
        particlePassword.text = settings.particlePassword
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
                case self.particleUser:
                    userDidChange(string: textString)
                    break
                case self.particlePassword:
                    passwordDidChange(string: textString)
                    break
                default:
                    print("unknown text field")
                    break
            }
        }
    }
    
    
    fileprivate func userDidChange(string: String)
    {
        print("User changed")
        settings.particleUser = string
        loginIfDataIsValid()
    }
    

    fileprivate func passwordDidChange(string: String)
    {
        print("Password changed")
        settings.particlePassword = string
        loginIfDataIsValid()
    }
    
    fileprivate func loginIfDataIsValid()
    {
        print("particle login")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let appFactory = appDelegate.appFactory as! AppFactory
        appFactory.loginToParticle()
    }
}
