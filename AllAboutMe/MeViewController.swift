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
      let contextInfo = ContextInfo.sharedInstance.getCurrentContext(contextGroup)
      if contextInfo.0 && contextInfo.1!.name != NEContextName.Unknown {
        contextsToPost.append(contextInfo.1!)
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
        print(JSON(data: (response.request?.HTTPBody)!))
        print(response.request)  // original URL request
        print(response.response) // URL response
        print(response.result)   // result of response serialization
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
    cell.contextLabel.text = contextGroup.name
    if ContextInfo.sharedInstance.getCurrentContext(contextGroup).0 {
//      Send request for image
      cell.imageView.image = UIImage(named: "relaxing")
    } else {
//      Show loading image
      cell.imageView.image = UIImage(named: "loading")      
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contextGroupCells.count
  }
}