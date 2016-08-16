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
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    

  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case "showMusicVCSegue":
        if let
          destController = segue.destinationViewController as? MusicViewController {
          if let _object = sender as? RecommendedItem {
            destController.item = _object
          }
        }
        break
      case "showVideoSegue":
        if let
          destController = segue.destinationViewController as? MusicViewController {
          if let _object = sender as? RecommendedItem {
            destController.item = _object
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
      if _item.type! == .Music {
        performSegueWithIdentifier("showMusicVCSegue", sender: _item)
      } else {
        performSegueWithIdentifier("showVideoSegue", sender: _item)
      }
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let _items = items {
      let _item = _items[indexPath.row]
      if _item.type! == .Music {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicTableViewCell", forIndexPath: indexPath) as! MusicTableViewCell
        cell.item = _item
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
        cell.item = _item
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
