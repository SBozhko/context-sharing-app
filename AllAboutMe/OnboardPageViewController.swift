//
//  OnboardPageViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/11/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class OnboardPageViewController : UIPageViewController {
  // Some hard-coded data for our walkthrough screens
  var pageHeaders = ["Recapture the serendipity in your life through the sensors in your smartphone", "Jarvis helps visualize how you spend your time -- automatically.", "Boosts your workout with a new song", "Hungry while working late? Jarvis might just have a deal for you. And lots more ..."]
  var pageImages = ["Jarvis", "OnboardAnalytics", "OnboardMusic", "OnboardDinner"]
//  var pageDescriptions = ["Learn to design the world's most beautiful iOS apps without having to hire a designer.", "Validate your app idea by creating a prototype before implementation", "Delight your users with stunning animation and transition", "Connect people together!"]
  
  // make the status bar white (light content)
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // This class is the page view controller's data source itself
    self.dataSource = self
    
    // Create the first onboard vc
    if let startWalkthroughVC = self.viewControllerAtIndex(0) {
      setViewControllers([startWalkthroughVC], direction: .Forward, animated: true, completion: nil)
    }
  }
  
  // MARK: - Navigate
  
  func nextPageWithIndex(index : Int) {
    if let nextWalkthroughVC = self.viewControllerAtIndex(index+1) {
      setViewControllers([nextWalkthroughVC], direction: .Forward, animated: true, completion: nil)
    }
  }
  
  func viewControllerAtIndex(index: Int) -> WalkthroughViewController? {
    if index == NSNotFound || index < 0 || index >= self.pageHeaders.count {
      return nil
    }
    
    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
    // create a new walkthrough view controller and assing appropriate date
    if let walkthroughViewController = storyboard.instantiateViewControllerWithIdentifier("WalkthroughViewController") as? WalkthroughViewController {
      walkthroughViewController.imageName = pageImages[index]
      walkthroughViewController.headerText = pageHeaders[index]
      walkthroughViewController.index = index
      
      return walkthroughViewController
    }
    
    return nil
  }
}

extension OnboardPageViewController : UIPageViewControllerDataSource {
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    var index = (viewController as! WalkthroughViewController).index
    index += 1
    return self.viewControllerAtIndex(index)
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    var index = (viewController as! WalkthroughViewController).index
    index -= 1
    return self.viewControllerAtIndex(index)
  }
}
