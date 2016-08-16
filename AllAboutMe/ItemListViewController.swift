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
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    tableView.reloadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    

  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
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

extension ItemListViewController : UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items!.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let _items = items {
      let _item = _items[indexPath.row]
      if _item.type! == .Music {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicTableViewCell") as? MusicTableViewCell
        cell?.configure(_item)
        return cell!
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell") as? VideoTableViewCell
        cell?.configure(_item)
        return cell!
      }
    }
    
    return UITableViewCell()
  }
}
