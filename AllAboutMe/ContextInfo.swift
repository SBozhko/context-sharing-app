//
//  ContextInfo.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import NEContextSDK

class ContextInfo {
  static let _sharedContextInfoInstance = ContextInfo()
  class var sharedInstance : ContextInfo {
    return _sharedContextInfoInstance
  }
  
  func getCurrentContext(group : NEContextGroup) -> (Bool, NEContext?) {
    switch (group) {
    case .Activity:
      if let value = NEActivity.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .DayCategory:
      if let value = NEDayCategory.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .IndoorOutdoor:
      if let value = NEIndoorOutdoor.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .Lightness:
      if let value = NELightness.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .Mood:
      if let value = NEMood.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .Place:
      if let value = NEPlace.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .Situation:
      if let value = NESituation.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .TimeOfDay:
      if let value = NETimeOfDay.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    case .Weather:
      if let value = NEWeather.get() {
        return (true, value)
      } else {
        return (false, nil)
      }
    default:
      return (false, nil)
    }
  }
}