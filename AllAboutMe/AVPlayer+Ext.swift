//
//  AVPlayer+Ext.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/16/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AVPlayerExt : AVPlayer {
  var observers: NSMutableSet! = NSMutableSet()
  var isPlaying : Bool = false
  var interrupted = false
  
  override func addObserver(observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutablePointer<Void>) {
    let observerId : String = "\(observer.hashValue)\(keyPath)"
    observers.addObject(observerId)
    super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
  }
  
  override func removeObserver(observer: NSObject, forKeyPath keyPath: String) {
    let observerId : String = "\(observer.hashValue)\(keyPath)"
    if (observers.containsObject(observerId)) {
      observers.removeObject(observerId)
      super.removeObserver(observer, forKeyPath: keyPath)
    }
  }
}