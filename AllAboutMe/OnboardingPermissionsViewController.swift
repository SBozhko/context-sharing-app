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
  let log = Logger(loggerName: String(OnboardingPermissionsViewController))
  
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
    let locationManager = CLLocationManager()
    locationManager.requestAlwaysAuthorization()
  }
}

extension OnboardingPermissionsViewController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    // permission changed, do something with the buffer of questions asked
    log.info("Received location authorization status: \(status.rawValue)")
    switch status {
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      performSegueWithIdentifier("finishIntroSegue", sender: self)
    default:
      let alertController = UIAlertController(title: "Limited functionality", message: "Without location permissions, the app's functionality will be limited.", preferredStyle: UIAlertControllerStyle.Alert)
      let doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil)
      alertController.addAction(doneAction)
      self.presentViewController(alertController, animated: true, completion: nil)
      break
    }
  }
}
