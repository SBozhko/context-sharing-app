//
//  Array+Ext.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/18/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
  mutating func removeObject(object: Element) {
    if let index = self.indexOf(object) {
      self.removeAtIndex(index)
    }
  }
  
  mutating func removeObjectsInArray(array: [Element]) {
    for object in array {
      self.removeObject(object)
    }
  }
}