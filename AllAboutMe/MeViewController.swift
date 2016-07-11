//
//  FirstViewController.swift
//  AllAboutMe
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
import Toast

class MeViewController: UIViewController {
  @IBOutlet weak var situationCollectionView: UICollectionView!
  @IBOutlet weak var otherContextCollectionView: UICollectionView!
  var uniqueMessageCode : NSString = ""
  let messageSubjectCodeLength = 10

  let reuseIdentifier = "Cell"
  let contextGroupCells : [NEContextGroup] = [NEContextGroup.Situation, NEContextGroup.Mood, NEContextGroup.Place, NEContextGroup.Weather, NEContextGroup.Activity, NEContextGroup.Lightness, NEContextGroup.TimeOfDay, NEContextGroup.DayCategory, NEContextGroup.IndoorOutdoor]
  var disposables : [Disposable] = []
  var collectionViewIndexPaths : [NSIndexPath] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if disposables.isEmpty {
      disposables.append(NEContextManager.sharedInstance.subscribe { context in
        print("\(NEDayCategory.get()!.name.name): \(context.name)-\(context.group.name)")
        dispatch_async(dispatch_get_main_queue(), {
          if context.group == NEContextGroup.Situation {
            self.situationCollectionView.reloadData()
          } else {
            self.otherContextCollectionView.reloadData()
          }
        })
//        self.collectionView.reloadItemsAtIndexPaths(self.collectionViewIndexPaths)
        self.postContextInfo([context])
      })
      initializeContexts()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
    var contextDataParameters : [[String : String]] = [[:]]
    contextDataParameters.removeLast()
    for context in contextsToPost {
      contextDataParameters.append(["ctxGroup" : context.group.name, "ctxName" : context.name.name])
    }
    
    let parameters : [String : AnyObject] = [
      "userId": Logging.sharedInstance.getUniqueDeviceIdentifier,
      "vendorId": Logging.sharedInstance.getUniqueDeviceIdentifier,
      "contextData": contextDataParameters,
      "idfa": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
    ]
    
    Alamofire.request(.POST, postContextEndpoint, parameters: parameters, encoding: .JSON)
      .responseJSON { response in
        if let JSON = response.result.value {
          print("JSON: \(JSON)")
        }
      }
  }
  
  func socialMediaSharing(serviceType : String) {
    if SLComposeViewController.isAvailableForServiceType(serviceType) {
      let composeController = SLComposeViewController(forServiceType: serviceType)
      if !composeController.setInitialText("Shared via NumberEight's Ambience App.") {
        print("did not set initial text")
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
    let urlString = "Shared via NumberEight's Ambience App."
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
      mail.setSubject("NumberEight Ambience Beta \(getAppVersionString()) Feedback: ")
      mail.setMessageBody("\n\n--------------------\niOS \(UIDevice.currentDevice().systemVersion) / \(DeviceGuru.hardwareDescription()!)\nIdentifier: \(Logging.sharedInstance.getUniqueDeviceIdentifier)|\(uniqueMessageCode)\n", isHTML: false)
      presentViewController(mail, animated: true, completion: nil)
    }
  }
}

extension MeViewController : MFMailComposeViewControllerDelegate {
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    if result == MFMailComposeResultSent {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.view.makeToast("Thanks for reporting!", duration: 3.0, position: CSToastPositionBottom, style: nil)
      })
      Logging.sharedInstance.userInitiatedLogDump(uniqueMessageCode as String)
    }
  }
}

extension MeViewController : UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.None
  }
}

extension MeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let contextGroupCellIndex = collectionView == otherContextCollectionView ? indexPath.row+1 : 0
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let validCurrentContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroupCells[contextGroupCellIndex]).context {
      if collectionView == situationCollectionView {
        if let vc = storyboard.instantiateViewControllerWithIdentifier("SituationPopoverViewController") as? SituationPopoverViewController {
          vc.modalPresentationStyle = .Popover
          vc.situation = validCurrentContext
          let popover = vc.popoverPresentationController!
          popover.delegate = self
          popover.sourceView = self.view
          presentViewController(vc, animated: true, completion: nil)
        }
      } else {
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        if let vc = storyboard.instantiateViewControllerWithIdentifier("OtherContextPopoverViewController") as? OtherContextPopoverViewController {
          vc.modalPresentationStyle = .Popover
          vc.context = validCurrentContext
          let popover = vc.popoverPresentationController!
          popover.delegate = self
          popover.sourceView = self.view
          presentViewController(vc, animated: true, completion: nil)
        }
      }
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MeCollectionViewCell
    let contextGroupCellIndex = collectionView == otherContextCollectionView ? indexPath.row+1 : 0
    let contextGroup = contextGroupCellIndex == 0 ? NEContextGroup.Situation : contextGroupCells[contextGroupCellIndex]
    let currentContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup)
    if let
      validContextName = currentContext.context,
      validContextImageName = currentContext.imageName {
      //      Send request for image
      cell.imageView.image = UIImage(named: validContextImageName)
      cell.contextLabel.text = validContextName.name.name
    } else {
      //      Show loading image
      cell.imageView.image = UIImage(named: "unknown")
      cell.contextLabel.text = contextGroup.name
    }
    if collectionView == situationCollectionView {
      cell.shareButton.addTarget(self, action: #selector(MeViewController.shareButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    return cell
  }
  
  @IBAction func shareButtonPressed(sender: AnyObject) {
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
      print("Cancelled")
    })
    optionMenu.addAction(twitterAction)
    optionMenu.addAction(facebookAction)
    optionMenu.addAction(whatsappAction)
    optionMenu.addAction(fileBugAction)
    optionMenu.addAction(cancelAction)
    self.presentViewController(optionMenu, animated: true, completion: nil)
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == situationCollectionView {
      return 1
    } else {
      return (contextGroupCells.count - 1)
    }
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {
    if collectionView == situationCollectionView {
      let size : CGSize = CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.width+27)
      return size
    } else {
      let size : CGSize  = CGSizeMake(collectionView.frame.size.width/4-5, collectionView.frame.size.width/4 + 30-5)
      return size
    }
  }
}