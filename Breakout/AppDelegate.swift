//
//  AppDelegate.swift
//  Breakout
//
//  Created by Neían on 16.08.2016.
//  Copyright © 2016 Michał Majchrzycki. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    struct Settings {
        static let Defaults = NSUserDefaults.standardUserDefaults()
        struct Ball {
            static var Size: CGFloat {
                get { return Defaults.objectForKey("Ball.Size") as? CGFloat ?? 25.0 }
                set { Defaults.setObject(newValue, forKey: "Ball.Size") }
            }
            static var StartSpreadAngle: CGFloat {
                get { return Defaults.objectForKey("Ball.StartSpreadAngle") as? CGFloat ?? CGFloat(M_PI/8) }
                set { Defaults.setObject(newValue, forKey: "Ball.StartSpreadAngle") }
            }
        }
        struct Brick {
            static var Rows: Int {
                get { return Defaults.objectForKey("Brick.Rows") as? Int ?? 3 }
                set { Defaults.setObject(newValue, forKey: "Brick.Rows") }
            }
            static var Columns: Int {
                get { return Defaults.objectForKey("Brick.Columns") as? Int ?? 5 }
                set { Defaults.setObject(newValue, forKey: "Brick.Columns") }
            }
        }
        struct Game {
            static var ContinueAfterGameOver: Bool {
                get { return Defaults.objectForKey("Game.ContinueAfterGameOver") as? Bool ?? true }
                set { Defaults.setObject(newValue, forKey: "Game.ContinueAfterGameOver") }
            }
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
