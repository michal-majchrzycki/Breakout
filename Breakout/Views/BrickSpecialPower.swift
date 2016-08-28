//
//  BrickSpecialPower.swift
//  PrehistoricBreakout
//
//  Created by Neían on 28.08.2016.
//  Copyright © 2016 Michał Majchrzycki. All rights reserved.
//

import UIKit

class BrickSpecialPower: UIImageView {
    
    let size: CGFloat = 50.0
    var brickType: BrickType?
    
    init(dropPosition: CGPoint, brickType: BrickType) {
        var frame = CGRect(origin: CGPointZero, size: CGSize(width: size, height: size))
        frame.origin.x = dropPosition.x - (size/2)
        frame.origin.y = dropPosition.y - (size/2)
        super.init(frame: frame)
        self.brickType = brickType
        
        switch brickType {
        case .LargerPaddle:
            image = UIImage(named: "power-larger-paddle")
        case .SmallerPaddle:
            image = UIImage(named: "power-smaller-paddle")
        case .AddBall:
            image = UIImage(named: "power-add-ball")
        default: break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
