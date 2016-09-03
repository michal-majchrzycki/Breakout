//
//  UserSettings.swift
//  PrehistoricBreakout
//
//  Created by Neían on 28.08.2016.
//  Copyright © 2016 Michał Majchrzycki. All rights reserved.
//

import Foundation



class UserSettings {
    static let sharedInstance = UserSettings()
    private init() {}
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private struct Defaults {
        static let Gravity: CGFloat = 0.25
        static let BallBouncy: CGFloat = 1.10
        static let BouncingBalls = 2
        static let HowManyBricks = 20
        static let HowManySpecialBricks = 8
        static let SmallPaddle = true
        static let LargPaddle = true
        static let AdditionalBrick = true
        static let HardBrick = true
    }
    
    private struct Keys {
        static let Gravity = "Gravity"
        static let BallBouncy = "Ball Bouncy"
        static let BouncingBalls = "Bouncing Balls"
        static let HowManyBricks = "How many Bricks?"
        static let HowManySpecialBricks = "How many Special Bricks"
        static let SmallPaddle = "Small Paddle"
        static let LargPaddle = "Large Paddle"
        static let AdditionalBrick = "Additional Brick"
        static let HardBrick = "Hard Brick"
    }
    
    var gravity: CGFloat {
        get {
            if let gravity = userDefaults.valueForKey(Keys.Gravity) as? CGFloat {
                return gravity
            } else {
                self.gravity = Defaults.Gravity
                return self.gravity
            }
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.Gravity)
            userDefaults.synchronize()
        }
    }
    
    var elasticity: CGFloat {
        get {
            if let elasticity = userDefaults.valueForKey(Keys.BallBouncy) as? CGFloat {
                return elasticity
            } else {
                self.elasticity = Defaults.BallBouncy
                return self.elasticity
            }
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.BallBouncy)
            userDefaults.synchronize()
        }
    }
    
    var bouncingBalls: Int {
        get {
            if userDefaults.integerForKey(Keys.BouncingBalls) != 0 {
                return userDefaults.integerForKey(Keys.BouncingBalls)
            } else {
                self.bouncingBalls = Defaults.BouncingBalls
                return self.bouncingBalls
            }
        }
        set {
            userDefaults.setInteger(newValue, forKey: Keys.BouncingBalls)
            userDefaults.synchronize()
        }
    }
    
    var howManyBricks: Int {
        get {
            if userDefaults.integerForKey(Keys.HowManyBricks) != 0 {
                return userDefaults.integerForKey(Keys.HowManyBricks)
            } else {
                self.howManyBricks = Defaults.HowManyBricks
                return self.howManyBricks
            }
        }
        set {
            userDefaults.setInteger(newValue, forKey: Keys.HowManyBricks)
            userDefaults.synchronize()
        }
    }
    
    var howManySpecialBricks: Int {
        get {
            if userDefaults.integerForKey(Keys.HowManySpecialBricks) != 0 {
                return userDefaults.integerForKey(Keys.HowManySpecialBricks)
            } else {
                self.howManySpecialBricks = Defaults.HowManySpecialBricks
                return self.howManySpecialBricks
            }
        }
        set {
            userDefaults.setInteger(newValue, forKey: Keys.HowManySpecialBricks)
            userDefaults.synchronize()
        }
    }
    
    var smallPaddle: Bool {
        get {
            if let smallPaddle = userDefaults.valueForKey(Keys.SmallPaddle) as? Bool {
                return smallPaddle
            } else {
                self.smallPaddle = Defaults.SmallPaddle
                return self.smallPaddle
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.SmallPaddle)
            userDefaults.synchronize()
        }
    }
    
    var largPaddle: Bool {
        get {
            if let specialBrickLargerPaddleEnabled = userDefaults.valueForKey(Keys.LargPaddle) as? Bool {
                return specialBrickLargerPaddleEnabled
            } else {
                self.largPaddle = Defaults.LargPaddle
                return self.largPaddle
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.LargPaddle)
            userDefaults.synchronize()
        }
        
    }
    
    var additionalBrick: Bool {
        get {
            if let additionalBrick = userDefaults.valueForKey(Keys.AdditionalBrick) as? Bool {
                return additionalBrick
            } else {
                self.additionalBrick = Defaults.AdditionalBrick
                return self.additionalBrick
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.AdditionalBrick)
            userDefaults.synchronize()
        }
        
    }
    
    var hardBrick: Bool {
        get {
            if let specialBrickHardEnabled = userDefaults.valueForKey(Keys.HardBrick) as? Bool {
                return specialBrickHardEnabled
            } else {
                self.hardBrick = Defaults.HardBrick
                return self.hardBrick
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.HardBrick)
            userDefaults.synchronize()
        }
    }
    
}