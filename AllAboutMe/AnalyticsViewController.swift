//
//  AnalyticsViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import Charts
import NEContextSDK
import Alamofire
import SwiftyJSON

class AnalyticsViewController: UIViewController {

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  @IBAction func handleButtonPressed(sender : UIButton) {
    sender.titleLabel
    if let
      localTitle = sender.titleLabel,
      titleText = localTitle.text {
      var contextGroup = NEContextGroup.Situation
      switch titleText {
        case "ACTIVITIES":
          contextGroup = NEContextGroup.Activity
        case "PLACES":
          contextGroup = NEContextGroup.Place
        case "MOODS":
          contextGroup = NEContextGroup.Mood
        case "IN - OUTDOORS":
          contextGroup = NEContextGroup.IndoorOutdoor
        default:
          contextGroup = NEContextGroup.Situation
      }
      performSegueWithIdentifier("showAnalyticsSegue", sender: contextGroup.name)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if identifier == "showAnalyticsSegue" {
        if let
          destController = segue.destinationViewController as? AnalyticsPopupViewController {
          if let contextGroup = sender as? String {
            destController.contextGroup = contextGroup
          }
        }
      }
    }
  }
}
