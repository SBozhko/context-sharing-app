//
//  OnboardingPermissionsViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/10/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import NEContextSDK

class OnboardingPermissionsViewController: UIViewController {
  @IBOutlet weak var greetingLabel: UILabel!
  @IBOutlet weak var useLocationButton: UIButton!
  @IBOutlet weak var useActivityButton: UIButton!
  let log = Logger(loggerName: String(OnboardingPermissionsViewController))

  var sensorPermissionsGranted : Bool {
    get {
      if let
        _locationBackgroundColor = useLocationButton.backgroundColor,
        _activityBackgroundColor = useActivityButton.backgroundColor {
        if _locationBackgroundColor == UIColor.greenColor() && _activityBackgroundColor == UIColor.greenColor() {
          return true
        }
      }
      return false
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    greetingLabel.text = "Nice to meet you \(Credentials.sharedInstance.name)!"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // make the status bar white (light content)
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
    
  @IBAction func useLocationButtonPressed(sender: AnyObject) {
//    let locationManager = CLLocationManager()
//    locationManager.requestAlwaysAuthorization()
//    if sensorPermissionsGranted {
//      performSegueWithIdentifier("finishIntroSegue", sender: self)
//    }
    performSegueWithIdentifier("finishIntroSegue", sender: self)
  }
    
  @IBAction func useActivityButtonPressed(sender: AnyObject) {
//    let motionActivityManager = CMMotionActivityManager()
//    if CMMotionActivityManager.isActivityAvailable() {
//      motionActivityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (activity) in
//        motionActivityManager.stopActivityUpdates()
//        dispatch_async(dispatch_get_main_queue(), {
//          self.useActivityButton.backgroundColor = UIColor.greenColor()
//          if self.sensorPermissionsGranted {
//            self.performSegueWithIdentifier("finishIntroSegue", sender: self)
//          }
//        })
//      })
//    }
//
//    if sensorPermissionsGranted {
//      performSegueWithIdentifier("finishIntroSegue", sender: self)
//    }
    performSegueWithIdentifier("finishIntroSegue", sender: self)
  }
}

extension OnboardingPermissionsViewController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    // permission changed, do something with the buffer of questions asked
    log.info("Received location authorization status: \(status.rawValue)")
    switch status {
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      dispatch_async(dispatch_get_main_queue(), {
        self.useLocationButton.backgroundColor = UIColor.greenColor()
      })
    default:
      let alertController = UIAlertController(title: "Limited functionality", message: "We use background location to show you interesting insights based on your day-to-day life. Without it, the app's functionality will be limited.", preferredStyle: UIAlertControllerStyle.Alert)
      let doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil)
      alertController.addAction(doneAction)
      self.presentViewController(alertController, animated: true, completion: nil)
      break
    }
  }
}
