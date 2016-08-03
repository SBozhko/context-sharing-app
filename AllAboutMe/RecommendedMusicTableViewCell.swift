//
//  RecommendedMusicTableViewCell.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/3/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class RecommendedMusicTableViewCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var itemTypeImageView: UIImageView!
  @IBOutlet weak var thumbnailImageView: UIImageView!

  var downloadTask: NSURLSessionDownloadTask?

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func configure(item : RecommendedItem) {
    titleLabel.text = item.title
    itemTypeImageView.image = UIImage(named: item.type == ItemType.Music ? "music" : "video")
    if let _cachedThumbnailImage = item.thumbnailImage {
      thumbnailImageView.image = _cachedThumbnailImage
    } else {
//      if let
//        thumbnailUrl = item.thumbnailImageUrl,
//        url = NSURL(string: thumbnailUrl) {
//          downloadTask = thumbnailImageView.loadImageWithURL(url, bounds: CGSize(width: self.frame.width, height: self.frame.height), item: item)
//      }
      thumbnailImageView.image = UIImage(named: "beach")
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    downloadTask?.cancel()
    downloadTask = nil
    titleLabel.text = nil
    itemTypeImageView.image = nil
    thumbnailImageView.image = nil
  }
}
