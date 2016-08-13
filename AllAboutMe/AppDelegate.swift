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
  let log = Logger(loggerName: String(AppDelegate))

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    Fabric.with([Crashlytics.self])
    let productionMixPanelToken = "5bfa0fac94b25659a07899a8c6d92fb8"
    let developmentMixPanelToken = "8fec05b9adae253085f4cfc726db2115"
    Mixpanel.sharedInstanceWithToken(Credentials.sharedInstance.isDevelopmentDevice ? developmentMixPanelToken : productionMixPanelToken)
    Mixpanel.sharedInstance().identify("\(VendorInfo.getId())")
    Mixpanel.sharedInstance().track("AppLaunched")
    if Credentials.userHasOnboarded {
      setupDashboardViewController()
    } else {
      NSNotificationCenter.defaultCenter().addObserver(self,
                                                       selector: #selector((UIApplication.sharedApplication().delegate as? AppDelegate)!.handleOnboardingCompletion),
                                                       name: onboardingCompleteNotification,
                                                       object: nil)
      self.window?.rootViewController = OnboardPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    }
    self.window?.makeKeyAndVisible()
    self.window?.makeKeyAndVisible()
    return true
  }
  
  func handleOnboardingCompletion() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: userHasOnboardedKey)
    setupDashboardViewController()
  }

  func setupDashboardViewController() {
    let storyboard = UIStoryboard(name: "Artboard", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("ArtboardTabBarController") as? ArtboardTabBarController {
      self.window?.rootViewController = vc
      _ = AWS.sharedInstance
      _ = Logging.sharedInstance
    }
  }
  
  func setupNormalRootViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as? MainTabBarController {
      self.window?.rootViewController = vc
      _ = AWS.sharedInstance
      _ = Logging.sharedInstance
      CSToastManager.setTapToDismissEnabled(true)
      CSToastManager.setQueueEnabled(true)
    }
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

