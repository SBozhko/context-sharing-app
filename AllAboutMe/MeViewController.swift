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
import SwiftyJSON
import AdSupport

class MeViewController: UIViewController {
  @IBOutlet weak var situationCollectionView: UICollectionView!
  @IBOutlet weak var otherContextCollectionView: UICollectionView!
  
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
      if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup) {
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
    print(ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString)
    let parameters : [String : AnyObject] = [
      "userId": "Abhishek123",
      "vendorId": Logging.sharedInstance.getVendorIdentifer,
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
}

extension MeViewController : UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.None
  }
}

extension MeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if collectionView == situationCollectionView {
      if let vc = storyboard.instantiateViewControllerWithIdentifier("SituationPopoverViewController") as? SituationPopoverViewController {
        vc.modalPresentationStyle = .Popover
        vc.situation = ContextInfo.sharedInstance.getValidCurrentContext(contextGroupCells[indexPath.row])
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        presentViewController(vc, animated: true, completion: nil)
      }
    } else {
      // Use the outlet in our custom class to get a reference to the UILabel in the cell
      if let vc = storyboard.instantiateViewControllerWithIdentifier("OtherContextPopoverViewController") as? OtherContextPopoverViewController {
        vc.modalPresentationStyle = .Popover
        vc.context = ContextInfo.sharedInstance.getValidCurrentContext(contextGroupCells[indexPath.row+1])
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        presentViewController(vc, animated: true, completion: nil)
      }
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MeCollectionViewCell
    let contextGroupCellIndex = collectionView == otherContextCollectionView ? indexPath.row+1 : 0
    let contextGroup = contextGroupCellIndex == 0 ? NEContextGroup.Situation : contextGroupCells[contextGroupCellIndex]
    if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup) {
      //      Send request for image
      let contextImage = ContextInfo.sharedInstance.getContextImage(contextGroup)
      if contextImage.flag {
        cell.imageView.image = UIImage(named: contextImage.imageName)
      } else {
        cell.imageView.image = UIImage(named: "unknown")
      }
      cell.contextLabel.text = validContext.name.name
    } else {
      //      Show loading image
      cell.imageView.image = UIImage(named: "loading")
      cell.contextLabel.text = contextGroup.name
    }
    return cell
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