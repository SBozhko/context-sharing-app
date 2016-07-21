//
//  SituationPopoverViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK

class ContextPopoverViewController: UIViewController {
  var context : NEContext?
  var overriddenContextName : NEContextName?
  var overriddenUserEnteredContextString : String?
  var overriddenContextGroup : NEContextGroup?
  
  @IBOutlet weak var contextLabel: UILabel!
  @IBOutlet weak var confidenceLabel: UILabel!
  var selectedContextName : NEContextName?
  var otherSelectedContextName : String?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    if let _context = context {
      print("Context Confidence: \(_context.confidence)")
      dispatch_async(dispatch_get_main_queue(), {
        self.contextLabel.text = "\(_context.name.name)"
        self.confidenceLabel.text = "\((_context.confidence*100.0).roundTo(2))%"
      })
    } else if let
      _overriddenContextName = overriddenContextName {
      print("Context Confidence: 100%")
      dispatch_async(dispatch_get_main_queue(), {
        self.contextLabel.text = "\(_overriddenContextName.name)"
        self.confidenceLabel.text = "100%"
      })
    } else if let
      _overriddenUserEnteredContextString = overriddenUserEnteredContextString {
      print("Context Confidence: 100%")
      dispatch_async(dispatch_get_main_queue(), {
        self.contextLabel.text = "\(_overriddenUserEnteredContextString)"
        self.confidenceLabel.text = "100%"
      })
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case "contextFeedbackSegue":
        if let
          destController = segue.destinationViewController as? ContextFeedbackViewController {
          if let _context = context {
            destController.context = _context
          } else if let
            _overriddenContextGroup = overriddenContextGroup {
            destController.overriddenContextGroup = _overriddenContextGroup
          }
        }
      default:
        break
      }
    }
  }
  
  @IBAction func unwindToContextPopoverVC(segue : UIStoryboardSegue) {
    if let identifier = segue.identifier {
      switch identifier {
      case "unwindToContextPopoverSegue":
        if let
          sourceController = segue.sourceViewController as? ContextFeedbackViewController {
          dispatch_async(dispatch_get_main_queue(), {
            if let _selectedContext = sourceController.selectedContext.first?.0 {
              self.contextLabel.text = _selectedContext.name
              self.selectedContextName = _selectedContext
              self.confidenceLabel.text = "100%"
            } else if let _otherOptionLabelText = sourceController.otherOptionLabel.text {
              self.contextLabel.text = _otherOptionLabelText
              self.otherSelectedContextName = _otherOptionLabelText
              self.confidenceLabel.text = "100%"
            }          
          })
        }
      default:
        break
      }
    }
  }
}