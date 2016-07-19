//
//  UIViewController+Ext.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/18/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

extension UIViewController {
  func isViewVisible() -> Bool {
    if isViewLoaded() {
      if self.navigationController != nil {
        return self.navigationController?.topViewController === self
      } else if self.tabBarController != nil {
        return self.tabBarController?.selectedViewController == self && self.presentedViewController == nil
      } else {
        return self.presentedViewController == nil
      }
    }
    return false
  }
}
