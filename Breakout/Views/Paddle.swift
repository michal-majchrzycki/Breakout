import UIKit

class Paddle: UIImageView {

    private let defaultVelocityDivide: CGFloat = 20
    private let defaultWitdh: CGFloat = 80
    private var currentWidth: CGFloat = 80
    private let stepperWidth: CGFloat = 10
    private let minimalWidth: CGFloat = 40
    private let maximumWidth: CGFloat = 120
    private let height: CGFloat = 18.0
    private let distanceFromBottom: CGFloat = 100.0
    private var referenceView: UIView!
    
    init(referenceView: UIView) {
        super.init(frame: CGRectZero)
        self.referenceView = referenceView
        
        backgroundColor = UIColor.brownColor()
        layer.cornerRadius = CGFloat(height / 2.5)
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1.7
        
        frame = CGRect(origin: CGPointZero, size: CGSize(width: currentWidth, height: height))
        frame.origin.x = referenceView.bounds.size.width/2 - currentWidth/2
        frame.origin.y = referenceView.bounds.size.height - height - distanceFromBottom
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func moveStuff(velocity: CGPoint) {
        let proposedCenter = CGPoint(x: center.x + velocity.x/defaultVelocityDivide, y: self.center.y)
        let newCenter = getCenterForProposedCenter(proposedCenter)
        
        UIView.animateWithDuration(0.0, delay: 0.0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveEaseIn], animations: { self.center = proposedCenter }, completion: nil)
    }
    
    private func getCenterForProposedCenter(proposedCenter: CGPoint) -> CGPoint {
        var newCenter = proposedCenter
        
        let paddleLeftEdgeAtNewCenter = floor(newCenter.x - (currentWidth/2))
        let paddleRightEdgeAtNewCenter = ceil(newCenter.x + (currentWidth/2))
        
        let referenceViewLeftEdge = floor(referenceView.bounds.origin.x)
        let referenceViewRightEdge = ceil(referenceView.bounds.width)
        
        if paddleLeftEdgeAtNewCenter <= referenceViewLeftEdge {
            newCenter.x = floor(CGFloat(currentWidth/2))
        } else if paddleRightEdgeAtNewCenter >= referenceViewRightEdge {
            newCenter.x = ceil(referenceView.bounds.width - (currentWidth/2))
        }
        return newCenter
    }
    func decreaseWidth() {
        var newWidth = currentWidth - stepperWidth
        if newWidth < minimalWidth {
            newWidth = minimalWidth
        }
        currentWidth = newWidth
        resizePaddle()
    }
    
    func increaseWidth() {
        var newWidth = currentWidth + stepperWidth
        if newWidth > maximumWidth {
            newWidth = maximumWidth
        }
        currentWidth = newWidth
        resizePaddle()
    }
    
    private func resizePaddle() {
        let newCenter = getCenterForProposedCenter(center)
        frame = CGRect(origin: CGPointZero, size: CGSize(width: currentWidth, height: height))
        center = newCenter
    }
    
}
