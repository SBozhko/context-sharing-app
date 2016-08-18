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
  static func getImageName(contextName : NEContextName, contextGroup : NEContextGroup, mainContext : Bool = false, shadow : Bool = true) -> String {
    var imageName = "Unknown"
    switch (contextGroup) {
    case .Activity:
      switch contextName {
      case .Stationary:
        imageName =  "Activity_Stationary"
      case .Walking:
        imageName =  "Activity_Walking"
      case .Running:
        imageName =  "Activity_Running"
      case .Cycling:
        imageName =  "Activity_Cycling"
      case .Driving:
        imageName =  "Activity_Driving"
      default:
        imageName =  "Activity_Stationary"
      }
    case .IndoorOutdoor:
      switch contextName {
      case .Indoor:
        imageName =  "IndoorOutdoor_Indoor"
      case .Outdoor:
        imageName =  "IndoorOutdoor_Outdoor"
      default:
        imageName =  "IndoorOutdoor_Indoor"
      }
    case .TimeOfDay:
      switch contextName {
      case .Breakfast:
        imageName =  "Time_Breakfast"
      case .Lunch:
        imageName =  "Time_Lunch"
      case .Dinner:
        imageName =  "Time_Dinner"
      case .BeforeLunch:
        imageName =  "Time_BeforeLunch"
      case .Evening:
        imageName =  "Time_Evening"
      case .EarlyHours:
        imageName =  "Time_EarlyHours"
      case .Night:
        imageName =  "Time_Night"
      case .Afternoon:
        imageName =  "Time_Afternoon"
      case .Morning:
        imageName =  "Time_Morning"
      default:
        imageName =  "Unknown"
      }
    case .Place:
      switch contextName {
      case .Home:
        imageName =  "Place_Home"
      case .Office:
        imageName =  "Place_Office"
      case .Library:
        imageName =  "Place_Library"
      case .Gym:
        imageName =  "Place_Gym"
      case .Restaurant:
        imageName =  "Place_Restaurant"
      case .Shop:
        imageName =  "Place_Shop"
      case .Beach:
        imageName =  "Place_Beach"
      default:
        imageName =  "Unknown"
      }
    case .Mood:
      switch contextName {
      case .Happy:
        imageName =  "Mood_Happy"
      case .Angry:
        imageName =  "Mood_Angry"
      case .Sad:
        imageName =  "Mood_Sad"
      case .Calm:
        imageName =  "Mood_Calm"
      default:
        imageName =  "Mood_Happy"
      }
    case .Situation:
      switch contextName {
      case .WakeUp:
        imageName =  "Situation_WakeUp"
      case .OnTheGo:
        imageName =  "Situation_OnTheGo"
      case .Working:
        imageName =  "Situation_Working"
      case .Workout:
        imageName =  "Situation_Workout"
      case .Relaxing:
        imageName =  "Situation_Relaxing"
      case .Housework:
        imageName =  "Situation_Housework"
      case .Party:
        imageName =  "Situation_Party"
      case .Bedtime:
        imageName =  "Situation_Bedtime"
      default:
        imageName =  "Unknown"
      }
    case .Weather:
      switch contextName {
      case .Sunny:
        imageName =  "Weather_Sunny"
      case .Cloudy:
        imageName =  "Weather_Cloudy"
      case .Windy:
        imageName =  "Weather_Windy"
      case .Snow:
        imageName =  "Weather_Snowy"
      case .Rain:
        imageName =  "Weather_Rainy"
      case .Drizzle:
        imageName =  "Weather_Drizzle"
      case .Thunderstorm:
        imageName =  "Weather_Thunder"
      default:
        imageName =  "Unknown"
      }
    default:
      break
    }
    imageName = mainContext ? "\(imageName)_75" : (shadow ? "\(imageName)_60" : "\(imageName)_60_no_shadow")
    return imageName
  }
}