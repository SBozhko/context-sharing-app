//
//  ArtboardTabBarController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/12/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class ArtboardTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBar.barTintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
    self.tabBar.tintColor = UIColor.whiteColor()
    self.tabBar.translucent = true
    self.tabBar.opaque = false
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
