//
//  ContextFeedbackViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK

class ContextFeedbackViewController: UIViewController {

  @IBOutlet weak var contextOptionsCollectionView: UICollectionView!  
  @IBOutlet weak var otherOptionLabel: UILabel!
  @IBOutlet weak var updateButton: UIButton!
  
  var context : NEContext?
  var overriddenContextGroup : NEContextGroup?
  var listOfContextNames : [NEContextName] = []
  var selectedContext : [NEContextName : NSIndexPath] = [:]
  var selectedOtherContext : String?
  weak var alertDoneAction : UIAlertAction?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _context = context {
      listOfContextNames = ContextInfo.sharedInstance.getContextListForContextGroup(_context.group)
    } else if let _overriddenContextGroup = overriddenContextGroup {
      listOfContextNames = ContextInfo.sharedInstance.getContextListForContextGroup(_overriddenContextGroup)
    }
    listOfContextNames.removeObject(NEContextName.Unknown)
    listOfContextNames.removeObject(NEContextName.Other)
    self.contextOptionsCollectionView.allowsMultipleSelection = false
  }
  
  func showOtherOptionsAlert() {
    let alertController = UIAlertController(title: "Add your option", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    let doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
      alert -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        let textField = alertController.textFields![0] as UITextField
        if let _userEnteredText = textField.text where !_userEnteredText.isEmpty {
          self.otherOptionLabel.text = textField.text
          self.selectedOtherContext = textField.text
          if let selectedIndexPaths = self.contextOptionsCollectionView.indexPathsForSelectedItems() {
            for indexPath in selectedIndexPaths {
              let cell = self.contextOptionsCollectionView.cellForItemAtIndexPath(indexPath) as? MeCollectionViewCell
              cell!.imageView.layer.borderWidth = 0.0
              cell!.imageView.layer.borderColor = UIColor.clearColor().CGColor
            }
          }
          self.selectedContext.removeAll()
        }
      })
    })
    doneAction.enabled = false
    alertDoneAction = doneAction
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
      (action : UIAlertAction!) -> Void in
      self.otherOptionLabel.text = ""
    })
    
    alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
      textField.placeholder = "Enter your option"
//      textField.delegate = self
      textField.autocapitalizationType = UITextAutocapitalizationType.Words
      textField.addTarget(self, action: #selector(ContextFeedbackViewController.alertControllerTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    alertController.addAction(doneAction)
    alertController.addAction(cancelAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func alertControllerTextFieldDidChange(textField : UITextField) {
    if let saveAction = alertDoneAction {
      saveAction.enabled = textField.text?.characters.count >= 1
    }
  }
  
  @IBAction func otherOptionButtonPressed(sender: AnyObject) {
    showOtherOptionsAlert()
  }
  
  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ContextFeedbackViewController : UITextFieldDelegate {

}

extension ContextFeedbackViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MeCollectionViewCell
    if let
      savedIndexPath = selectedContext[listOfContextNames[indexPath.row]]
        where savedIndexPath == indexPath {
      selectedContext.removeValueForKey(listOfContextNames[savedIndexPath.row])
      cell!.imageView.layer.borderWidth = 0.0
      cell!.imageView.layer.borderColor = UIColor.clearColor().CGColor
      self.otherOptionLabel.text = ""
    } else {
      selectedContext[listOfContextNames[indexPath.row]] = indexPath
      cell!.imageView.layer.borderWidth = 3.0
      cell!.imageView.layer.borderColor = UIColor.blueColor().CGColor
      self.otherOptionLabel.text = ""
    }
  }
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MeCollectionViewCell
    if let
      savedIndexPath = selectedContext[listOfContextNames[indexPath.row]]
      where savedIndexPath == indexPath {
      selectedContext.removeValueForKey(listOfContextNames[savedIndexPath.row])
    }
    cell!.imageView.layer.borderWidth = 0.0
    cell!.imageView.layer.borderColor = UIColor.clearColor().CGColor
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
    let size : CGSize = CGSizeMake(collectionView.frame.size.width/4-5, collectionView.frame.size.width/4 + 25-5)
    return size
  }
}
