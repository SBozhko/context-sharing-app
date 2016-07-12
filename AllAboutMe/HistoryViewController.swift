//
//  HistoryViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import Charts
import NEContextSDK
import Alamofire
import SwiftyJSON

class HistoryViewController: UIViewController {
  
  var plotsToShow = [NEContextGroup.Situation, NEContextGroup.Place, NEContextGroup.Activity, NEContextGroup.IndoorOutdoor]
  let reuseIdentifier = "Cell"

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
}

extension HistoryViewController : UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.OverFullScreen
  }
}

extension HistoryViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let contextGroup = plotsToShow[indexPath.row]
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("AnalyticsPopupViewController") as? AnalyticsPopupViewController {
      vc.modalPresentationStyle = .Popover
      vc.contextGroup = contextGroup
      let popover = vc.popoverPresentationController!
      popover.delegate = self
      popover.sourceView = self.view
      presentViewController(vc, animated: true, completion: nil)
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MeCollectionViewCell
    let contextGroup = plotsToShow[indexPath.row]
    switch (contextGroup) {
    case .Situation:
      cell.imageView.image = UIImage(named: "party")
      cell.contextLabel.text = "Situations"
    case .Activity:
      cell.imageView.image = UIImage(named: "activity")
      cell.contextLabel.text = "Activities"
    case .Place:
      cell.imageView.image = UIImage(named: "places")
      cell.contextLabel.text = "Places"
    case .IndoorOutdoor:
      cell.imageView.image = UIImage(named: "io")
      cell.contextLabel.text = "Indoor/Outdoor"
    default:
      cell.imageView.image = UIImage(named: "unknown")
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return plotsToShow.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {
    let size : CGSize  = CGSizeMake(collectionView.frame.size.width/2-5, collectionView.frame.size.width/2 + 30-5)
    return size
  }
}
