//
//  WalkthroughViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/11/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class WalkthroughViewController : UIViewController {
  
  // These IBOutlets are already connect for you. We'll configure these outlets later
  @IBOutlet weak var headerLabel: UILabel!
//  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var startButtonView: UIView!
  
  
  // MARK: - Data model for each walkthrough screen
  var index = 0               // the current page index
  var headerText = ""
  var imageName = ""
  var descriptionText = ""
  
  // Just to make sure that the status bar is white - it depends on your preference
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  // 1 - Let's configure a walkthrough screen with the data model
  override func viewDidLoad() {
    super.viewDidLoad()
    
    headerLabel.text = headerText
//    descriptionLabel.text = descriptionText
    imageView.image = UIImage(named: imageName)
    pageControl.currentPage = index
    
    // customize the next and start button
    startButtonView.hidden = (index == 3) ? false : true
  }
  
  // 2 - If the user click the start button, we will just dismiss the page VC as we are displaying this PageVC via a modal segue
  @IBAction func startClicked(sender : AnyObject) {
    performSegueWithIdentifier("getNameSegue", sender: self)
  }
  
//  // If the user clicks the next button, we'll show the next page view controller
//  @IBAction func nextClicked(sender : AnyObject) {
//    let pageViewController = self.parentViewController as! OnboardPageViewController
//    pageViewController.nextPageWithIndex(index)
//  }
}

