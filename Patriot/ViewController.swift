//
//  ViewController.swift
//  Patriot
//
//  Display a grid of images representing each supported activity
//
//  Created by Ron Lisle on 4/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


private let reuseIdentifier = "ActivityCell"


class ViewController: UICollectionViewController
{
    fileprivate let swipeInteractionController = InteractiveTransition()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    var dataManager: ActivitiesDataManager?
    let colors = Colors()
    var settings: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleConfigRecognizer))
        screenEdgeRecognizer.edges = .left
        view.addGestureRecognizer(screenEdgeRecognizer)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            //TODO: inject factory into init
            appDelegate.appFactory?.configureActivities(viewController: self)
        }
        addGradient()
    }


    @objc func handleConfigRecognizer(_ recognizer: UIScreenEdgePanGestureRecognizer)
    {
        if recognizer.state == .began
        {
            performSegue(withIdentifier: "openConfig", sender: nil)
        }
        else
        {
            swipeInteractionController.handleGesture(gestureRecognizer: recognizer)
        }
    }
    
    
    func addGradient()
    {
        view.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer)
    {
        if let index = gestureRecognizer.view?.tag
        {
            dataManager?.toggleActivity(at: index)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destinationViewController = segue.destination as? ConfigViewController
        {
            destinationViewController.modalPresentationStyle = .custom  // no effect
            destinationViewController.transitioningDelegate = self
            swipeInteractionController.wireToViewController(viewController: destinationViewController)
        }
    }
}


extension ViewController: UIViewControllerTransitioningDelegate
{
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return swipeInteractionController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentConfigAnimator()
    }
}


// MARK: UICollectionViewDataSource
extension ViewController
{
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataManager?.activities.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        styleCell(cell)
        
        if let activities = dataManager?.activities, activities.count > indexPath.row
        {
            let activity = activities[indexPath.row];
            if let cell = cell as? ActivitiesCollectionViewCell
            {
                //TODO: move this logic to the activity struct
                print("Cell activity \(activity.name) is \(activity.percent)%")
                let isOn = activity.percent > 0
                let image = isOn ? activity.onImage : activity.offImage
                cell.imageView.image = image

                let caption = activity.name.capitalized
                cell.label.text = caption
                
                cell.tag = indexPath.row
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_: )))
                cell.addGestureRecognizer(tapGesture)
            }
        }
        
        return cell
    }


    func styleCell(_ cell: UICollectionViewCell)
    {
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 2
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.shadowOpacity = 0.75
        cell.layer.shadowRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize.zero
    }
    
}

// MARK: Flow Layout Delegate
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 150, height: 150)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        
        let verticalInsets: CGFloat = 30
        
        let itemWidth = 150
        let screenSize = UIScreen.main.bounds
        let displayWidth = Int(screenSize.width)
        let numberOfItemsPerRow = displayWidth / itemWidth
        let horizontalSpacing = CGFloat((displayWidth - (itemWidth * numberOfItemsPerRow)) / (numberOfItemsPerRow + 1))
        let inset = UIEdgeInsetsMake(verticalInsets, horizontalSpacing-1, verticalInsets, horizontalSpacing-1)
        
        return inset
    }
}


extension ViewController : ActivityNotifying
{
    func supportedListChanged()
    {
        print("VC supportedListChanged")
        collectionView?.reloadData()
    }
    
    func activityChanged(name: String, percent: Int)
    {
        print("VC activityChanged: \(name), \(percent)")
        if let index = dataManager?.activities.index(where: {$0.name == name})
        {
            print("   index of activityChanged = \(index)")
            collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}
