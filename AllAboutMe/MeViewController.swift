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

extension MeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("Selected cell #\(indexPath.row)")
  }
  
  // make a cell for each cell index path
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    // get a reference to our storyboard cell
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MeCollectionViewCell
    if collectionView == situationCollectionView {
      if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(NEContextGroup.Situation) {
        //      Send request for image
        cell.imageView.image = UIImage(named: "\(ContextInfo.sharedInstance.getContextImage(NEContextGroup.Situation))")
        cell.contextLabel.text = validContext.name.name
      } else {
        //      Show loading image
        cell.imageView.image = UIImage(named: "loading")
        cell.contextLabel.text = NEContextGroup.Situation.name
      }
    } else {
      // Use the outlet in our custom class to get a reference to the UILabel in the cell
      let contextGroup = contextGroupCells[indexPath.row+1]
      if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup) {
        //      Send request for image
        let contextImage = ContextInfo.sharedInstance.getContextImage(contextGroup)
        if contextImage.0 {
          cell.imageView.image = UIImage(named: contextImage.1)
        } else {
          cell.imageView.image = UIImage(named: "loading")
        }
        cell.contextLabel.text = validContext.name.name
      } else {
        //      Show loading image
        cell.imageView.image = UIImage(named: "loading")
        cell.contextLabel.text = contextGroup.name
      }
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
    let scale = UIScreen.mainScreen().scale as CGFloat
    let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    if collectionView == situationCollectionView {
      return CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    } else {
      return CGSizeMake(cellSize.width * scale/4, cellSize.height * scale/4)
    }
  }
}