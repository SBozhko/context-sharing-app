//
//  AWS.swift
//  Context
//
//  Created by Abhishek Sen on 6/29/16.
//  Copyright © 2016 NE. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSS3

class AWS : NSObject {
  static let _awsInstance = AWS()
  class var sharedInstance: AWS {
    return _awsInstance
  }
  let cognitoPoolId = "us-east-1:17f95bbd-0f9c-44fc-875e-0b8d498ee93f"
  let bucketName = "numbereight.sdk"
  let userLogsBucketFolderName = "context_sharing_logs/%@/%@"
  
  override init() {
    let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: cognitoPoolId)
    let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
    AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
  }
  
  func handleUploadRequest(keyFileName : String, uniqueDeviceIdentifier : String, fullFilePath : String, userInitiatedDump : Bool = false) {
    let uploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.bucket = bucketName
    uploadRequest.key = String(format: userLogsBucketFolderName, uniqueDeviceIdentifier, keyFileName)
    uploadRequest.body = NSURL(fileURLWithPath: fullFilePath)
    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
    transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
      if task.error != nil {
        Logging.sharedInstance.writeData("Log[\(keyFileName)] upload error: \(task.error)")
      } else {
        Logging.sharedInstance.writeData("Log[\(keyFileName)] upload successful.")
        /* Now we can delete this file from the file system */
        Logging.sharedInstance.removeFile(fullFilePath)
      }
      return nil
    })
  }
}