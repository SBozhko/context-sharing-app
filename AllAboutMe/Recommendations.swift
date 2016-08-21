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
  var unwatchedItems : [RecommendedItem] = []
  var watchedItems : [RecommendedItem] = []
  let minNumberOfItems = 2
  
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
          self.unwatchedItems.append(musicItemList[itemId]!)
        case .Video:
          self.unwatchedItems.append(videoItemList[itemId]!)
        default:
          break
        }
      }
    }
  }
  
  func reloadRecommendations() {
    if let _profileId = Credentials.sharedInstance.profileId {
      let newContentEndpoint = "\(getContextBasedRecommendations)/\(_profileId)"
      Alamofire.request(.GET, newContentEndpoint, encoding: .JSON)
        .responseJSON { response in
          if let unwrappedResult = response.data {
            self.clearItems()
            self.populateRecommendedItemsList(JSON(data: unwrappedResult))
            NSNotificationCenter.defaultCenter().postNotificationName("itemsAvailableNotification", object: nil)
          }
      }
    }
  }
  
  private func clearItems() {
    unwatchedItems.removeAll()
    watchedItems.removeAll()
  }
  
  func getItems(numberOfItems : Int) -> [RecommendedItem]? {
    if unwatchedItems.count >= minNumberOfItems {
      var items : [RecommendedItem] = []
      for index in 0..<minNumberOfItems {
        let item = unwatchedItems[index]
        watchedItems.append(item)
        items.append(item)
        unwatchedItems.removeAtIndex(index)
      }
      
      if unwatchedItems.count <= minNumberOfItems {
        reloadRecommendations()
      }
      return items
    } else {
      reloadRecommendations()
    }
    return nil
  }
}