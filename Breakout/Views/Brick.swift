import UIKit

    enum BrickType: Int {
        case Regular = 0, SmallerPaddle, LargerPaddle
        
        var hitsRequired: Int {
            switch self {
            case .Regular: fallthrough
            case .SmallerPaddle: fallthrough
            case .LargerPaddle: fallthrough
            default: break
            }
            return self.hitsRequired
        }
        
        var color: UIColor {
            switch self {
            case .Regular:
                return UIColor.whiteColor()
            case .SmallerPaddle:
                return UIColor.whiteColor()
            case .LargerPaddle:
                return UIColor.whiteColor()
            }
        }
        
        static var count: Int {
            return LargerPaddle.hashValue + 1
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
            fatalError()
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