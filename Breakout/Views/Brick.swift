import UIKit

enum BrickType: Int {
    case Regular = 0, SmallerPaddle, LargerPaddle, AddBall, Hard
    
    var hitsRequired: Int {
        switch self {
        case .Regular: fallthrough
        case .SmallerPaddle: fallthrough
        case .LargerPaddle: fallthrough
        case .AddBall:
            return 1
        case .Hard:
            return 3
        }
    }
    
    var color: UIColor {
        switch self {
        case .Regular:
            return UIColor.brownColor()
        case .SmallerPaddle:
            return UIColor.orangeColor()
        case .LargerPaddle:
            return UIColor.grayColor()
        case .AddBall:
            return UIColor.greenColor()
        case .Hard:
            return UIColor.redColor()
        }
    }
    
    static var count: Int {
        return Hard.hashValue + 1
    }
}

class Brick: UIView {
    let padding: CGFloat = 2.0
    var currentAlphaLevel: CGFloat = 1.0
    
    var currentHits = 0 {
        didSet {
            if type?.hitsRequired > 1 {
                colorAlphaDown()
            }
        }
    }
    var type: BrickType?
    
    init(frame: CGRect, type: BrickType) {
        super.init(frame: frame)
        self.type = type
        opaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func colorAlphaDown() {
        currentAlphaLevel = CGFloat(1 - Double(currentHits + 1) * 0.10)
        alpha = currentAlphaLevel
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(rect: CGRect(x: bounds.origin.x + padding, y: bounds.origin.y + padding, width: bounds.size.width - padding * 2, height: bounds.size.height - padding * 2))
        type?.color.set()
        path.fill()
    }
    
}