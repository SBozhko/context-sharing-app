//
//  FirstViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import RxSwift
import NEContextSDK
import Alamofire
import AdSupport
import Social
import MessageUI

class MeViewController: UIViewController {
  @IBOutlet weak var otherContextCollectionView: UICollectionView!
  @IBOutlet weak var situationView: UIView!
  @IBOutlet weak var situationImageView: UIImageView!
  @IBOutlet weak var situationLabel: UILabel!
  
  var uniqueMessageCode : NSString = ""
  let messageSubjectCodeLength = 10

  let reuseIdentifier = "Cell"
  let contextGroupCells : [NEContextGroup] = [NEContextGroup.Situation, NEContextGroup.Mood, NEContextGroup.Place, NEContextGroup.Weather, NEContextGroup.Activity, NEContextGroup.Lightness, NEContextGroup.TimeOfDay, NEContextGroup.DayCategory, NEContextGroup.IndoorOutdoor]
  var disposables : [Disposable] = []
  var collectionViewIndexPaths : [NSIndexPath] = []
  let log = Logger(loggerName: String(MeViewController))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(MeViewController.handleUserContextOverrideTimerExpired(_:)),
                                                     name: contextOverrideTimerExpiredNotification,
                                                     object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(MeViewController.handleProfileIdReceivedNotification(_:)),
                                                     name: profileIdReceivedNotification,
                                                     object: nil)
    let situationImagetapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(MeViewController.situationImageViewTapped))
    situationImageView.userInteractionEnabled = true
    situationImageView.addGestureRecognizer(situationImagetapGestureRecognizer)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if disposables.isEmpty {
      disposables.append(NEContextManager.sharedInstance.subscribe { context in
        self.log.info("Received context update: \(NEDayCategory.get()!.name.name): \(context.name)-\(context.group.name)")
        dispatch_async(dispatch_get_main_queue(), {
          if context.group == NEContextGroup.Situation {
            self.updateSituationView()
          } else {
            self.otherContextCollectionView.reloadData()
          }
        })
        self.postContextInfo([context])
      })
      initializeContexts()
    } else {
      self.updateSituationView()
      self.otherContextCollectionView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func handleUserContextOverrideTimerExpired(notification : NSNotification) {
    if self.isViewVisible() && UIApplication.sharedApplication().applicationState == .Active {
      self.updateSituationView()
      self.otherContextCollectionView.reloadData()
    }
  }
  
  func handleProfileIdReceivedNotification(notification : NSNotification) {
    initializeContexts()
  }
  
  func situationImageViewTapped() {
    selectedContext(NEContextGroup.Situation)
  }
  
  func initializeContexts() {
    var contextsToPost : [NEContext] = []
    for contextGroup in contextGroupCells {
      if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup).context {
        contextsToPost.append(validContext)
      }
    }
    if !contextsToPost.isEmpty {
      postContextInfo(contextsToPost)
    }
  }
  
  func postContextInfo(contextsToPost : [NEContext]) {
    if let _profileId = Credentials.sharedInstance.profileId {
      var contextDataParameters : [[String : String]] = [[:]]
      contextDataParameters.removeLast()
      for context in contextsToPost {
        contextDataParameters.append(["ctxGroup" : context.group.name, "ctxName" : context.name.name])
      }
      
      let parameters : [String : AnyObject] = [
        "contextData": contextDataParameters,
        "profileId": _profileId
      ]
      
      Alamofire.request(.POST, postContextEndpoint, parameters: parameters, encoding: .JSON)
        .responseJSON { response in
          if let JSON = response.result.value {
            self.log.info("Received JSON POST response: \(JSON)")
          }
      }
    }
  }
  
  func updateSituationView() {
    let currentContext = ContextInfo.sharedInstance.getValidCurrentContext(NESituation.group)
    if let
      validContextName = currentContext.context,
      validContextImageName = currentContext.imageName {
      //      Send request for image
      situationImageView.image = UIImage(named: validContextImageName)
      situationLabel.text = ContextInfo.sharedInstance.getSituationDisplayMessage(validContextName.name)
    } else {
      //      Show loading image
      situationImageView.image = UIImage(named: "unknown")
      situationLabel.text = NESituation.group.name
    }
  }
  
  func socialMediaSharing(serviceType : String) {
    if SLComposeViewController.isAvailableForServiceType(serviceType) {
      let composeController = SLComposeViewController(forServiceType: serviceType)
      if !composeController.setInitialText("Shared via Jarvis") {
//        print("did not set initial text")
      }
      
      composeController.completionHandler = {result -> Void in
        if (result as SLComposeViewControllerResult) == SLComposeViewControllerResult.Done {
        }
      }
      self.presentViewController(composeController, animated: true, completion: nil)
    } else {
      let alert = UIAlertController(title: "Accounts", message: String("Please login to a %@ account to share.", serviceType.capitalizedString), preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  func shareOnWhatsApp() {
    let urlString = "Shared via Jarvis"
    let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    let url = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
    if UIApplication.sharedApplication().canOpenURL(url!) {
      UIApplication.sharedApplication().openURL(url!)
    }
  }
  
  func reportBug() {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.navigationItem.title = "File Bug"
      mail.mailComposeDelegate = self
      mail.setToRecipients(["hi@numbereight.me"])
      uniqueMessageCode = randomStringWithLength(messageSubjectCodeLength)
      mail.setSubject("Jarvis Beta \(getAppVersionString()) Feedback: ")
      mail.setMessageBody("\n\n--------------------\niOS \(UIDevice.currentDevice().systemVersion) / \(DeviceGuru.hardwareDescription()!)\nIdentifier: \(VendorInfo.getId())|\(uniqueMessageCode)\n", isHTML: false)
      presentViewController(mail, animated: true, completion: nil)
    }
  }
  
  @IBAction func unwindToMeVC(segue : UIStoryboardSegue) {
    if let identifier = segue.identifier {
      switch identifier {
      case "unwindToMeVCSegue":
        if let
          sourceController = segue.sourceViewController as? ContextPopoverViewController {
            if let
              _context = sourceController.context {
              var contextName = NEContextName.Other
              var userEnteredContextString = ""
              if let _userSelectedContextName = sourceController.selectedContextName {
                contextName = _userSelectedContextName
              }
              if let _userEnteredContext = sourceController.otherSelectedContextName {
                userEnteredContextString = _userEnteredContext
              }
              if contextName != NEContextName.Other || userEnteredContextString != "" {
                ContextInfo.sharedInstance.overrideCurrentContextSettings(_context.group, userSelectedContextName: contextName, userEnteredContextString: userEnteredContextString)
              }
              dispatch_async(dispatch_get_main_queue(), {
                if _context.group == NEContextGroup.Situation {
                  self.updateSituationView()
                } else {
                  self.otherContextCollectionView.reloadData()
                }
              })
            } else if let
              _contextGroup = sourceController.overriddenContextGroup {
              var contextName = NEContextName.Other
              var userEnteredContextString = ""
              if let _userSelectedContextName = sourceController.selectedContextName {
                contextName = _userSelectedContextName
              }
              if let _userEnteredContext = sourceController.otherSelectedContextName {
                userEnteredContextString = _userEnteredContext
              }
              if contextName != NEContextName.Other || userEnteredContextString != "" {
                ContextInfo.sharedInstance.overrideCurrentContextSettings(_contextGroup, userSelectedContextName: contextName, userEnteredContextString: userEnteredContextString)
              }
              dispatch_async(dispatch_get_main_queue(), {
                if _contextGroup == NEContextGroup.Situation {
                  self.updateSituationView()
                } else {
                  self.otherContextCollectionView.reloadData()
                }
              })
          }
        }
      default:
        break
      }
    }
  }
  
  func selectedContext(contextGroup : NEContextGroup) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let overriddenContext = ContextInfo.sharedInstance.getOverriddenContext(contextGroup)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("ContextPopoverViewController") as? ContextPopoverViewController {
      vc.modalPresentationStyle = .Popover
      let popover = vc.popoverPresentationController!
      popover.delegate = self
      popover.sourceView = self.view
      if overriddenContext.flag {
        vc.overriddenContextGroup = contextGroup
        if let _contextName = overriddenContext.contextName {
          vc.overriddenContextName = _contextName
        } else if let _userEnteredContextString = overriddenContext.userContextString {
          vc.overriddenUserEnteredContextString = _userEnteredContextString
        }
      } else if let currentContext = ContextInfo.sharedInstance.getCurrentContext(contextGroup).context {
        vc.context = currentContext
      }
      presentViewController(vc, animated: true, completion: nil)
    }
  }
  
  @IBAction func shareButtonPressed() {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let twitterAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.socialMediaSharing(SLServiceTypeTwitter)
    })
    let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.socialMediaSharing(SLServiceTypeFacebook)
    })
    let whatsappAction = UIAlertAction(title: "WhatsApp", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.shareOnWhatsApp()
    })
    let fileBugAction = UIAlertAction(title: "Report a Bug", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.reportBug()
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
      (alert: UIAlertAction!) -> Void in
//      print("Cancelled")
    })
    optionMenu.addAction(twitterAction)
    optionMenu.addAction(facebookAction)
    optionMenu.addAction(whatsappAction)
    optionMenu.addAction(fileBugAction)
    optionMenu.addAction(cancelAction)
    self.presentViewController(optionMenu, animated: true, completion: nil)
  }
}

extension MeViewController : MFMailComposeViewControllerDelegate {
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    if result == MFMailComposeResultSent {
      let logId = uniqueMessageCode as String
      NELogging.dumpLogsForId(logId)
      Logging.sharedInstance.userInitiatedLogDump(logId)
    }
  }
}

extension MeViewController : UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.OverFullScreen
  }
  
  func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
    return true
  }
}

extension MeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    selectedContext(contextGroupCells[indexPath.row+1])
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MeCollectionViewCell
    let contextGroupCellIndex = indexPath.row+1
    let contextGroup = contextGroupCells[contextGroupCellIndex]
    let overriddenContext = ContextInfo.sharedInstance.getOverriddenContext(contextGroup)
    if overriddenContext.flag {
      if let contextName = overriddenContext.contextName {
        cell.imageView.image = UIImage(named: contextName.name.lowercaseString)
        cell.contextLabel.text = contextName.name
      } else if let userContextString = overriddenContext.userContextString {
        cell.contextLabel.text = userContextString
        cell.imageView.image = UIImage(named: "unknown")
      } else {
        //      Show loading image
        cell.imageView.image = UIImage(named: "unknown")
        cell.contextLabel.text = contextGroup.name
      }
    } else {
      let currentContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup)
      if let
        validContextName = currentContext.context,
        validContextImageName = currentContext.imageName {
        //      Send request for image
        cell.imageView.image = UIImage(named: validContextImageName)
        cell.contextLabel.text = contextGroup == NEContextGroup.Situation ?
          ContextInfo.sharedInstance.getSituationDisplayMessage(validContextName.name) :
          validContextName.name.name
      } else {
        //      Show loading image
        cell.imageView.image = UIImage(named: "unknown")
        cell.contextLabel.text = contextGroup.name
      }
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (contextGroupCells.count - 1)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {
    let size : CGSize  = CGSizeMake(collectionView.frame.size.width/4-15, collectionView.frame.size.width/4+20-15)
    return size
  }
}