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

  @IBOutlet weak var itemView1: UIView!
  @IBOutlet weak var imageView1: UIImageView!
  @IBOutlet weak var itemTypeImageView1: UIImageView!
  @IBOutlet weak var titleLabel1: UILabel!
  @IBOutlet weak var durationLabel1: UILabel!
  @IBOutlet weak var itemView2: UIView!
  @IBOutlet weak var imageView2: UIImageView!
  @IBOutlet weak var itemTypeImageView2: UIImageView!
  @IBOutlet weak var titleLabel2: UILabel!
  @IBOutlet weak var durationLabel2: UILabel!
  
  var items : [RecommendedItem]!
  var downloadTask1: NSURLSessionDownloadTask?
  var downloadTask2: NSURLSessionDownloadTask?

  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(ItemListViewController.handleImageDownloadNotification(_:)),
                                                     name: imageDownloadNotification,
                                                     object: nil)
    loadItems()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  func loadItems() {
    populateView(itemView1.tag)
    populateView(itemView2.tag)
  }
  
  func loadImage(itemViewTag : Int) {
    let toImageView : UIImageView? = itemViewTag == 0 ? imageView1 : imageView2
    let toImage : UIImage? = items[itemViewTag].thumbnailImage
    if let
      localToImageView = toImageView,
      localToImage = toImage {
      UIView.transitionWithView(localToImageView, duration: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        localToImageView.image = localToImage
        }, completion: nil)
    }
  }
  
  func populateView(itemViewTag : Int) {
    let index = itemViewTag
    if index == 0 {
      itemTypeImageView1.image = items[index].type! == .Music ? UIImage(named: "music") : UIImage(named: "video")
      if let localTitle = items[index].title {
        titleLabel1.text = localTitle
      }
      if let localDuration = items[index].duration {
        durationLabel1.text = getDurationString(localDuration)
      }
      if items[index].thumbnailImage != nil {
        loadImage(index)
      } else {
        if let
          thumbnailUrl = items[index].thumbnailImageUrl,
          url = NSURL(string: thumbnailUrl) {
          downloadTask1 = imageView1.loadImageWithURL(url, item: items[index], index: index)
        }
      }
    } else {
      itemTypeImageView2.image = items[index].type! == .Music ? UIImage(named: "music") : UIImage(named: "video")
      if let localTitle = items[index].title {
        titleLabel2.text = localTitle
      }
      if let localDuration = items[index].duration {
        durationLabel2.text = getDurationString(localDuration)
      }
      if items[index].thumbnailImage != nil {
        loadImage(index)
      } else {
        if let
          thumbnailUrl = items[index].thumbnailImageUrl,
          url = NSURL(string: thumbnailUrl) {
          downloadTask2 = imageView2.loadImageWithURL(url, item: items[index], index: index)
        }
      }
    }
  }

  func handleImageDownloadNotification(notification : NSNotification) {
    if let index = notification.object as? Int {
      dispatch_async(dispatch_get_main_queue(), {
        self.loadImage(index)
      })
    }
  }
  
  @IBAction func handleRefresh() {
    if let _items = Recommendations.sharedInstance.getItems(2) {
      items.removeAll(keepCapacity: true)
      _items.forEach({ (item) in
        items.append(item)
      })
      Mixpanel.sharedInstance().track("RefreshedItems")
      loadItems()
    }
  }
  
  @IBAction func itemButtonPressed(sender: UIButton) {
    let index = sender.tag
    if items[index].type! == .Music {
      performSegueWithIdentifier("showMusicVCSegue", sender: index)
    } else {
      performSegueWithIdentifier("showWebViewVCSegue", sender: index)
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
          if let index = sender as? Int {
            destController.item = self.items[index]
          }
        }
        break
      case "showWebViewVCSegue":
        if let
          navController = segue.destinationViewController as? UINavigationController,
          destController = navController.topViewController as? WebViewController {
            if let index = sender as? Int {
              destController.item = self.items[index]
            }
        }
      default:
        break
      }
    }
  }
}
