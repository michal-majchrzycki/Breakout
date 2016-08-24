import UIKit

class BrekoutPhysics: UIDynamicBehavior {

    lazy var colidePhysics: UICollisionBehavior = {
    let createdColidePhycisc = UICollisionBehavior()
        return createdColidePhycisc
    }()
    
    lazy var gravityPhysics: UIGravityBehavior = {
        let createdGravityPhysics = UIGravityBehavior()
        return createdGravityPhysics
    }()
   
    lazy var ballPhysics: UIDynamicItemBehavior = {
        let createdBallPhysics = UIDynamicItemBehavior()
        createdBallPhysics.resistance = 0.0
        createdBallPhysics.friction = 0.1
        createdBallPhysics.allowsRotation = true
        return createdBallPhysics
    }()
    
    override init()
    {
        super.init()
        addChildBehavior(colidePhysics)
        addChildBehavior(gravityPhysics)
        addChildBehavior(ballPhysics)
    }
    
    func addBounds(path: UIBezierPath, named name: String) {
        colidePhysics.removeBoundaryWithIdentifier(name)
        colidePhysics.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBounds(named name: String) {
        colidePhysics.removeBoundaryWithIdentifier(name)
    }
    
    private struct forDevice {
        struct iPhone5s {
            static let Width: CGFloat = 320.0
            static let Height: CGFloat = 568.0
        }
        struct iPhone6 {
            static let Width: CGFloat = 375.0
            static let Height: CGFloat = 667.0
        }
        struct iPhone6Plus {
            static let Width: CGFloat = 414.0
            static let Height: CGFloat = 736.0
        }
        struct iPad2 {
            static let Width: CGFloat = 768.0
            static let Height: CGFloat = 1024.0
        }
        struct iPadAir {
            static let Width: CGFloat = 1536.0
            static let Height: CGFloat = 2048.0
        }
        struct iPadPro {
            static let Width: CGFloat = 2048.0
            static let Height: CGFloat = 2732.0
        }
    }

    func ballPhysics (ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        let linearVelocity = ballPhysics.linearVelocityForItem(ball)
        
        let referenceViewHeight = dynamicAnimator?.referenceView?.bounds.size.height
        if referenceViewHeight > forDevice.iPhone5s.Height {
            pushBehavior.magnitude = 0.2
        } else if referenceViewHeight > forDevice.iPhone6Plus.Height {
            pushBehavior.magnitude = 0.3
        } else if referenceViewHeight > forDevice.iPad2.Height {
            pushBehavior.magnitude = 0.35
        } else if referenceViewHeight > forDevice.iPadAir.Height {
            pushBehavior.magnitude = 0.4
        } else {
            pushBehavior.magnitude = 0.15
        }
        let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x))
        let oppositeAngle = CGFloat((currentAngle + M_PI) % (2 * M_PI))
        
        let lower = oppositeAngle - CGFloat.degreeForRadius(35)
        let upper = oppositeAngle + CGFloat.degreeForRadius(35)
        
        pushBehavior.angle = CGFloat.defaultRadius(lower, upper)

        pushBehavior.action = { [unowned pushBehavior] in
            pushBehavior.removeItem(ball)
            pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }
    
    func pushRestoredBall(ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        if let linearVelocity = ball.linearVelocity where linearVelocity != CGPointZero {
            pushBehavior.magnitude = 0.1
            
            pushBehavior.angle = CGFloat(atan2(linearVelocity.y, linearVelocity.x))
            
            pushBehavior.action = { [unowned pushBehavior] in
                pushBehavior.removeItem(ball)
                pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
            }
            addChildBehavior(pushBehavior)
        }
    }
    
    func pushBallFromPaddle(ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        let referenceViewHeight = dynamicAnimator?.referenceView?.bounds.size.height
        if referenceViewHeight > forDevice.iPhone5s.Height {
            pushBehavior.magnitude = 0.2
        } else if referenceViewHeight > forDevice.iPhone6Plus.Height {
            pushBehavior.magnitude = 0.3
        } else if referenceViewHeight > forDevice.iPad2.Height {
            pushBehavior.magnitude = 0.35
        } else if referenceViewHeight > forDevice.iPadAir.Height {
            pushBehavior.magnitude = 0.4
        } else {
            pushBehavior.magnitude = 0.15
        }
        
        let lower =  CGFloat(((90-15) * M_PI)/180)
        let upper = CGFloat(((90+15) * M_PI)/180)
        pushBehavior.angle = CGFloat.defaultRadius(lower, upper)
        
        pushBehavior.action = { [unowned pushBehavior] in
            pushBehavior.removeItem(ball)
            pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }
    
    func addBall(ball: Ball) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        gravityPhysics.addItem(ball)
        colidePhysics.addItem(ball)
        ballPhysics.addItem(ball)
    }
    
    func removeBall(ball: Ball) {
        gravityPhysics.removeItem(ball)
        colidePhysics.removeItem(ball)
        ballPhysics.removeItem(ball)
        ball.removeFromSuperview()
    }
    
}


private extension CGFloat {
    static func defaultRadius(lower: CGFloat = 0, _ upper: CGFloat = CGFloat(2 * M_PI)) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
    
    static func degreeForRadius(degree: Double) -> CGFloat {
        return CGFloat((degree * M_PI)/180)
    }
}
