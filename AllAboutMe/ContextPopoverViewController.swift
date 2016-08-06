//
//  SituationPopoverViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK
import Mixpanel
import Toast

class ContextPopoverViewController: UIViewController {
  var context : NEContext?
  var overriddenContextName : NEContextName?
  var overriddenUserEnteredContextString : String?
  var overriddenContextGroup : NEContextGroup?
  
  @IBOutlet weak var contextLabel: UILabel!
  @IBOutlet weak var confidenceLabel: UILabel!
  var selectedContextName : NEContextName?
  var otherSelectedContextName : String?
  let log = Logger(loggerName: String(ContextPopoverViewController))

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    if let _context = context {
      dispatch_async(dispatch_get_main_queue(), {
        self.contextLabel.text = "\(_context.name.name)"
        self.confidenceLabel.text = "\((_context.confidence*100.0).roundTo(2))%"
      })
    } else if let
      _overriddenContextName = overriddenContextName {
      dispatch_async(dispatch_get_main_queue(), {
        self.contextLabel.text = "\(_overriddenContextName.name)"
        self.confidenceLabel.text = "100%"
      })
    } else if let
      _overriddenUserEnteredContextString = overriddenUserEnteredContextString {
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
            self.log.debug("Incorrect button pressed: \(_context.group.name) \(_context.name.name) \(_context.confidence)")
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
  
  @IBAction func correctButtonPressed(sender: AnyObject) {
    self.view.makeToast("Thanks for confirming! We're improving every day.", duration: 2.0, position: CSToastPositionCenter)    
    Mixpanel.sharedInstance().track("CorrectButtonPressed", properties: [
      "ContextGroup" : context?.group.name ?? "Unknown",
      "ContextName" : context?.name.name ?? "Unknown"])
    self.log.debug("Correct button pressed: \(context?.group.name) \(context?.name.name) \(context?.confidence)")
  }
  
  @IBAction func unwindToContextPopoverVC(segue : UIStoryboardSegue) {
    if let identifier = segue.identifier {
      switch identifier {
      case "unwindToContextPopoverSegue":
        if let
          sourceController = segue.sourceViewController as? ContextFeedbackViewController {
          dispatch_async(dispatch_get_main_queue(), {
            if let _selectedContext = sourceController.selectedContext.first?.0 {
              self.log.info("Previous context info: \(self.context?.group.name), \(self.contextLabel.text)")
              self.log.info("Corrected context info: \(_selectedContext.name)")
              Mixpanel.sharedInstance().track("IncorrectContextButtonPressed", properties: [
                "ContextGroup" : self.context?.group.name ?? "Unknown",
                "ContextNameBefore" : self.contextLabel.text ?? "Unknown",
                "ContextNameAfter" : _selectedContext.name,
                "ManuallyTyped" : false])
              if self.contextLabel.text != _selectedContext.name {
                // Update NE SDK with user feedback
                NEPlace.update(_selectedContext, placeContextString: nil)
                self.view.makeToast("Thanks for correcting! We're improving every day.", duration: 2.0, position: CSToastPositionCenter)
                self.contextLabel.text = _selectedContext.name
                self.selectedContextName = _selectedContext
                self.confidenceLabel.text = "100%"
              }
            } else if let _otherOptionLabelText = sourceController.otherOptionLabel.text where !_otherOptionLabelText.isEmpty {
              self.log.info("Previous context info: \(self.context?.group.name), \(self.contextLabel.text)")
              self.log.info("Corrected context info: \(_otherOptionLabelText)")
              Mixpanel.sharedInstance().track("IncorrectContextButtonPressed", properties: [
                "ContextGroup" : self.context?.group.name ?? "Unknown",
                "ContextNameBefore" : self.contextLabel.text ?? "Unknown",
                "ContextNameAfter" : _otherOptionLabelText,
                "ManuallyTyped" : true])
              // Update NE SDK with user feedback
              NEPlace.update(nil, placeContextString: _otherOptionLabelText)
              self.contextLabel.text = _otherOptionLabelText
              self.otherSelectedContextName = _otherOptionLabelText
              self.confidenceLabel.text = "100%"
              self.view.makeToast("Thanks for correcting! We're improving every day.", duration: 2.0, position: CSToastPositionCenter)
            }
          })
        }
      default:
        break
      }
    }
  }
}