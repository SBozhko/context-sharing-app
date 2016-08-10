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
import Onboard

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
    self.window?.tintColor = globalTint
    let userHasOnboarded = NSUserDefaults.standardUserDefaults().boolForKey(userHasOnboardedKey)
    if userHasOnboarded {
      setupNormalRootViewController()
    } else {
      NSNotificationCenter.defaultCenter().addObserver(self,
                                                       selector: #selector((UIApplication.sharedApplication().delegate as? AppDelegate)!.setupNormalRootViewController),
                                                       name: onboardingCompleteNotification,
                                                       object: nil)
      self.window?.rootViewController = generateOnboardingViewController()
    }
    application.statusBarStyle = UIStatusBarStyle.LightContent
    self.window?.makeKeyAndVisible()
    return true
  }
  
  func handleOnboardingCompletion() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: userHasOnboardedKey)
    setupNormalRootViewController()
  }
  
  func setupNormalRootViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("MeViewController") as? MeViewController {
      self.window?.rootViewController = vc
      _ = AWS.sharedInstance
      _ = Logging.sharedInstance
      CSToastManager.setTapToDismissEnabled(true)
      CSToastManager.setQueueEnabled(true)
      UIView.animateWithDuration(0.2, animations: {
        vc.view.alpha = 1.0
      })
    }
  }
  
  func generateOnboardingViewController() -> OnboardingViewController {
    let avenirNextRegular24 = UIFont(name: "AvenirNext-Regular", size: 16.0)
    let avenirNextBold24 = UIFont(name: "AvenirNext-Bold", size: 16.0)
    let avenirNextRegular36 = UIFont(name: "AvenirNext-Regular", size: 16.0)
    let underTitlePaddingValue : CGFloat = 40.0
    
    let firstPage = OnboardingContentViewController(title: "Hi there!\nI'm Jarvis.", body: "I can help you escape of your daily routine and recapture the serendipity in your life.", image: UIImage(named: "Jarvis"), buttonText: "") { () -> Void in
      // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }
    firstPage.titleLabel.font = avenirNextRegular36
    firstPage.bodyLabel.font = avenirNextRegular24
    firstPage.underTitlePadding = underTitlePaddingValue
    
    let secondPage = OnboardingContentViewController(title: "Want to know how you spend your time every day?", body: "I help monitor your daily activities and send fun and timely bits of information.", image: UIImage(named: "Jarvis"), buttonText: "") { () -> Void in
      // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }
    secondPage.titleLabel.font = avenirNextRegular24
    secondPage.bodyLabel.font = avenirNextRegular24
    secondPage.underTitlePadding = underTitlePaddingValue
    
    let thirdPage = OnboardingContentViewController(title: "Discover a song to help you workout?", body: "No problem.", image: UIImage(named: "Jarvis"), buttonText: "") { () -> Void in
      // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }
    thirdPage.titleLabel.font = avenirNextRegular24
    thirdPage.bodyLabel.font = avenirNextRegular24
    thirdPage.underTitlePadding = underTitlePaddingValue
    
    let fourthPage = OnboardingContentViewController(title: "Thinking of dinner while working late at the office?", body: "How about a meal deal?", image: UIImage(named: "Jarvis"), buttonText: "") { () -> Void in
      // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }
    fourthPage.titleLabel.font = avenirNextRegular24
    fourthPage.bodyLabel.font = avenirNextRegular24
    fourthPage.underTitlePadding = underTitlePaddingValue
    
    let fifthPage = OnboardingContentViewController(title: "Or maybe a funny video to brighten your day?", body: "I understand your current situation to surprise you every time!", image: UIImage(named: "Jarvis"), buttonText: "CONTINUE") { () -> Void in
      self.handleOnboardingIntroCompletion()
    }
    fifthPage.titleLabel.font = avenirNextRegular24
    fifthPage.bodyLabel.font = avenirNextRegular24
    fifthPage.actionButton.titleLabel?.font = avenirNextBold24
    fifthPage.actionButton.titleLabel?.textColor = globalTint
    fifthPage.underTitlePadding = underTitlePaddingValue
    
    let onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "OnboardingBackground"), contents: [firstPage, secondPage, thirdPage, fourthPage, fifthPage])
    onboardingVC.shouldMaskBackground = false
    onboardingVC.shouldFadeTransitions = true
    onboardingVC.fadePageControlOnLastPage = true
    onboardingVC.fadeSkipButtonOnLastPage = true
    return onboardingVC
  }
  
  func handleOnboardingIntroCompletion() {
    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("OnboardingGetNameViewController") as? OnboardingGetNameViewController {
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

