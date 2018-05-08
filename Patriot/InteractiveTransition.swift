//
//  Interactor.swift
//  Patriot
//
//  Created by Ron Lisle on 5/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import UIKit

class InteractiveTransition: UIPercentDrivenInteractiveTransition
{
    var interactionInProgress = false      // was hasStarted
    var shouldCompleteTransition = false   // was shouldfinish
    private weak var viewController: UIViewController!
    
    func wireToViewController(viewController: UIViewController!)
    {
        self.viewController = viewController
    }
    
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer)
    {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 300)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))

      switch gestureRecognizer.state {

      case .began:  // handled in VC
        interactionInProgress = true
        viewController.dismiss(animated: true, completion: nil)

      case .changed:
        shouldCompleteTransition = progress > 0.5
        update(progress)

      case .cancelled:
        interactionInProgress = false
        cancel()

      case .ended:
        interactionInProgress = false

        if !shouldCompleteTransition {
          cancel()
        } else {
          finish()
        }

      default:
          print("Unsupported")
      }
    }
}
