//
//  SituationPopoverViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK

class SituationPopoverViewController: UIViewController {
  var situation : NEContext?
  
  @IBOutlet weak var situationLabel: UILabel!
  @IBOutlet weak var confidenceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    if let _situation = situation {
      print("Situation Confidence: \(_situation.confidence)")
      dispatch_async(dispatch_get_main_queue(), {
        self.situationLabel.text = "\(_situation.name.name)"
        self.confidenceLabel.text = "\((_situation.confidence*100.0).roundTo(2))%"
      })
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func closePopover(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case "situationFeedbackSegue":
        if let
          destController = segue.destinationViewController as? ContextFeedbackViewController {
          destController.context = situation
      }
      default:
        break
      }
    }
  }
}

extension SituationPopoverViewController : UIPopoverPresentationControllerDelegate {
}