//
//  UIImageView+Ext.swift
//  Jarvis
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

extension UIImageView {
  func loadImageWithURL(url: NSURL, bounds: CGSize, item : RecommendedItem?) -> NSURLSessionDownloadTask {
    let session = NSURLSession.sharedSession()
    
    let downloadTask = session.downloadTaskWithURL(url, completionHandler: {
      [weak self] url, response, error in      
      if error == nil && url != nil {
        if let data = NSData(contentsOfURL: url!) {
          if let image = UIImage(data: data) {
            dispatch_async(dispatch_get_main_queue()) {
              if let strongSelf = self {
                strongSelf.image = image
                if let _item = item {
                  _item.thumbnailImage = strongSelf.image
                }
              }
            }
          }
        }
      }
      })
    
    downloadTask.resume()
    return downloadTask
  }
}
