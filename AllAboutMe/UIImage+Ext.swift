//
//  UIImage+Ext.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

extension UIImage {
  func resizedImageWithBounds(bounds: CGSize) -> UIImage {
    let horizontalRatio = bounds.width / size.width
    let verticalRatio = bounds.height / size.height
    let ratio = min(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
  
  func scaledImageWithWidth(width : CGFloat) -> UIImage {
    let oldWidth = size.width;
    let scaleFactor = width / oldWidth;
    let newHeight = size.height * scaleFactor;
    let newWidth = oldWidth * scaleFactor;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}