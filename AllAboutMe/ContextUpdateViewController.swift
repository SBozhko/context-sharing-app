//
//  ContextUpdateViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/17/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK

protocol ContextUpdateDelegate {
  func backFromContextUpdate(contextGroup : NEContextGroup, selectedContext : NEContextName)
}

class ContextUpdateViewController: UIViewController, UIGestureRecognizerDelegate {
  @IBOutlet weak var contextGroupLabel: UILabel!
  @IBOutlet weak var currentContextStatementPrefixLabel: UILabel!
  @IBOutlet weak var currentContextStatementSuffixLabel: UILabel!
  @IBOutlet weak var currentContextImageView: UIImageView!
  @IBOutlet weak var contextChoicesCollectionView: UICollectionView!
  @IBOutlet weak var closeImageView: UIImageView!
  
  var context : NEContext!
  var listOfContextNames : [NEContextName] = []
  var selectedContext : [NEContextName : NSIndexPath] = [:]
  var contextGroup : NEContextGroup?
  var updateDelegate : ContextUpdateDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    listOfContextNames = ContextInfo.sharedInstance.getContextListForContextGroup(context.group).filter({ $0 != NEContextName.Unknown && $0 != NEContextName.Other && $0 != NEContextName.Normal && $0 != NEContextName.BeforeLunch })
    addImageViewModifications(closeImageView)
    contextGroup = context.group
    contextGroupLabel.text = contextGroup?.name.uppercaseString
    currentContextStatementPrefixLabel.text = ContextInfo.sharedInstance.getContextGroupStatement(contextGroup!)
    currentContextStatementSuffixLabel.text = context.name.name.lowercaseString
    currentContextImageView.image = UIImage(named: Images.getImageName(context.name.name, contextGroup: contextGroup!.name, mainContext: true))
  }

  func addImageViewModifications(imgView : UIImageView) {
    let recognizer = UITapGestureRecognizer(target: self, action:#selector(ContextUpdateViewController.handleImageTapGesture(_:)))
    recognizer.delegate = self
    imgView.addGestureRecognizer(recognizer)
  }
  
  func handleImageTapGesture(gestureRecognizer: UITapGestureRecognizer) {
    if let _imageView = gestureRecognizer.view as? UIImageView {
      switch _imageView.tag {
      case 0:
        closeButtonPressed()
        break
      default:
        break
      }
    }
  }

  func closeButtonPressed() {
    if selectedContext.count > 0 {
      updateDelegate?.backFromContextUpdate(contextGroup!, selectedContext : (selectedContext.first?.0)!)
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ContextUpdateViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let
      savedIndexPath = selectedContext[listOfContextNames[indexPath.row]]
      where savedIndexPath == indexPath {
      selectedContext.removeValueForKey(listOfContextNames[savedIndexPath.row])
//      cell!.contextOptionImageView.layer.borderWidth = 0.0
//      cell!.contextOptionImageView.layer.borderColor = UIColor.clearColor().CGColor
    } else {
      selectedContext[listOfContextNames[indexPath.row]] = indexPath
//      cell!.contextOptionImageView.layer.borderWidth = 3.0
//      cell!.contextOptionImageView.layer.borderColor = UIColor.blueColor().CGColor
      currentContextImageView.image = UIImage(named: Images.getImageName(listOfContextNames[indexPath.row].name, contextGroup: contextGroup!.name, mainContext: true))
      currentContextStatementSuffixLabel.text = listOfContextNames[indexPath.row].name.lowercaseString
    }
  }
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    if let
      savedIndexPath = selectedContext[listOfContextNames[indexPath.row]]
      where savedIndexPath == indexPath {
      selectedContext.removeValueForKey(listOfContextNames[savedIndexPath.row])
    }
//    cell!.contextOptionImageView.layer.borderWidth = 0.0
//    cell!.contextOptionImageView.layer.borderColor = UIColor.clearColor().CGColor
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ContextUpdateCollectionViewCell
    if !listOfContextNames.isEmpty {
      //      Send request for image
      cell.contextOptionImageView.image = UIImage(named: Images.getImageName(listOfContextNames[indexPath.row].name, contextGroup: contextGroup!.name, shadow: false))
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return listOfContextNames.count
  }
}
