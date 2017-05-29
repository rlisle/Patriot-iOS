//
//  ConfigHelper.swift
//  Patriot
//
//  Created by Ron Lisle on 5/29/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation
import UIKit

enum Direction {
    case Up
    case Down
    case Left   // Closing
    case Right  // Opening
}


struct ConfigHelper
{
    static let configWidth: CGFloat = 0.8
    static let percentThreshold: CGFloat = 0.3
    static let snapshotNumber = 12345
    
    static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: Direction) -> CGFloat
    {
        let pointOnAxis: CGFloat
        let axisLength: CGFloat
        switch direction
        {
            case .Up, .Down:
                pointOnAxis = translationInView.y
                axisLength = viewBounds.height
            case .Left, .Right:
                pointOnAxis = translationInView.x
                axisLength = viewBounds.width
        }
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis: Float
        let positiveMovementOnAxisPercent: Float
        switch direction {
        case .Right, .Down:     // positive
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .Up, .Left:        // negative
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
    
    static func mapGestureStateToInteractor(gestureState: UIGestureRecognizerState, progress: CGFloat, interactor: Interactor?, triggerSegue: () -> Void)
    {
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
    }
}
