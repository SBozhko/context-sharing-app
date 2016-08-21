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
import Alamofire
import SwiftyJSON

class DashboardViewController: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var situationView: UIView!
  @IBOutlet weak var situationImageView: UIImageView!
  @IBOutlet weak var situationLabel: UILabel!
  @IBOutlet weak var placeImageView: UIImageView!
  @IBOutlet weak var moodImageView: UIImageView!
  @IBOutlet weak var timeImageView: UIImageView!
  @IBOutlet weak var weatherImageView: UIImageView!
  @IBOutlet weak var indoorOutdoorImageView: UIImageView!
  @IBOutlet weak var activityImageView: UIImageView!
  @IBOutlet weak var surpriseMeImageView: UIImageView!
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
    addImageViewModifications(surpriseMeImageView)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(DashboardViewController.handleProfileIdReceivedNotification(_:)),
                                                     name: profileIdReceivedNotification,
                                                     object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(DashboardViewController.handleItemsAvailableNotification(_:)),
                                                     name: itemsAvailableNotification,
                                                     object: nil)
    if Credentials.sharedInstance.profileId != nil {
      Recommendations.sharedInstance.reloadRecommendations()
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
          self.postContextInfo([context])
        }
      })
      initializeContexts()
    } else {
//      self.updateSituationView()
//      self.otherContextCollectionView.reloadData()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func addImageViewModifications(imgView : UIImageView) {
    let recognizer = UITapGestureRecognizer(target: self, action:#selector(DashboardViewController.handleImageTapGesture(_:)))
    recognizer.delegate = self
    imgView.addGestureRecognizer(recognizer)
    imgView.layer.cornerRadius = imgView.frame.width / 2.0
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
      postContextInfo(contextsToPost)
    }
  }
  
  func postContextInfo(contextsToPost : [NEContext]) {
    if let _profileId = Credentials.sharedInstance.profileId {
      var contextDataParameters : [[String : AnyObject]] = [[:]]
      contextDataParameters.removeAll()
      for context in contextsToPost {
        contextDataParameters.append(["ctxGroup" : context.group.name, "ctxName" : context.name.name, "manual" : false])
      }
      
      let parameters : [String : AnyObject] = [
        "contextData": contextDataParameters,
        "profileId": _profileId
      ]
      
      log.debug("Sending parameters: \(contextDataParameters)")
      Alamofire.request(.POST, postContextEndpoint, parameters: parameters, encoding: .JSON)
        .responseJSON { response in
            dispatch_async(dispatch_get_main_queue(), {
            if let unwrappedResult = response.data {
              let json = JSON(data: unwrappedResult)
              let contexts = json["contextData"]
              for (_, subJson):(String, JSON) in contexts {
                print(subJson)
                self.updateDashboardImage(subJson["ctxName"].string!, contextGroup: subJson["ctxGroup"].string!)
              }
            }
          })
      }
    }
  }
  
  func postManualContextInfo(contextInfo : (contextName : String, contextGroup : String)) {
    if let _profileId = Credentials.sharedInstance.profileId {
      let contextDataParameters : [[String : AnyObject]] = [["ctxGroup" : contextInfo.contextGroup, "ctxName" : contextInfo.contextName, "manual" : true]]
      let parameters : [String : AnyObject] = [
        "contextData": contextDataParameters,
        "profileId": _profileId
      ]
      
      log.debug("Sending manual parameters: \(contextDataParameters)")
      Alamofire.request(.POST, postContextEndpoint, parameters: parameters, encoding: .JSON)
        .responseJSON { response in
          dispatch_async(dispatch_get_main_queue(), {
            if let unwrappedResult = response.data {
              let json = JSON(data: unwrappedResult)
              let contexts = json["contextData"]
              for (_, subJson):(String, JSON) in contexts {
                print(subJson)
                self.updateDashboardImage(subJson["ctxName"].string!, contextGroup: subJson["ctxGroup"].string!)
              }
            }
          })
      }
    }
  }
    
  func updateDashboardImage(contextName : String, contextGroup : String) {
    switch contextGroup {
    case NEContextGroup.Activity.name:
      activityImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.IndoorOutdoor.name:
      indoorOutdoorImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.TimeOfDay.name:
      timeImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Weather.name:
      weatherImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Place.name:
      placeImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Mood.name:
      moodImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
    case NEContextGroup.Situation.name:
      situationImageView.image = UIImage(named: Images.getImageName(contextName, contextGroup: contextGroup))
      situationLabel.text = "\(ContextInfo.sharedInstance.getSituationDisplayMessage(contextName))"
      situationView.hidden = false
    default:
      break
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
      case .SurpriseMe:
        /* Surprise Me image */
        userRequested = true
        handleSurpriseMe()
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
      case .Situation:
        /* Situation image */
        break
      }
    }
  }
  
  func handleItemsAvailableNotification(notification : NSNotification) {
    if userRequested {
      handleSurpriseMe()
    }
  }
  
  func handleSurpriseMe() {
    if userRequested {
      if let _items = Recommendations.sharedInstance.getItems(2) {
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
}

extension DashboardViewController : ContextUpdateDelegate {
  func backFromContextUpdate(contextGroup : NEContextGroup, selectedContext : NEContextName) {
    dispatch_async(dispatch_get_main_queue()) { 
      self.postManualContextInfo((selectedContext.name, contextGroup.name))
    }
  }
}
