//
//  Logger.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/16/16.
//  Copyright © 2016 NE. All rights reserved.

import Foundation

class Logger {
  private let loggerName: String
  
  init(loggerName: String) {
    self.loggerName = loggerName
  }
  
  func debug(message: String) {
    Logging.sharedInstance.writeData(Logging.DebugLevel, loggerName: loggerName, dataString: message)
  }
  
  func info(message: String) {
    Logging.sharedInstance.writeData(Logging.InfoLevel, loggerName: loggerName, dataString: message)
  }
  
  func warn(message: String) {
    Logging.sharedInstance.writeData(Logging.WarnLevel,loggerName: loggerName, dataString: message)
  }
  
  func error(message: String) {
    Logging.sharedInstance.writeData(Logging.ErrorLevel, loggerName: loggerName,dataString: message)
  }
  
}
