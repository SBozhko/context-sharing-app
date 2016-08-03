//
//  Item.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/2/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import UIKit

class RecommendedItem : NSObject {
  var type : ItemType?
  var url : String?
  var title : String?
  var duration : String?
  var id : Int?
  var thumbnailImageUrl : String?
  var thumbnailImage : UIImage?
  
  convenience init(type : ItemType?) {
    self.init()
    self.type = type
  }
}