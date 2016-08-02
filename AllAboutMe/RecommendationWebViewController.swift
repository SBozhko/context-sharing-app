//
//  RecommendationWebViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/1/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class RecommendationWebViewController: UIViewController {
  @IBOutlet weak var webView: UIWebView!
  
  var urlString : String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let url = NSURL (string: urlString!)
    let urlRequest = NSURLRequest(URL: url!);
    webView.loadRequest(urlRequest);
  }
  
  @IBAction func stopPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func refreshPressed(sender: AnyObject) {
    webView.reload()
  }
  
  @IBAction func backPressed(sender: AnyObject) {
    webView.goBack()
  }
  
  @IBAction func forwardPressed(sender: AnyObject) {
    webView.goForward()
  }  
}
