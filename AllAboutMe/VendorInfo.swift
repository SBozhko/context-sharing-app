//
//  VendorInfo.swift
//  Jarvis
//
//  Created by Abhishek Sen on 7/17/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import UIKit

class VendorInfo {
  private static var uniqueDeviceId = ""
  
  static func getId() -> String {
    if uniqueDeviceId == "" {
      let identifier = UIDevice.currentDevice().identifierForVendor!.description
      let identifierArray = identifier.componentsSeparatedByString(">")
      let identifierString = identifierArray[1] as String
      uniqueDeviceId = identifierString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    return uniqueDeviceId
  }
}