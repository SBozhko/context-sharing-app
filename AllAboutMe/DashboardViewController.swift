//
//  DashboardViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/12/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import RxSwift
import NEContextSDK
import Mixpanel

class DashboardViewController: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var situationLabel: UILabel!
  @IBOutlet weak var placeImageView: UIImageView!
  @IBOutlet weak var moodImageView: UIImageView!
  @IBOutlet weak var timeImageView: UIImageView!
  @IBOutlet weak var weatherImageView: UIImageView!
  @IBOutlet weak var indoorOutdoorImageView: UIImageView!
  @IBOutlet weak var activityImageView: UIImageView!
  
  var disposables : [Disposable] = []
  let log = Logger(loggerName: String(DashboardViewController))
  let contextGroups : [NEContextGroup] = [NEContextGroup.Situation, NEContextGroup.Mood, NEContextGroup.Place, NEContextGroup.Weather, NEContextGroup.Activity, NEContextGroup.Lightness, NEContextGroup.TimeOfDay, NEContextGroup.DayCategory, NEContextGroup.IndoorOutdoor]
  var userRequested = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /* Add gesture recognizers */
    addImageViewModifications(placeImageView)
    addImageViewModifications(moodImageView)
    addImageViewModifications(timeImageView)
    addImageViewModifications(weatherImageView)
    addImageViewModifications(indoorOutdoorImageView)
    addImageViewModifications(activityImageView)
    let recognizer = UITapGestureRecognizer(target: self, action:#selector(DashboardViewController.handleImageTapGesture(_:)))
    recognizer.delegate = self
    situationLabel.addGestureRecognizer(recognizer)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(DashboardViewController.handleProfileIdReceivedNotification(_:)),
                                                     name: profileIdReceivedNotification,
                                                     object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(DashboardViewController.handleItemsAvailableNotification(_:)),
                                                     name: itemsAvailableNotification,
                                                     object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(DashboardViewController.handleContextUpdate(_:)),
                                                     name: contextUpdateNotification,
                                                     object: nil)
    if Credentials.sharedInstance.profileId != nil {
      Recommendations.sharedInstance.reloadRecommendations()
    }
    if let storedName = Credentials.name {
      self.situationLabel.text = "Hi \(storedName)!"
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if disposables.isEmpty {
      disposables.append(NEContextManager.sharedInstance.subscribe { context in
        self.log.info("Received context update: \(context.group.name): \(context.name)")
        if context.name != NEContextName.VeryHot && context.name != NEContextName.Cold &&
            context.name != NEContextName.Warm && context.name != NEContextName.Hot &&
          context.name != NEContextName.Freezing {
          ContextInfo.sharedInstance.postContextInfo([context])
        }
      })
      initializeContexts()
    } else {
//      self.updateSituationView()
//      self.otherContextCollectionView.reloadData()
    }
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  func addImageViewModifications(imgView : UIImageView, roundedCornerRadius : Bool = true) {
    let recognizer = UITapGestureRecognizer(target: self, action:#selector(DashboardViewController.handleImageTapGesture(_:)))
    recognizer.delegate = self
    imgView.addGestureRecognizer(recognizer)
    if roundedCornerRadius {
      imgView.layer.cornerRadius = imgView.frame.width / 2.0
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func handleProfileIdReceivedNotification(notification : NSNotification) {
    initializeContexts()
    Recommendations.sharedInstance.reloadRecommendations()
  }
  
  func initializeContexts() {
    var contextsToPost : [NEContext] = []
    for contextGroup in contextGroups {
      if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup).context {
        contextsToPost.append(validContext)
      }
    }
    if !contextsToPost.isEmpty {
      ContextInfo.sharedInstance.postContextInfo(contextsToPost)
    }
  }
    
  func updateDashboardImage(contextName : String, contextGroup : String) {
    var toImageView : UIImageView?
    var toImage : UIImage?
    switch contextGroup {
    case NEContextGroup.Activity.name:
      toImageView = activityImageView
      toImage = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.IndoorOutdoor.name:
      toImageView = indoorOutdoorImageView
      toImage = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.TimeOfDay.name:
      toImageView = timeImageView
      toImage = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Weather.name:
      toImageView = weatherImageView
      toImage = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Place.name:
      toImageView = placeImageView
      toImage = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Mood.name:
      toImageView = moodImageView
      toImage = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Situation.name:
      UIView.transitionWithView(self.situationLabel, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
        self.situationLabel.text = "\(ContextInfo.sharedInstance.getDashboardSituationDisplayMessage(contextName))"
        }, completion: nil)
      return
    default:
      break
    }

    if let
      localToImageView = toImageView,
      localToImage = toImage {
      UIView.transitionWithView(localToImageView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
        localToImageView.image = localToImage
      }, completion: nil)
    }
  }
  
  @objc func handleContextUpdate(notification : NSNotification) {
    if let contextUpdate : [String : String] = notification.object as? [String : String] {
      dispatch_async(dispatch_get_main_queue(), {
        self.updateDashboardImage(contextUpdate.first!.0, contextGroup: contextUpdate.first!.1)
      })
    }
  }
  
  func handleImageTapGesture(gestureRecognizer: UITapGestureRecognizer) {
    if let _imageView = gestureRecognizer.view as? UIImageView {      
      switch (ContextType(rawValue: _imageView.tag)!) {
      case .Place:
        /* Place image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.Place).context)
        break
      case .Mood:
        /* Mood image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.Mood).context)
        break
      case .Time:
        /* Time image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.TimeOfDay).context)
        break
      case .Weather:
        /* Weather image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.Weather).context)
        break
      case .IndoorOutdoor:
        /* Indoor/Outdoor image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.IndoorOutdoor).context)
        break
      case .Activity:
        /* Activity image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.Activity).context)
        break
      default:
        break
      }
    } else if let localLabelView = gestureRecognizer.view as? UILabel {
      switch (ContextType(rawValue: localLabelView.tag)!) {
      case .Situation:
        /* Situation image */
        /* Activity image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.Situation).context)
        break
      default:
        break
      }
    }
  }
  
  func handleItemsAvailableNotification(notification : NSNotification) {
    if userRequested && UIApplication.sharedApplication().applicationState == UIApplicationState.Active && self.isViewVisible() {
      handleSurpriseMe()
    }
  }
  
  @IBAction func handleGoButtonPressed(sender : UIButton) {
    userRequested = true
    handleSurpriseMe()
  }
  
  func handleSurpriseMe() {
    if userRequested {
      if let _items = Recommendations.sharedInstance.getItems(2) {
        Mixpanel.sharedInstance().track("SurpriseMePressed", properties: [
          "SituationName" : situationLabel.text ?? "Unknown"])
        userRequested = false
        performSegueWithIdentifier("hitMeSegue", sender: _items)
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case "hitMeSegue":
        if let
          destController = segue.destinationViewController as? ItemListViewController {
          if let _items = sender as? [RecommendedItem] {
            destController.items = _items
          }
        }
      case "showContextUpdateSegue":
        if let
          destController = segue.destinationViewController as? ContextUpdateViewController {
          if let localContext = sender as? NEContext {
            destController.updateDelegate = self
            destController.context = localContext
          }
        }
      default:
        break
      }
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension DashboardViewController : ContextUpdateDelegate {
  func backFromContextUpdate(contextGroup : NEContextGroup, selectedContext : NEContextName) {
    ContextInfo.sharedInstance.postManualContextInfo((selectedContext.name, contextGroup.name))
  }
}
