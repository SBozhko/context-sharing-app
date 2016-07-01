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

class MeViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  
  let reuseIdentifier = "Cell"
  let contextGroupCells : [NEContextGroup] = [NEContextGroup.Situation, NEContextGroup.Mood, NEContextGroup.Place, NEContextGroup.Weather, NEContextGroup.Activity, NEContextGroup.Lightness, NEContextGroup.TimeOfDay, NEContextGroup.DayCategory, NEContextGroup.IndoorOutdoor]
  var disposables : [Disposable] = []
  var collectionViewIndexPaths : [NSIndexPath] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    initializeContexts()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if disposables.isEmpty {
      disposables.append(NEContextManager.sharedInstance.subscribe { context in
        print("\(NEDayCategory.get()!.name.name): \(context.name)-\(context.group.name)")
        dispatch_async(dispatch_get_main_queue(), {
          self.collectionView.reloadData()
        })
//        self.collectionView.reloadItemsAtIndexPaths(self.collectionViewIndexPaths)
        self.postContextInfo([context])
      })
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
      contextDataParameters.append(["ctxType" : context.group.name, "ctxValue" : context.name.name])
    }
    let parameters : [String : AnyObject] = [
      "userId": "Abhishek123",
      "vendorId": Logging.sharedInstance.getVendorIdentifer,
      "contextData": contextDataParameters
    ]
    Alamofire.request(.POST, postContextEndpoint, parameters: parameters, encoding: .JSON)
      .responseJSON { response in
//        print(JSON(data: (response.request?.HTTPBody)!))
//        print(response.request)  // original URL request
//        print(response.response) // URL response
//        print(response.result)   // result of response serialization
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
    
    // Use the outlet in our custom class to get a reference to the UILabel in the cell
    let contextGroup = contextGroupCells[indexPath.row]
    if let validContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup) {
      //      Send request for image
      cell.imageView.image = UIImage(named: "relaxing")
      cell.contextLabel.text = validContext.name.name
    } else {
      //      Show loading image
      cell.imageView.image = UIImage(named: "loading")
      cell.contextLabel.text = contextGroup.name
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contextGroupCells.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {
    let scale = UIScreen.mainScreen().scale as CGFloat
    let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    return CGSizeMake(cellSize.width * scale/2, cellSize.height * scale/2)
  }
}