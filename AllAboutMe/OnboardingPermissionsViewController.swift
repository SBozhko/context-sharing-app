//
//  OnboardingPermissionsViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/10/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import PermissionScope

class OnboardingPermissionsViewController: UIViewController {
  @IBOutlet weak internal var imageView: UIImageView!
  @IBOutlet weak var buttonLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  let log = Logger(loggerName: String(OnboardingPermissionsViewController))
  let pscope = PermissionScope()
  
  var permissionsGranted : Bool {
    get {
      if let
        locationPermission = self.permissions[PermissionType.LocationAlways],
        motionPermission = self.permissions[PermissionType.Motion] {
        if locationPermission == .Authorized && motionPermission == .Authorized {
          return true
        }
      }
      return false
    }
  }
  var permissions : [PermissionType : PermissionStatus] = [PermissionType.LocationAlways : PermissionStatus.Unknown, PermissionType.Motion : PermissionStatus.Unknown]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // If permissions have not yet been granted.
    pscope.addPermission(LocationAlwaysPermission(), message: "I use location info to show you suprising contextual insights and content.")
    pscope.addPermission(MotionPermission(), message: "I use activity info to automatically visualize your daily activities.")
    pscope.headerLabel.text = "Hey \(Credentials.name!)!"
    pscope.buttonFont = UIFont(name: "AvenirNext-Regular", size: 14.0)!
    pscope.labelFont = pscope.buttonFont
    self.messageLabel.text = "Nice to meet you \(Credentials.name!)! I need some device permissions before we get started."
    self.buttonLabel.text = "Ok"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // make the status bar white (light content)
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  func showPermissionsDialog() {
    // Show dialog with callbacks
    pscope.show({ finished, results in
      self.log.info("Permissions: \(results)")
        results.forEach({ (result) in
          self.permissions[result.type] = result.status
        })
        if self.permissionsGranted {
          dispatch_async(dispatch_get_main_queue(), {
            self.buttonLabel.text = "Let's start!"
            self.imageView.image = UIImage(named: "cheers")
            self.messageLabel.text = "Thanks \(Credentials.name!) - cheers!"
          })
        }
      }, cancelled: { (results) -> Void in
        print("thing was cancelled")
    })
  }
    
  @IBAction func introCompletionButtonPressed(sender: AnyObject) {
    if permissionsGranted {
      NSNotificationCenter.defaultCenter().postNotificationName(onboardingCompleteNotification, object: nil)
    } else {
      showPermissionsDialog()
    }
  }
}
