//
//  ContextFeedbackViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class ContextFeedbackViewController: UIViewController {

  @IBOutlet weak var contextOptionsCollectionView: UICollectionView!
  
  @IBAction func updateButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
