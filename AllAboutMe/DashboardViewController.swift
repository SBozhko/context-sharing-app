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
import AdSupport

class DashboardViewController: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var placeImageView: UIImageView!
  @IBOutlet weak var moodImageView: UIImageView!
  @IBOutlet weak var timeImageView: UIImageView!
  @IBOutlet weak var weatherImageView: UIImageView!
  @IBOutlet weak var indoorOutdoorImageView: UIImageView!
  @IBOutlet weak var activityImageView: UIImageView!
  @IBOutlet weak var surpriseMeImageView: UIImageView!
  @IBOutlet weak var situationButton: UIButton!
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
        self.log.info("Received context update: \(NEDayCategory.get()!.name.name): \(context.name)-\(context.group.name)")
        dispatch_async(dispatch_get_main_queue(), {
          switch context.group {
          case .Activity:
            self.activityImageView.image = UIImage(named: Images.getImageName(context.name, contextGroup: context.group))
          case .IndoorOutdoor:
            self.indoorOutdoorImageView.image = UIImage(named: Images.getImageName(context.name, contextGroup: context.group))
          case .TimeOfDay:
            self.timeImageView.image = UIImage(named: Images.getImageName(context.name, contextGroup: context.group))
          default:
            break
          }
        })
        self.postContextInfo([context])
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
  
  func postContextInfo(contextsToPost : [NEContext], manual : Bool = false) {
    if let _profileId = Credentials.sharedInstance.profileId {
      var contextDataParameters : [[String : AnyObject]] = [[:]]
      contextDataParameters.removeLast()
      for context in contextsToPost {
        contextDataParameters.append(["ctxGroup" : context.group.name, "ctxName" : context.name.name, "manual" : manual])
      }
      
      let parameters : [String : AnyObject] = [
        "contextData": contextDataParameters,
        "profileId": _profileId
      ]
      
      log.debug("Sending parameters: \(contextDataParameters)")
      Alamofire.request(.POST, postContextEndpoint, parameters: parameters, encoding: .JSON)
        .responseJSON { response in
          if let JSON = response.result.value {
            self.log.info("Received JSON POST response: \(JSON)")
          }
      }
    }
  }
  
  func updateDashboardImage(context : NEContext) {
    switch context.group {
    case .Activity:
      activityImageView.image = UIImage(named: Images.getImageName(context.name, contextGroup: context.group))
    case .IndoorOutdoor:
      indoorOutdoorImageView.image = UIImage(named: Images.getImageName(context.name, contextGroup: context.group))
    case .TimeOfDay:
      timeImageView.image = UIImage(named: Images.getImageName(context.name, contextGroup: context.group))
    default:
      break
    }
  }
  
  func handleImageTapGesture(gestureRecognizer: UITapGestureRecognizer) {
    if let _imageView = gestureRecognizer.view as? UIImageView {
      print("Tag \(_imageView.tag)")
      
      switch (ContextType(rawValue: _imageView.tag)!) {
      case .Place:
        /* Place image */
        break
      case .Mood:
        /* Mood image */
        performSegueWithIdentifier("showContextUpdateSegue", sender: ContextInfo.sharedInstance.getCurrentContext(NEContextGroup.Mood).context)
        break
      case .Time:
        /* Time image */
        break
      case .SurpriseMe:
        /* Surprise Me image */
        userRequested = true
        handleSurpriseMe()
        break
      case .Weather:
        /* Weather image */
        break
      case .IndoorOutdoor:
        /* Indoor/Outdoor image */
        break
      case .Activity:
        /* Activity image */
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
            destController.context = localContext
          }
        }
      default:
        break
      }
    }
  }
}
