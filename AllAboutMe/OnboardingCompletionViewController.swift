//
//  OnboardingCompletionViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/10/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class OnboardingCompletionViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // make the status bar white (light content)
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
    
  @IBAction func onboardingCompleteButtonPressed(sender: AnyObject) {
    NSNotificationCenter.defaultCenter().postNotificationName(onboardingCompleteNotification, object: nil)
    performSegueWithIdentifier("onboardingCompleteSegue", sender: self)
//    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
