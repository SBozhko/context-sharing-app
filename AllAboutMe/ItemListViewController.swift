//
//  ItemListViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/15/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class ItemListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var items : [RecommendedItem]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
    tableView.registerNib(UINib(nibName: "MusicTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicTableViewCell")
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(ItemListViewController.handleImageDownloadNotification(_:)),
                                                     name: imageDownloadNotification,
                                                     object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func handleImageDownloadNotification(notification : NSNotification) {
    if let indexPath: NSIndexPath = notification.object as? NSIndexPath {
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    else {
      tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
      case "showVideoVCSegue":
        if let
          destController = segue.destinationViewController as? MusicViewController {
          if let item = sender as? RecommendedItem {
            destController.item = item
          }
        }
      default:
        break
      }
    }
  }
  
  func showMusicViewController(item : RecommendedItem) {
    let storyboard = UIStoryboard(name: "Artboard", bundle: nil)
    let musicVC = storyboard.instantiateViewControllerWithIdentifier("MusicViewController") as! MusicViewController
    musicVC.item = item
    self.presentViewController(musicVC, animated: true, completion: nil)
  }
}

extension ItemListViewController : UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items!.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let _items = items {
      let _item = _items[indexPath.row]
      if _item.type! == .Music {
//        showMusicViewController(_item)        
        performSegueWithIdentifier("showMusicVCSegue", sender: _item)
      } else {
        performSegueWithIdentifier("showVideoVCSegue", sender: _item)
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
