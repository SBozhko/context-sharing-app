//
//  Common.swift
//  Jarvis
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import UIKit

/* Colors */
let globalTint = UIColor(red:0.96, green:0.65, blue:0.14, alpha:1.0)

/* Settings Keys */
let userHasOnboardedKey = "userHasOnboardedKey"
let nameKey = "nameKey"

/* Notifications */
let contextOverrideTimerExpiredNotification = "overrideTimerExpired"
let profileIdReceivedNotification = "profileIdReceivedNotification"
let onboardingCompleteNotification = "onboardingCompleteNotification"
let itemsAvailableNotification = "itemsAvailableNotification"
let imageDownloadNotification = "imageDownloadNotification"
let contextUpdateNotification = "contextUpdateNotification"

/* Server Endpoints */
let postUserInfoInitEndpoint = "http://ec2-54-152-1-96.compute-1.amazonaws.com:9000/v1/users"
let postContextEndpoint = "http://ec2-54-152-1-96.compute-1.amazonaws.com:9000/v1/contexts"
let getContextHistoryEndpoint = "http://ec2-54-152-1-96.compute-1.amazonaws.com:9000/v1/contexts"
let getContextBasedRecommendations = "http://ec2-54-152-1-96.compute-1.amazonaws.com:9000/v1/recommendations"

let uniqueStringCollection : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

enum AnalyticsPeriod : Int {
  case Day = 0, Week, Month
  var name : String {
    switch self {
    case .Day:
      return "day"
    case .Week:
      return "week"
    default:
      return "month"
    }
  }
  static let allValues = [Day, Week, Month]
}

enum ItemType : String {
  case Music = "musicItems", Video = "videoItems", News = "newsItems"
}

enum ContextType : Int {
  case Place = 0, Mood, Time, SurpriseMe, Weather, IndoorOutdoor, Activity, Situation
  static let allValues = [Place, Mood, Time, SurpriseMe, Weather, IndoorOutdoor, Activity, Situation]
}

func randomStringWithLength (len : Int) -> NSString {
  let randomString : NSMutableString = NSMutableString(capacity: len)
  for _ in 0 ..< len {
    let length = UInt32 (uniqueStringCollection.length)
    let rand = arc4random_uniform(length)
    randomString.appendFormat("%C", uniqueStringCollection.characterAtIndex(Int(rand)))
  }
  return randomString
}

func getAppVersionString() -> String {
  var appVersion = "v"
  if let shortVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
    appVersion += shortVersion
  }
  if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
    appVersion += ".\(version)"
  }
  return appVersion
}

func getDurationString(durationInSeconds: Int) -> String {
  var seconds = durationInSeconds
  let hours = Int(floor(Double(seconds/3600)))
  seconds -= (hours * 3600)
  let minutes = Int(floor(Double(seconds/60)))
  seconds -= (minutes * 60)
  
  var durationString = ""
  var hoursString = ""
  var minutesString = ""
  var secondsString = ""
  
  if hours > 0 {
    hoursString = String(hours)
    minutesString = minutes > 9 ? String(minutes) : "0" + String(minutes)
    secondsString = seconds > 9 ? String(seconds) : "0" + String(seconds)
    durationString = "\(hoursString):\(minutesString):\(secondsString)"
  } else {
    minutesString = minutes > 0 ? String(minutes) : "0"
    secondsString = seconds > 9 ? String(seconds) : "0" + String(seconds)
    durationString = "\(minutesString):\(secondsString)"
  }
  
  return durationString
}