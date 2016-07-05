//
//  OtherContextPopoverViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/5/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK

class OtherContextPopoverViewController: UIViewController {
  var context : NEContext?
  
  @IBOutlet weak var contextLabel: UILabel!
  @IBOutlet weak var confidenceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    if let _context = context {
      print("Other context Confidence: \(_context.confidence)")
      dispatch_async(dispatch_get_main_queue(), {
        self.contextLabel.text = "\(_context.name.name)"
        self.confidenceLabel.text = "\((_context.confidence*100.0).roundTo(2))%"
      })
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func closePopover(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension OtherContextPopoverViewController : UIPopoverPresentationControllerDelegate {
}
