import UIKit

class Paddle: UIImageView {

        private let defaultVelocityDivider: CGFloat = 20
        
        private let defaultWidth: CGFloat = 80
        private var currentWidth: CGFloat = 80
        private let widthStepper: CGFloat = 10
        private let minWidth: CGFloat = 40
        private let maxWidth: CGFloat = 120
        
        private let height: CGFloat = 18.0
        private let distanceFromBottom: CGFloat = 100.0
        
        private var referenceView: UIView!
        
        init(referenceView: UIView) {
            super.init(frame: CGRectZero)
            self.referenceView = referenceView
            
            backgroundColor = UIColor(red: 141/255.0, green: 185/255.0, blue: 230/255.0, alpha: 1.0)
            layer.cornerRadius = CGFloat(height / 2.5)
            
            layer.borderColor = UIColor(red: 0/255.0, green: 52/255.0, blue: 120/255.0, alpha: 1.0).CGColor
            layer.borderWidth = 1.7
            
            frame = CGRect(origin: CGPointZero, size: CGSize(width: currentWidth, height: height))
            frame.origin.x = referenceView.bounds.size.width/2 - currentWidth/2
            frame.origin.y = referenceView.bounds.size.height - height - distanceFromBottom
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) ups, problem!")
        }
        
        func move(velocity: CGPoint) {
            let proposedCenter = CGPoint(x: center.x + velocity.x/defaultVelocityDivider, y: self.center.y)
            let newCenter = getCenterForProposedCenter(proposedCenter)
            
            UIView.animateWithDuration(0.0,
                                       delay: 0.0,
                                       options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveEaseIn],
                                       animations: {
                                        self.center = newCenter
                },
                                       completion: nil
            )
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
            var newWidth = currentWidth - widthStepper
            if newWidth < minWidth {
                newWidth = minWidth
            }
            currentWidth = newWidth
            resizePaddle()
        }
        
        func increaseWidth() {
            var newWidth = currentWidth + widthStepper
            if newWidth > maxWidth {
                newWidth = maxWidth
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