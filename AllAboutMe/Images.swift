//
//  Images.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/13/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import NEContextSDK

class Images {
  static func getImageName(context : NEContext) -> String {
    switch (context.group) {
    case .Activity:
      switch context.name {
      case .Stationary:
        return "Activity_Stationary"
      case .Walking:
        return "Activity_Walking"
      case .Running:
        return "Activity_Running"
      case .Cycling:
        return "Activity_Cycling"
      case .Driving:
        return "Activity_Driving"
      default:
        return "Unknown"
      }
    case .IndoorOutdoor:
      switch context.name {
      case .Indoor:
        return "IndoorOutdoor_Indoor"
      case .Outdoor:
        return "IndoorOutdoor_Outdoor"
      default:
        return "Unknown"
      }
    case .TimeOfDay:
      switch context.name {
      case .Breakfast:
        return "Time_Breakfast"
      case .Lunch:
        return "Time_Lunch"
      case .Dinner:
        return "Dinner"
      default:
        return "Unknown"
      }
    default:
      break
    }
    
    return "Unknown"
  }
}