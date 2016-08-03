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
  var recommendedItems : [RecommendedItem] = []
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "RecommendedMusicTableViewCell", bundle: nil), forCellReuseIdentifier: "RecommendedMusicTableViewCell")
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let _profileId = Credentials.sharedInstance.profileId {
      let newContentEndpoint = "\(getContextBasedRecommendations)/\(_profileId)"
      Alamofire.request(.GET, newContentEndpoint, encoding: .JSON)
        .responseJSON { response in
          if let unwrappedResult = response.data {
            self.populateRecommendedItemsList(JSON(data: unwrappedResult))
            self.tableView.reloadData()
          }
      }
    }
  }
  
  private func _populateRecommendedItemsList(itemType : ItemType, json : JSON) -> [Int : RecommendedItem] {
    var items : [Int : RecommendedItem] = [:]
    for (_, subJson) : (String, JSON) in json {
      if let itemId = subJson["id"].int {
        let newItem = RecommendedItem(type: itemType)
        newItem.id = itemId
        if let itemTitle = subJson["title"].string {
          newItem.title = itemTitle
        }
        if let itemURL = subJson["url"].string {
          newItem.url = itemURL
        }
        if let itemImageURL = subJson["imageUrl"].string {
          newItem.thumbnailImageUrl = itemImageURL
        }
        items[itemId] = newItem
      }
    }
    return items
  }
  
  private func populateRecommendedItemsList(json : JSON) {
    let orderedList = json["order"]
    var musicItemList : [Int : RecommendedItem] = [:]
    if json[ItemType.Music.rawValue].count > 0 {
      musicItemList = _populateRecommendedItemsList(ItemType.Music, json: json[ItemType.Music.rawValue])
    }
    var videoItemList : [Int : RecommendedItem] = [:]
    if json[ItemType.Video.rawValue].count > 0 {
      videoItemList = _populateRecommendedItemsList(ItemType.Video, json: json[ItemType.Video.rawValue])
    }
    for (_, subJson) : (String, JSON) in orderedList {
      if let
        itemType = subJson["type"].string,
        itemId = subJson["id"].int {
        switch ItemType(rawValue: itemType)! {
          case .Music:
            self.recommendedItems.append(musicItemList[itemId]!)
          case .Video:
            self.recommendedItems.append(videoItemList[itemId]!)
          default:
            break
        }
      }
    }
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
      vc.urlString = recommendedItems[indexPath.row].url
      presentViewController(vc, animated: true, completion: nil)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RecommendedMusicTableViewCell") as? RecommendedMusicTableViewCell
    cell?.configure(recommendedItems[indexPath.row])
    cell?.contentView.backgroundColor = UIColor.clearColor()
    let whiteRoundedView : UIView = UIView(frame: CGRectMake(10, 8, self.view.frame.size.width - 20, 120))
    whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 0.8])
    whiteRoundedView.layer.masksToBounds = false
    whiteRoundedView.layer.cornerRadius = 2.0
    whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
    whiteRoundedView.layer.shadowOpacity = 0.2
    cell?.contentView.addSubview(whiteRoundedView)
    cell?.contentView.sendSubviewToBack(whiteRoundedView)
    return cell!
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 10.0
  }
}