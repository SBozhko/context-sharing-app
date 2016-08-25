//
//  ItemListViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/15/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import Mixpanel

class ItemListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var items : [RecommendedItem]?
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(ItemListViewController.handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
    
    return refreshControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
    tableView.registerNib(UINib(nibName: "MusicTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicTableViewCell")
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = UIColor.clearColor()
    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(ItemListViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    self.tableView.addSubview(refreshControl)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(ItemListViewController.handleImageDownloadNotification(_:)),
                                                     name: imageDownloadNotification,
                                                     object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.Default
  }

  func handleImageDownloadNotification(notification : NSNotification) {
    if let indexPath: NSIndexPath = notification.object as? NSIndexPath {
      dispatch_async(dispatch_get_main_queue(), {
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      })
    }
    else {
      dispatch_async(dispatch_get_main_queue(), {
        self.tableView.reloadData()
      })
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func handleRefresh(refreshControl: UIRefreshControl) {
    if let _items = Recommendations.sharedInstance.getItems(2) {
      self.refreshControl.endRefreshing()
      items?.removeAll(keepCapacity: true)
      _items.forEach({ (item) in
        items?.append(item)
      })
      Mixpanel.sharedInstance().track("RefreshedItems")
      dispatch_async(dispatch_get_main_queue(), {
        self.tableView.reloadData()
      })
      
    }
  }

  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case "showMusicVCSegue":
        if let
          destController = segue.destinationViewController as? MusicViewController {
          if let item = sender as? RecommendedItem {
            destController.item = item
          }
        }
        break
      case "showWebViewVCSegue":
        if let
          navController = segue.destinationViewController as? UINavigationController,
          destController = navController.topViewController as? WebViewController {
            if let item = sender as? RecommendedItem {
              destController.item = item
            }
        }
      default:
        break
      }
    }
  }
}

extension ItemListViewController : UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items!.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let _items = items {
      let _item = _items[indexPath.row]
      Mixpanel.sharedInstance().track("SelectedContentType", properties: [
        "Type" : _item.type!.rawValue])
      if _item.type! == .Music {
        performSegueWithIdentifier("showMusicVCSegue", sender: _item)
      } else {
        performSegueWithIdentifier("showWebViewVCSegue", sender: _item)
      }
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let unwrappedItems = items {
      let localItem = unwrappedItems[indexPath.row]
      if localItem.type! == .Music {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicTableViewCell", forIndexPath: indexPath) as! MusicTableViewCell
        cell.configure(localItem, indexPath: indexPath)
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
        cell.configure(localItem, indexPath: indexPath)
        return cell
      }
    }
    
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
}
