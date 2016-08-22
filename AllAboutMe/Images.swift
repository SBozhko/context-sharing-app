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
  static func getImageName(contextName : String, contextGroup : String, mainContext : Bool = false, shadow : Bool = true) -> String {
    var imageName = "Unknown"
    switch (contextGroup) {
    case NEContextGroup.Activity.name:
      switch contextName {
      case NEContextName.Stationary.name:
        imageName =  "Activity_Stationary"
      case NEContextName.Walking.name:
        imageName =  "Activity_Walking"
      case NEContextName.Running.name:
        imageName =  "Activity_Running"
      case NEContextName.Cycling.name:
        imageName =  "Activity_Cycling"
      case NEContextName.Driving.name:
        imageName =  "Activity_Driving"
      default:
        imageName =  "Activity_Stationary"
      }
    case NEContextGroup.IndoorOutdoor.name:
      switch contextName {
      case NEContextName.Indoor.name:
        imageName =  "IndoorOutdoor_Indoor"
      case NEContextName.Outdoor.name:
        imageName =  "IndoorOutdoor_Outdoor"
      default:
        imageName =  "IndoorOutdoor_Indoor"
      }
    case NEContextGroup.TimeOfDay.name:
      switch contextName {
      case NEContextName.Breakfast.name:
        imageName =  "Time_Breakfast"
      case NEContextName.Lunch.name:
        imageName =  "Time_Lunch"
      case NEContextName.Dinner.name:
        imageName =  "Time_Dinner"
      case NEContextName.BeforeLunch.name:
        imageName =  "Time_Lunch"
      case NEContextName.Evening.name:
        imageName =  "Time_Evening"
      case NEContextName.EarlyHours.name:
        imageName =  "Time_EarlyHours"
      case NEContextName.Night.name:
        imageName =  "Time_Night"
      case NEContextName.Afternoon.name:
        imageName =  "Time_Afternoon"
      case NEContextName.Morning.name:
        imageName =  "Time_Morning"
      default:
        imageName =  "Time_Evening"
      }
    case NEContextGroup.Place.name:
      switch contextName {
      case NEContextName.Home.name:
        imageName =  "Place_Home"
      case NEContextName.Office.name:
        imageName =  "Place_Office"
      case NEContextName.Library.name:
        imageName =  "Place_Library"
      case NEContextName.Gym.name:
        imageName =  "Place_Gym"
      case NEContextName.Restaurant.name:
        imageName =  "Place_Restaurant"
      case NEContextName.Shop.name:
        imageName =  "Place_Shop"
      case NEContextName.Beach.name:
        imageName =  "Place_Beach"
      default:
        imageName =  "Place_Home"
      }
    case NEContextGroup.Mood.name:
      switch contextName {
      case NEContextName.Happy.name:
        imageName =  "Mood_Happy"
      case NEContextName.Angry.name:
        imageName =  "Mood_Angry"
      case NEContextName.Sad.name:
        imageName =  "Mood_Sad"
      case NEContextName.Calm.name:
        imageName =  "Mood_Calm"
      default:
        imageName =  "Mood_Happy"
      }
    case NEContextGroup.Situation.name:
      switch contextName {
      case NEContextName.WakeUp.name:
        imageName =  "Situation_Wakeup"
      case NEContextName.OnTheGo.name:
        imageName =  "Situation_Commuting"
      case NEContextName.Working.name:
        imageName =  "Situation_Working"
      case NEContextName.Workout.name:
        imageName =  "Situation_Workout"
      case NEContextName.Relaxing.name:
        imageName =  "Situation_Relaxing"
      case NEContextName.Housework.name:
        imageName =  "Situation_Housework"
      case NEContextName.Party.name:
        imageName =  "Situation_Party"
      case NEContextName.Bedtime.name:
        imageName =  "Situation_Bedtime"
      default:
        imageName =  "Situation_Background"
      }
    case NEContextGroup.Weather.name:
      switch contextName {
      case NEContextName.Sunny.name:
        imageName =  "Weather_Sunny"
      case NEContextName.Cloudy.name:
        imageName =  "Weather_Cloudy"
      case NEContextName.Windy.name:
        imageName =  "Weather_Windy"
      case NEContextName.Snow.name:
        imageName =  "Weather_Snowy"
      case NEContextName.Rain.name:
        imageName =  "Weather_Rainy"
      case NEContextName.Drizzle.name:
        imageName =  "Weather_Drizzle"
      case NEContextName.Thunderstorm.name:
        imageName =  "Weather_Thunder"
      default:
        imageName =  "Unknown"
      }
    default:
      break
    }
    if contextGroup != NEContextGroup.Situation.name {
      imageName = mainContext ? "\(imageName)_75" : (shadow ? "\(imageName)_60" : "\(imageName)_60_no_shadow")
    }
    return imageName
  }
}