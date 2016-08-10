//
//  Common.swift
//  Jarvis
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation

/* Settings Keys */
let userHasOnboardedKey = "userHasOnboardedKey"
let nameKey = "nameKey"

/* Notifications */
let contextOverrideTimerExpiredNotification = "overrideTimerExpired"
let profileIdReceivedNotification = "profileIdReceivedNotification"
let onboardingCompleteNotification = "onboardingCompleteNotification"

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