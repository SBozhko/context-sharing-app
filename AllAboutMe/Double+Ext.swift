//
//  Double+Ext.swift
//  Jarvis
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation

extension Double {
  func roundTo(decimalPlaces: Int) -> String {
    return NSString(format: "%.\(decimalPlaces)f", self) as String
  }
}