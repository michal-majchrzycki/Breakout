import UIKit

class Brick: UIImageView {

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
                return UIColor(red: 177/255.0, green: 160/255.0, blue: 164/255.0, alpha: 1.0)
            case .SmallerPaddle:
                return UIColor(red: 225/255.0, green: 232/255.0, blue: 111/255.0, alpha: 1.0)
            case .LargerPaddle:
                return UIColor(red: 194/255.0, green: 231/255.0, blue: 112/255.0, alpha: 1.0)
            }
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
}
