//
//  ContextFeedbackViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK

class ContextFeedbackViewController: UIViewController {

  @IBOutlet weak var contextOptionsCollectionView: UICollectionView!
  
  var context : NEContext?
  var listOfContextNames : [NEContextName] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _context = context {
      listOfContextNames = ContextInfo.sharedInstance.getContextListForContextGroup(_context.group)
    }
  }
  
  @IBAction func updateButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ContextFeedbackViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
  
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MeCollectionViewCell
    if !listOfContextNames.isEmpty {
      //      Send request for image
      cell.imageView.image = UIImage(named: listOfContextNames[indexPath.row].name.lowercaseString)
      cell.contextLabel.text = listOfContextNames[indexPath.row].name
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return listOfContextNames.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {
    let size : CGSize  = CGSizeMake(collectionView.frame.size.width/4-5, collectionView.frame.size.width/4 + 30-5)
    return size
  }
}
