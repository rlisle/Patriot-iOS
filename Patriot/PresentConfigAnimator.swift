//
//  PresentConfigAnimator.swift
//  Patriot
//
//  This is the config animation controller
//
//  Created by Ron Lisle on 5/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//
import UIKit
 
class PresentConfigAnimator : NSObject
{
    let configWidth: CGFloat = 0.9
    let percentThreshold: CGFloat = 0.3
    let snapshotNumber = 12345

}


extension PresentConfigAnimator : UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        print("duration")
        return 0.6
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        print("animateTransition")
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
            else {
                return
        }
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        snapshot.tag = snapshotNumber
        snapshot.isUserInteractionEnabled = false
        snapshot.layer.shadowOpacity = 0.7
        containerView.insertSubview(snapshot, aboveSubview: toVC.view)
        fromVC.view.isHidden = true
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:
        {
            snapshot.center.x += UIScreen.main.bounds.width * self.configWidth
        },
        completion: { _ in
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
