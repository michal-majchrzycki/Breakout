import UIKit

class Ball: UIImageView {
    var linearVelocity: CGPoint?
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.width / 2.2
        image = UIImage(named: "ball")
        backgroundColor = UIColor.brownColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("UPS!")
    }
    
}
