//
//  AppDelegate.swift
//  Jarvis
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import Mixpanel
import Fabric
import Crashlytics
import Toast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Fabric.with([Crashlytics.self])
    let productionMixPanelToken = "5bfa0fac94b25659a07899a8c6d92fb8"
    let developmentMixPanelToken = "8fec05b9adae253085f4cfc726db2115"
    Mixpanel.sharedInstanceWithToken(Credentials.sharedInstance.isDevelopmentDevice ? developmentMixPanelToken : productionMixPanelToken)
    Mixpanel.sharedInstance().identify("\(VendorInfo.getId())")
    Mixpanel.sharedInstance().track("AppLaunched")
    _ = AWS.sharedInstance
    _ = Logging.sharedInstance
    CSToastManager.setTapToDismissEnabled(true)
    CSToastManager.setQueueEnabled(true)
    return true
  }
  
  func logUser() {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
//    Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
    Crashlytics.sharedInstance().setUserIdentifier("\(VendorInfo.getId())")
//    Crashlytics.sharedInstance().setUserName("Test User")
  }


  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Mixpanel.sharedInstance().track("AppDidEnterBackground")
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    Mixpanel.sharedInstance().track("AppDidBecomeActive")
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    Mixpanel.sharedInstance().track("AppWillTerminate")
  }


}

