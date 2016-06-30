//
//  Logging.swift
//  Context
//
//  Created by Abhishek Sen on 6/29/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import DeviceGuru

class Logging {
  static let _loggingInstance = Logging()
  class var sharedInstance: Logging {
    return _loggingInstance
  }
  var uniqueDeviceId = ""
  
  let logTimeStampFormatter = NSDateFormatter()
  let logFileNameFormatter = NSDateFormatter()
  let tempLogFileNameFormatter = NSDateFormatter()
  let logTimeStampDateFormatString = "yyyy-MM-dd HH:mm:ssZZZZ"
  let tempLogFileNameDateFormatString = "yyyy-MM-dd_HH:mm:ss"
  let logFileNameDateFormatString = "yyyy-MM-dd"
  let logFileDirectoryPrefix = "/UserLogs/"
  let applicationSupportDirectories: [String]? = NSSearchPathForDirectoriesInDomains(
    NSSearchPathDirectory.LibraryDirectory,
    NSSearchPathDomainMask.UserDomainMask,
    true)
  let fileManager = NSFileManager.defaultManager()
  var logFileHandle: NSFileHandle?
  var logFileDirectoryName = ""
  var logFileFullPath = ""
  var getLogFileDirectory : String {
    get {
      if logFileDirectoryName == "" {
        logFileDirectoryName = applicationSupportDirectories![0].stringByAppendingPathComponent(logFileDirectoryPrefix)
      }
      return logFileDirectoryName
    }
  }
  var getVendorIdentifer : String {
    get {
      if uniqueDeviceId == "" {
        let identifier = UIDevice.currentDevice().identifierForVendor!.description
        let identifierArray = identifier.componentsSeparatedByString(">")
        let identifierString = identifierArray[1] as String
        uniqueDeviceId = identifierString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
      }
      return uniqueDeviceId
    }
  }
  var getLogFileName : String {
    get {
      logFileNameFormatter.dateFormat = logFileNameDateFormatString
      return String(format: "NEContextSDK_%@.txt", logFileNameFormatter.stringFromDate(NSDate()))
    }
  }
  var getLogFileFullPathName : String {
    get {
      if logFileFullPath == "" {
        logFileFullPath = getLogFileDirectory.stringByAppendingPathComponent(getLogFileName)
      }
      return logFileFullPath
      
    }
  }
  var getLogTimeStamp : String {
    get {
      return String(format: "%@|", logTimeStampFormatter.stringFromDate(NSDate()))
    }
  }
  
  init() {
    logTimeStampFormatter.dateFormat = logTimeStampDateFormatString
    logFileNameFormatter.dateFormat = logFileNameDateFormatString
    tempLogFileNameFormatter.dateFormat = tempLogFileNameDateFormatString
    /* Check if log file directory creation failed */
    if !createLogsDirectory() {
      /* If so, reset the logFileDirectoryName to the default Library folder */
      logFileDirectoryName = applicationSupportDirectories![0]
    }
    
    let logFilePath = getLogFileFullPathName
    
    /* Upload older log files (if any) */
    uploadLogFiles(getLogFileDirectory)
    
    var logFileInitialString : String = ""
    if fileManager.fileExistsAtPath(logFilePath) {
      logFileInitialString = "\n\n"
      logFileHandle = NSFileHandle(forWritingAtPath: logFilePath)
      writeData(logFileInitialString, skipTimeStamp: true)
    } else {
      logFileInitialString = "Device ID: \(getVendorIdentifer)\nDate/Time Created: \(logTimeStampFormatter.stringFromDate(NSDate()))\n"
      logFileInitialString += "iOS \(UIDevice.currentDevice().systemVersion) / \(DeviceGuru.hardwareDescription()!)\n\n"
      do {
        try logFileInitialString.writeToFile(logFilePath, atomically: true, encoding: NSUTF8StringEncoding)
        logFileHandle = NSFileHandle(forWritingAtPath: logFilePath)
      } catch {
        
      }
    }
  }
  
  func uploadLogFiles(directory : String) {
    let files = fileManager.enumeratorAtPath(directory)
    while let fileName = files?.nextObject() as? String{
      if fileName.hasSuffix("txt") && fileName != getLogFileName {
        AWS.sharedInstance.handleUploadRequest(fileName, uniqueDeviceIdentifier: getVendorIdentifer, fullFilePath: directory.stringByAppendingPathComponent(fileName))
      }
    }
  }
  
  func writeData(dataString: String, skipTimeStamp : Bool = false) {
    let logString = skipTimeStamp ? dataString : String(format: "%@%@\n", getLogTimeStamp, dataString)
    if let unwrappedFileHandle = logFileHandle {
      unwrappedFileHandle.seekToEndOfFile()
      unwrappedFileHandle.writeData(logString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    } else {
      print("balls")
    }
    print("\(getLogTimeStamp)\(dataString)")
  }
  
  func removeFile(fullFilePath : String) {
    do {
      try fileManager.removeItemAtPath(fullFilePath)
      writeData("Removed file: \(fullFilePath)")
    } catch let error as NSError {
      writeData("Remove failed for \(fullFilePath): \(error.localizedDescription)")
    }
  }
  
  func createLogsDirectory() -> Bool {
    /* Check if the logs directory exists first */
    var isDir : ObjCBool = false
    if fileManager.fileExistsAtPath(getLogFileDirectory, isDirectory:&isDir) {
      if isDir {
        // File exists and is a directory
        return true
      }
    }
    do {
      try fileManager.createDirectoryAtPath(getLogFileDirectory, withIntermediateDirectories: true, attributes: nil)
      return true
    } catch let error as NSError {
      writeData("Failed to create logs directory: \(error.localizedDescription)")
      return false
    }
  }
  
  deinit {
    writeData("Closing log file: \(getLogFileFullPathName)")
    logFileHandle?.closeFile()
  }
}