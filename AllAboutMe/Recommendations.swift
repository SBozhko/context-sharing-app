//
//  Recommendations.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/13/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Recommendations {
  static let _recsInstance = Recommendations()
  class var sharedInstance: Recommendations {
    return _recsInstance
  }
  let log = Logger(loggerName: String(Recommendations))
  var items : [RecommendedItem] = []
  var currentItemIndex = 0
  let minNumberOfItems = 1
  
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
        if let itemEmbedURL = subJson["embedUrl"].string {
          newItem.embedUrl = itemEmbedURL
        }
        if let itemStreamURL = subJson["streamUrl"].string {
          newItem.streamUrl = itemStreamURL
        }
        if let itemImageURL = subJson["artwork"].string {
          newItem.thumbnailImageUrl = itemImageURL
        }
        if let itemDuration = subJson["duration"].int {
          newItem.duration = itemDuration/1000
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
          self.items.append(musicItemList[itemId]!)
        case .Video:
          self.items.append(videoItemList[itemId]!)
        default:
          break
        }
      }
    }
  }
  
  func reloadRecommendations() {
    if let localProfileId = Credentials.sharedInstance.profileId {
      let newContentEndpoint = "\(getContextBasedRecommendations)/\(localProfileId)"
      Alamofire.request(.GET, newContentEndpoint, encoding: .JSON)
        .responseJSON { response in
          if response.result.isSuccess {
            if let unwrappedResult = response.data {
              self.clearItems()
              self.populateRecommendedItemsList(JSON(data: unwrappedResult))
              NSNotificationCenter.defaultCenter().postNotificationName("itemsAvailableNotification", object: nil)
            }
          }
      }
    }
  }
  
  private func clearItems() {
    currentItemIndex = 0
    items.removeAll()
  }
  
  func getItems(numberOfItems : Int) -> [RecommendedItem]? {
    if items.indices.contains(currentItemIndex) && items.indices.contains(currentItemIndex+1) {
      var newItems : [RecommendedItem] = []
      newItems.append(items[currentItemIndex])
      newItems.append(items[currentItemIndex+1])
      currentItemIndex += 2
      return newItems
    } else {
      reloadRecommendations()
    }
    return nil
  }
}