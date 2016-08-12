//
//  Credentials.swift
//  Jarvis
//
//  Created by Abhishek Sen on 7/19/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import Alamofire
import AdSupport
import SwiftyJSON

let developmentDevices = ["8E3A29F4-56E3-463F-823A-2BBFC4213261", // Abhi, iPhone 5S
                          "459D4163-B958-4470-9422-EDD762B4ECC9"] // Svetlana, iPhone 6S

class Credentials {
  static let _credentialsInstance = Credentials()
  class var sharedInstance: Credentials {
    return _credentialsInstance
  }
  let log = Logger(loggerName: String(Credentials))
  var profileId : Int?
  var isDevelopmentDevice : Bool {
    get {
      let devDevice = developmentDevices.contains(ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString)
      (devDevice) ? log.debug("This is a development device.") : log.debug("This is a production device.")
      return devDevice
    }
  }
  
  static var userHasOnboarded : Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(userHasOnboardedKey)
    }
  }
  
  static var name : String? {
    get {
      return NSUserDefaults.standardUserDefaults().stringForKey(nameKey)
    }
  }
  
  init() {
    if let
      _profileId = NSUserDefaults.standardUserDefaults().objectForKey("profileId") as? Int {
      profileId = _profileId
      self.log.info("Using profile id: \(_profileId)")
    } else {
      let logTimeStampFormatter = NSDateFormatter()
      let logTimeStampDateFormatString = "ZZ"
      logTimeStampFormatter.dateFormat = logTimeStampDateFormatString
      let timestamp = String(logTimeStampFormatter.stringFromDate(NSDate()))
      let parameters : [String : AnyObject]
      if let _name = Credentials.name {
        parameters = [
          "userId": VendorInfo.getId(),
          "advertisingId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString,
          "vendorId": VendorInfo.getId(),
          "timezone": "UTC\(timestamp)",
          "name" : _name
        ]
      } else {
        parameters = [
          "userId": VendorInfo.getId(),
          "advertisingId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString,
          "vendorId": VendorInfo.getId(),
          "timezone": "UTC\(timestamp)"        ]
      }
      
      Alamofire.request(.POST, postUserInfoInitEndpoint, parameters: parameters, encoding: .JSON)
        .responseJSON { response in
          if let unwrappedResult = response.data {
            let json = JSON(data: unwrappedResult)
            if let _profileId = json["profileId"].int {
              self.log.info("Received profile id: \(_profileId)")
              self.profileId = _profileId
              NSUserDefaults.standardUserDefaults().setInteger(_profileId, forKey: "profileId")
            }
          }
      }
    }
  }
}