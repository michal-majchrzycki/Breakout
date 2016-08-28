import UIKit

class Ball: UIImageView {
    // used for restoring game state
    var linearVelocity: CGPoint?
    
    // iOS 9 specific
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.width / 2.0
        image = UIImage(named: "ball")
        backgroundColor = UIColor.redColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}