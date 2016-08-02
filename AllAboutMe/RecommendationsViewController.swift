//
//  RecommendationsViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/1/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NEContextSDK

class RecommendationsViewController: UIViewController {
  var recommendedItems : [String] = []
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    recommendedItems.append("https://soundcloud.com/mattdimona/the-universe-we-dreamt")
    recommendedItems.append("https://www.youtube.com/watch?v=xIx0jK-dhWg")    
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
//    if let _profileId = Credentials.sharedInstance.profileId {
//      let newContentEndpoint = "\(getContextHistoryEndpoint)/\(_profileId)?ctx=\(ContextInfo.sharedInstance.getValidCurrentContext(NEContextGroup.Situation)))"
////      Mixpanel.sharedInstance().track("LoadCharts", properties: ["ContextGroup" : contextGroup!.name, "Period" : analyticsPeriod.name])
//      
//      Alamofire.request(.GET, newContentEndpoint, encoding: .JSON)
//        .responseJSON { response in
//          if let unwrappedResult = response.data {
//            let json = JSON(data: unwrappedResult)
//            let items = json["items"]
//            for (_, subJson):(String, JSON) in items {
//              if let _item = subJson as? String {
//                self.recommendedItems.append(_item)
//              }
//            }
//            self.tableView.reloadData()
//          }
//      }
//    }
  }
}

extension RecommendationsViewController : UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.OverFullScreen
  }
  
  func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
    return true
  }
}

extension RecommendationsViewController : UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recommendedItems.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("RecommendationWebViewController") as? RecommendationWebViewController {
      vc.modalPresentationStyle = .Popover
      let popover = vc.popoverPresentationController!
      popover.delegate = self
      popover.sourceView = self.view
      vc.urlString = recommendedItems[indexPath.row]
      presentViewController(vc, animated: true, completion: nil)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RecommendationsTableViewCell") as? RecommendationsTableViewCell
    cell?.itemLabel.text = recommendedItems[indexPath.row]
    return cell!
  }
}