//
//  WebViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/13/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
  var webView: WKWebView!
  var urlString : String?
  var progressView: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let url = NSURL (string: urlString!)
    let urlRequest = NSURLRequest(URL: url!)
    self.webView.loadRequest(urlRequest)
    self.webView.allowsBackForwardNavigationGestures = true
    progressView = UIProgressView(progressViewStyle: .Default)
    progressView.sizeToFit()
    let progressButton = UIBarButtonItem(customView: progressView)
    let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(webView.reload))
    toolbarItems = [progressButton, spacer, refresh]
    navigationController?.toolbarHidden = false
    webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
  }
  
  override func loadView() {
    super.loadView()
    self.webView = WKWebView()
    self.webView?.navigationDelegate = self
    self.view = self.webView!
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "estimatedProgress" {
      progressView.progress = Float(webView.estimatedProgress)
    }
  }
  
  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.webView!.stopLoading()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  deinit {
    webView.removeObserver(self, forKeyPath: "estimatedProgress")
  }
}

extension WebViewController : WKNavigationDelegate {
  
}
