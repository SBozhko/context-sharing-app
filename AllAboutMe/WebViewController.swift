//
//  WebViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/13/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import WebKit
import Social

class WebViewController: UIViewController {
  var webView: WKWebView!
  var item : RecommendedItem!
  var progressView: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let url = NSURL (string: item.url!)
    let urlRequest = NSURLRequest(URL: url!)
    self.webView.loadRequest(urlRequest)
    self.webView.allowsBackForwardNavigationGestures = true
    self.webView.navigationDelegate = self
    progressView = UIProgressView(progressViewStyle: .Default)
    progressView.sizeToFit()
    progressView.tintColor = UIColor.darkGrayColor()
    let progressButton = UIBarButtonItem(customView: progressView)
    let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(webView.reload))
    toolbarItems = [progressButton, spacer, refresh]
    navigationController?.toolbarHidden = false
    self.title = item.title
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
  
  func socialMediaSharing(serviceType : String) {
    if SLComposeViewController.isAvailableForServiceType(serviceType) {
      let composeController = SLComposeViewController(forServiceType: serviceType)
      if !composeController.setInitialText("Shared from Jarvis. What do you think?") {
        print("did not set initial text")
      }
      if let image = item!.thumbnailImage {
        composeController.addImage(image)
      }
      if let
        url = item!.url,
        permaUrl = NSURL(string: url) {
        composeController.addURL(permaUrl)
      }
      
      composeController.completionHandler = {result -> Void in
        if (result as SLComposeViewControllerResult) == SLComposeViewControllerResult.Done {
          
        }
      }
      self.presentViewController(composeController, animated: true, completion: nil)
    }
  }
  
  func shareOnWhatsApp() {
    let urlString = "Shared from Jarvis - Check it out. \(item!.streamUrl)"
    let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    let url = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
    if UIApplication.sharedApplication().canOpenURL(url!) {
      UIApplication.sharedApplication().openURL(url!)
    }
  }
  
  @IBAction func handleShareWebContent(sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let twitterAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.socialMediaSharing(SLServiceTypeTwitter)
    })
    let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.socialMediaSharing(SLServiceTypeFacebook)
    })
    let whatsappAction = UIAlertAction(title: "WhatsApp", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      self.shareOnWhatsApp()
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
      (alert: UIAlertAction!) -> Void in
      print("Cancelled")
    })
    optionMenu.addAction(twitterAction)
    optionMenu.addAction(facebookAction)
    optionMenu.addAction(whatsappAction)
    optionMenu.addAction(cancelAction)
    
    optionMenu.view.tintColor = UIColor.darkGrayColor()
    presentViewController(optionMenu, animated: true, completion: nil)
  }
  
  deinit {
    webView.removeObserver(self, forKeyPath: "estimatedProgress")
  }
}

extension WebViewController : WKNavigationDelegate {
  func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
  }
  
  
  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }  
}
