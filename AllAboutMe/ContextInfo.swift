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
  var temporarilyOverriddenContexts : [NEContextGroup : (NEContextName, String)] = [:]
  var contextTimers : [String : NSTimer] = [:]
  let overrideContextTimerValue = 60.0
  
  func getOverriddenContext(group : NEContextGroup) -> (flag : Bool, contextName : NEContextName?, userContextString : String?) {
    if let
      overridenContext = temporarilyOverriddenContexts[group],
      _ = contextTimers[group.name] {
      return (true, overridenContext.0, overridenContext.1)
    } else {
      return (false, nil, nil)
    }
  }
  
  func getValidCurrentContext(group : NEContextGroup) -> (context : NEContext?, imageName : String?) {
    let contextInfo = getCurrentContext(group)
    if contextInfo.flag && contextInfo.context!.name != NEContextName.Unknown {
      return (contextInfo.context, contextInfo.imageName)
    } else {
      return (nil, nil)
    }
  }
  
  func getCurrentContext(group : NEContextGroup) -> (flag : Bool, context : NEContext?, imageName : String?) {
    switch (group) {
    case .Activity:
      if let value = NEActivity.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .DayCategory:
      if let value = NEDayCategory.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .IndoorOutdoor:
      if let value = NEIndoorOutdoor.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .Lightness:
      if let value = NELightness.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .Mood:
      if let value = NEMood.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .Place:
      if let value = NEPlace.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .Situation:
      if let value = NESituation.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .TimeOfDay:
      if let value = NETimeOfDay.get() {
        return (true, value, value.name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    case .Weather:
      let weatherEvent = NEWeather.get()
      if weatherEvent.count >= 2 {
        /* The 0th item contains weather info */
        return (true, weatherEvent[0], weatherEvent[0].name.name.lowercaseString)
      } else {
        return (false, nil, nil)
      }
    default:
      return (false, nil, nil)
    }
  }
  
  func getContextListForContextGroup(group : NEContextGroup) -> [NEContextName] {
    switch (group) {
    case .Activity:
      return NEActivity.contexts
    case .DayCategory:
      return NEDayCategory.contexts
    case .IndoorOutdoor:
      return NEIndoorOutdoor.contexts
    case .Lightness:
      return NELightness.contexts
    case .Mood:
      return NEMood.contexts
    case .Place:
      return NEPlace.contexts
    case .Situation:
      return NESituation.contexts
    case .TimeOfDay:
      return NETimeOfDay.contexts
    case .Weather:
      return NEWeather.contexts
    default:
      return []
    }
  }
  
  func getSituationDisplayMessage(situation : NEContextName) -> String {
    switch (situation) {
    case .WakeUp:
      return "Good morning!"
    case .Working:
      return "Focus and work well"
    case .Workout:
      return "Have a super workout!"
    case .Party:
      return "Party time!"
    case .Housework:
      return "Time to clean up"
    case .Relaxing:
      return "Chill time"
    case .OnTheGo:
      return "Don't sweat the commute"
    case .Bedtime:
      return "Good night"
    default:
      return ""
    }
  }
  
  // MARK: - Timers
  
  func stopOverrideTimer(contextGroupName : String) {
    if let overriddenTimer = contextTimers[contextGroupName] {
      print("Override timer stopped for \(contextGroupName)")
      overriddenTimer.invalidate()
      contextTimers.removeValueForKey(contextGroupName)
      // Post notification to reload contexts
      NSNotificationCenter.defaultCenter().postNotificationName(contextOverrideTimerExpiredNotification, object: nil)
    }
  }
  
  func startOverrideTimer(contextGroup : NEContextGroup) {
    print("Override timer started for \(contextGroup.name)")
    stopOverrideTimer(contextGroup.name)
    contextTimers[contextGroup.name] = NSTimer.scheduledTimerWithTimeInterval(
                                    overrideContextTimerValue,
                                    target: self,
                                    selector: #selector(ContextInfo.overrideTimerExpired(_:)),
                                    userInfo: contextGroup.name,
                                    repeats: false)
  }
  
  @objc func overrideTimerExpired(timer : NSTimer) {
    if let contextGroupName = timer.userInfo as? String {
      print("Override timer expired for \(contextGroupName)")
      stopOverrideTimer(contextGroupName)
    }
  }
  
  func overrideCurrentContextSettings(contextGroup : NEContextGroup, userSelectedContextName : NEContextName, userEnteredContextString : String = "") -> Bool {
    // If we're already in the same context as what the user wants to override it to, nothing to do
    if let currentContext = ContextInfo.sharedInstance.getValidCurrentContext(contextGroup).context where currentContext.name == userSelectedContextName {
      stopOverrideTimer(contextGroup.name)
      return false
    }
    // Else we'll override the values
    if !userEnteredContextString.isEmpty {
      // Add to temporary overridden list of contexts
      temporarilyOverriddenContexts[contextGroup] = (NEContextName.Other, userEnteredContextString)
      // Start timer for this context group
      startOverrideTimer(contextGroup)
    } else {
      // Add to temporary overridden list of contexts
      temporarilyOverriddenContexts[contextGroup] = (userSelectedContextName, "")
      // Start timer for this context group
      startOverrideTimer(contextGroup)
    }
    return true
  }
}