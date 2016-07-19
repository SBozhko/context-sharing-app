//
//  Credentials.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/19/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import Alamofire
import AdSupport
import SwiftyJSON

class Credentials {
  static let _credentialsInstance = Credentials()
  class var sharedInstance: Credentials {
    return _credentialsInstance
  }
  let log = Logger(loggerName: String(Credentials))
  var profileId : Int?
  
  init() {
    if let _profileId = NSUserDefaults.standardUserDefaults().objectForKey("profileId") as? Int {
      profileId = _profileId
      self.log.info("Using profile id: \(_profileId)")
    } else {
      let logTimeStampFormatter = NSDateFormatter()
      let logTimeStampDateFormatString = "ZZ"
      logTimeStampFormatter.dateFormat = logTimeStampDateFormatString
      let timestamp = String(logTimeStampFormatter.stringFromDate(NSDate()))
      let parameters : [String : AnyObject] = [
        "userId": VendorInfo.getId(),
        "advertisingId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString,
        "vendorId": VendorInfo.getId(),
        "timezone": "UTC\(timestamp)"
      ]
      
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