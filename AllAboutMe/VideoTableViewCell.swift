//
//  VideoTableViewCell.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/15/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  var item : RecommendedItem?
  var downloadTask: NSURLSessionDownloadTask?

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {

  }

  func configure(item : RecommendedItem) {
    self.item = item
    if let _title = item.title {
      self.titleLabel.text = _title
    }
    if let _duration = item.duration {
      self.durationLabel.text = _duration
    }
    if let _cachedThumbnailImage = item.thumbnailImage {
      self.artworkImageView.image = _cachedThumbnailImage
    } else {
      if let
        thumbnailUrl = item.thumbnailImageUrl,
        url = NSURL(string: thumbnailUrl) {
        downloadTask = self.artworkImageView.loadImageWithURL(url, bounds: CGSize(width: self.frame.width, height: self.frame.height), item: item)
      }
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    downloadTask?.cancel()
    downloadTask = nil
    titleLabel = nil
    durationLabel.text = nil
    artworkImageView.image = nil
  }
}
