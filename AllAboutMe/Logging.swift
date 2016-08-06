//
//  Logging.swift
//  Context
//
//  Created by Abhishek Sen on 7/16/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import CoreFoundation
import DeviceGuru

class Logging {
  static let _loggingInstance = Logging()
  class var sharedInstance: Logging {
    return _loggingInstance
  }
  
  let ClassName = String(Logging)
  let log = Logger(loggerName: String(Logging))
  static let DebugLevel = "DEBUG"
  static let InfoLevel = "INFO"
  static let WarnLevel = "WARN"
  static let ErrorLevel = "ERROR"
  
  let logTimeStampFormatter = NSDateFormatter()
  let logFileNameFormatter = NSDateFormatter()
  let tempLogFileNameFormatter = NSDateFormatter()
  let temporaryLogFileDirectory = "\(NSTemporaryDirectory())/"
  let logTimeStampDateFormatString = "yyyy-MM-dd HH:mm:ssZZZZ"
  let tempLogFileNameDateFormatString = "yyyy-MM-dd_HH:mm:ss"
  let logFileNameDateFormatString = "yyyy-MM-dd"
  let logFileDirectoryPrefix = "/JarvisLogs/"
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
  
  var getLogFileName : String {
    get {
      logFileNameFormatter.dateFormat = logFileNameDateFormatString
      return String(format: "Jarvis_%@.txt", logFileNameFormatter.stringFromDate(NSDate()))
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
      writeData("", loggerName: "", dataString: logFileInitialString, skipTimeStamp: true)
    } else {
      logFileInitialString = "Device ID: \(VendorInfo.getId())\nDate/Time Created: \(logTimeStampFormatter.stringFromDate(NSDate()))\n"
      logFileInitialString += "iOS \(UIDevice.currentDevice().systemVersion) / \(DeviceGuru.hardwareDescription()!)\n\n"
      do {
        try logFileInitialString.writeToFile(logFilePath, atomically: true, encoding: NSUTF8StringEncoding)
        logFileHandle = NSFileHandle(forWritingAtPath: logFilePath)
      } catch {
        
      }
    }
  }
  
  func getUserDumpLogFileName(randomMessageHash : String) -> String {
    logFileNameFormatter.dateFormat = logFileNameDateFormatString
    return String(format: "User_Dump_Jarvis_%@_%@.txt", tempLogFileNameFormatter.stringFromDate(NSDate()), randomMessageHash)
  }
  
  func getUserDumpFileFullPathName(randomMessageHash : String) -> String {
    return temporaryLogFileDirectory.stringByAppendingPathComponent(getUserDumpLogFileName(randomMessageHash))
  }
  
  func uploadLogFiles(directory: String) {
    let files = fileManager.enumeratorAtPath(directory)
    let currentLogName = getLogFileName
    while let fileName = files?.nextObject() as? String {
      if fileName.hasSuffix("txt") && fileName != currentLogName {
        AWS.sharedInstance.handleUploadRequest(
          fileName,
          uniqueDeviceIdentifier: VendorInfo.getId(),
          fullFilePath: directory.stringByAppendingPathComponent(fileName)
        )
      }
    }
  }
  
  func userInitiatedLogDump(dumpMessage : String) {
    self.log.debug("User Initiated Dump: \(dumpMessage)\n")
    do {
      let userDumpFileFullPathName = getUserDumpFileFullPathName(dumpMessage)
      try fileManager.copyItemAtPath(getLogFileFullPathName, toPath: userDumpFileFullPathName)
      AWS.sharedInstance.handleUploadRequest(getUserDumpLogFileName(dumpMessage), uniqueDeviceIdentifier: VendorInfo.getId(), fullFilePath: userDumpFileFullPathName, userInitiatedDump:  true)
    } catch {
      log.error("\(error)")
    }
  }
  
  func writeData(level: String, loggerName: String, dataString: String, skipTimeStamp : Bool = false) {
    let timestamp = String(logTimeStampFormatter.stringFromDate(NSDate()))
    let fullLogString = "[\(timestamp)][\(level)][\(loggerName)][\(dataString)]"
    let logString = skipTimeStamp ? dataString : fullLogString
    if let unwrappedFileHandle = logFileHandle {
      unwrappedFileHandle.seekToEndOfFile()
      unwrappedFileHandle.writeData("\(logString)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    } else {
      self.log.error("Could not write log line to file: \(logString)")
    }
    print(fullLogString)
  }
  
  func removeFile(fullFilePath : String) {
    do {
      try fileManager.removeItemAtPath(fullFilePath)
      writeData(Logging.InfoLevel, loggerName: ClassName, dataString: "Removed file: \(fullFilePath)")
    } catch let error as NSError {
      writeData(Logging.ErrorLevel, loggerName: ClassName, dataString: "Remove failed for \(fullFilePath): \(error.localizedDescription)")
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
      writeData(Logging.ErrorLevel, loggerName: ClassName, dataString: "Failed to create logs directory: \(error.localizedDescription)")
      return false
    }
  }
  
  deinit {
    writeData(Logging.InfoLevel, loggerName: ClassName, dataString: "Closing log file: \(getLogFileFullPathName)")
    logFileHandle?.closeFile()
  }
}