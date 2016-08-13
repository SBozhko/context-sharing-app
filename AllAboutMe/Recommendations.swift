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
          self.unwatchedItems.append(musicItemList[itemId]!)
        case .Video:
          self.unwatchedItems.append(videoItemList[itemId]!)
        default:
          break
        }
      }
    }
  }
  
  private func reloadRecommendations() {
    if let _profileId = Credentials.sharedInstance.profileId {
      let newContentEndpoint = "\(getContextBasedRecommendations)/\(_profileId)"
      Alamofire.request(.GET, newContentEndpoint, encoding: .JSON)
        .responseJSON { response in
          if let unwrappedResult = response.data {
            self.clearItems()
            self.populateRecommendedItemsList(JSON(data: unwrappedResult))
          }
      }
    }
  }
  
  private func clearItems() {
    unwatchedItems.removeAll()
    watchedItems.removeAll()
  }
  
  func getItem() -> RecommendedItem? {
    if unwatchedItems.count > 0 {
      let index = Int(arc4random_uniform(UInt32(unwatchedItems.count)))
      let item = unwatchedItems[index]
      watchedItems.append(item)
      unwatchedItems.removeAtIndex(index)
      if unwatchedItems.isEmpty {
        reloadRecommendations()
      }
      return item
    } else {
      reloadRecommendations()
    }
    return nil
  }
}