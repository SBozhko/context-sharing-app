//
//  MusicTableViewCell.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/15/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  var item : RecommendedItem?
  var downloadTask: NSURLSessionDownloadTask?

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

  func configure(item : RecommendedItem, indexPath : NSIndexPath) {
    self.item = item
    if let _title = item.title {
      self.titleLabel.text = _title
    }
    if let _duration = item.duration {
      self.durationLabel.text = getDurationString(_duration)
    }
    if let _cachedThumbnailImage = item.thumbnailImage {
      self.artworkImageView.image = _cachedThumbnailImage
    } else {
      if let
        thumbnailUrl = item.thumbnailImageUrl,
        url = NSURL(string: thumbnailUrl) {
//        downloadTask = self.artworkImageView.loadImageWithURL(url, item: item, indexPath: indexPath)
      }
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    downloadTask?.cancel()
    downloadTask = nil
    titleLabel = nil
    artistLabel = nil
    durationLabel.text = nil
    artworkImageView.image = nil
  }
}
