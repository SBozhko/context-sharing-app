//
//  MusicViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/16/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Social

var downloadTask: NSURLSessionDownloadTask?

class MusicViewController: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var trackTitleLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var timeElapsedLabel: UILabel!
  @IBOutlet weak var currentTimeSlider: UISlider!
  @IBOutlet weak var playImageView: UIImageView!
  @IBOutlet weak var shareImageView: UIImageView!
  @IBOutlet weak var likeImageView: UIImageView!
  @IBOutlet weak var closeImageView: UIImageView!
  
  var avPlayer: AVPlayerExt?
  var scrubbing = false
  var timer = NSTimer()
  var item : RecommendedItem?
  var currentAudioDuration: NSNumber {
    get {
      return NSNumber(double: Double(item!.duration!))
    }
  }
  var currentAudioTime: NSNumber {
    get {
      if let player = avPlayer {
        return NSNumber(double: CMTimeGetSeconds(player.currentTime()))
      } else {
        return 0.0
      }
    }
    set (newValue) {
      if let player = avPlayer {
        player.seekToTime(CMTimeMakeWithSeconds(Float64(newValue), player.currentTime().timescale))
      }
    }
  }
  var headphonePluggedIn : Bool {
    get {
      let currentRoute = AVAudioSession.sharedInstance().currentRoute
      if !currentRoute.outputs.isEmpty {
        for description in currentRoute.outputs {
          if description.portType == AVAudioSessionPortHeadphones {
            return true
          }
        }
      }
      return false
    }
  }
  var isPlaying = false
  var liked = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.updateUI()
    addImageViewModifications(likeImageView)
    addImageViewModifications(playImageView)
    addImageViewModifications(shareImageView)
    addImageViewModifications(closeImageView)
  }
  
  func addImageViewModifications(imgView : UIImageView) {
    let recognizer = UITapGestureRecognizer(target: self, action:#selector(MusicViewController.handleImageTapGesture(_:)))
    recognizer.delegate = self
    imgView.addGestureRecognizer(recognizer)
  }
  
  func handleImageTapGesture(gestureRecognizer: UITapGestureRecognizer) {
    if let _imageView = gestureRecognizer.view as? UIImageView {
      switch _imageView.tag {
      case 0:
        handleSharePressed()
        break
      case 1:
        handlePlayPausePressed()
        break
      case 2:
        handleLikeButtonPressed()
        break
      case 3:
        handleClosePressed()
        break
      default:
        break
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    /* Invalidate timer when view will disappear */
    stopUISliderTimer()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // MARK: - UI Updates
  
  func startUISliderTimer(subType: UIEventSubtype) {
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MusicViewController.updateTime(_:)), userInfo: subType.rawValue, repeats: true)
  }
  
  func stopUISliderTimer() {
    timer.invalidate()
  }
  
  func updateTime(timer: NSTimer) {
    if let _ = timer.userInfo as? Int {
      if (UIApplication.sharedApplication().applicationState == .Active && self.isViewVisible()) {
        let timeLeft = currentAudioDuration.integerValue - currentAudioTime.integerValue
        if !scrubbing {
          currentTimeSlider.value = Float(currentAudioTime)
        }
        
        timeElapsedLabel.text = String(format: "%@", getDurationString(currentAudioTime.integerValue))
        durationLabel.text = String(format: "-%@", getDurationString(timeLeft))
      }
    }
  }
  
  func updateUI() {
    if let _thumbnail = item!.thumbnailImage {
      self.artworkImageView.image = _thumbnail
    } else {
      if let
        _thumbnailUrl = item!.thumbnailImageUrl,
        url = NSURL(string: _thumbnailUrl) {
        downloadTask = self.artworkImageView.loadImageWithURL(url, item: item, indexPath: nil)
      }
    }
    
    self.trackTitleLabel.text = item!.title!
    self.currentTimeSlider.minimumValue = 0.0
    self.currentTimeSlider.maximumValue = Float(self.currentAudioDuration)
    self.currentTimeSlider.value = Float(self.currentAudioTime)
    self.timeElapsedLabel.text = String(format: "%@", getDurationString(self.currentAudioTime.integerValue))
    self.durationLabel.text = String(format: "-%@", getDurationString(self.currentAudioDuration.integerValue - self.currentAudioTime.integerValue))
    self.playImageView.image = UIImage(named: "pause")
    playTrack()
  }
  
  // MARK: - IB Action Handlers
  
  @IBAction func userIsScrubbing(sender: UISlider) {
    stopUISliderTimer()
    scrubbing = true
  }
  
  @IBAction func setCurrentTime(sender: UISlider) {
    scrubbing = false
    currentAudioTime = Double(currentTimeSlider.value)
    startUISliderTimer(.None)
  }
  
  func updateLikeButtonUI(like : Bool) {
    if like {
      self.likeImageView.image = UIImage(named: "liked")
    } else {
      self.likeImageView.image = UIImage(named: "like")
    }
  }
  
  func handleClosePressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func socialMediaSharing(serviceType : String) {
    if SLComposeViewController.isAvailableForServiceType(serviceType) {
      let composeController = SLComposeViewController(forServiceType: serviceType)
      if !composeController.setInitialText("Shared from Jarvis! What do you think?") {
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
    let urlString = "Just discovered this track via Number8 - \(item!.streamUrl)! Download the app @ https://goo.gl/tU4JJD!"
    let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    let url = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
    if UIApplication.sharedApplication().canOpenURL(url!) {
      UIApplication.sharedApplication().openURL(url!)
    }
  }
  
  func handleSharePressed() {
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
    
    optionMenu.view.tintColor = UIColor(red: 0.6, green: 0.118, blue: 0.875, alpha: 1)
    presentViewController(optionMenu, animated: true, completion: nil)
  }
  
  func handleLikeButtonPressed() {
    if liked {
      self.likeImageView.image = UIImage(named: "like")
    } else {
    self.likeImageView.image = UIImage(named: "liked")
    }
    liked = !liked
  }
  
  func handlePlayPausePressed() {
    if isPlaying {
      self.playImageView.image = UIImage(named: "like")
    } else {
      self.playImageView.image = UIImage(named: "liked")
    }
    isPlaying = !isPlaying
  }
   
  /* Play a new track or the same track */
  func playTrack() {
    if let player = avPlayer {
      player.pause()
      self.avPlayer = nil
    }
    
    avPlayer = AVPlayerExt(URL: NSURL(string: String(format: "%@?client_id=%@", item!.streamUrl!, Credentials.soundCloudClientId))!)
    self.avPlayer!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
  }
  
  override func observeValueForKeyPath(keyPath : String?, ofObject: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if ofObject as? NSObject == avPlayer && keyPath == "status" {
      if let status = avPlayer?.status {
        switch status {
        case .Failed:
          break
        case .Unknown:
          break
        case .ReadyToPlay:
          self.setOutputAudioPort()
          self.avPlayer?.play()
          self.isPlaying = true
        }
      }
    }
  }
  
  private func externalAudioActive() -> Bool {
    let currentAudioRoutes = AVAudioSession.sharedInstance().currentRoute.outputs
    for outputPort in currentAudioRoutes {
      print("External audio port name: \(outputPort.portName), \(outputPort.portType)")
      if  outputPort.portType == AVAudioSessionPortAirPlay ||
        outputPort.portType == AVAudioSessionPortBluetoothA2DP ||
        outputPort.portType == AVAudioSessionPortBluetoothHFP {
        return true
      }
    }
    return false
  }
  
  func getAudioDeviceFromTypes(types : [String]) -> AVAudioSessionPortDescription? {
    let routes = AVAudioSession.sharedInstance().availableInputs
    var returnedRoute : AVAudioSessionPortDescription?
    if let unwrappedRoutes = routes {
      for route in unwrappedRoutes {
        if types.contains(route.portType) {
          returnedRoute = route
        }
      }
    }
    return returnedRoute
  }
  
  func getBluetoothAudioDevice() -> AVAudioSessionPortDescription? {
    let bluetoothRoutes = [AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP]
    return getAudioDeviceFromTypes(bluetoothRoutes)
  }
  
  func getBuiltInAudioDevice() -> AVAudioSessionPortDescription? {
    let builtinRoutes = [AVAudioSessionPortBuiltInMic];
    return getAudioDeviceFromTypes(builtinRoutes)
  }
  
  func getSpeakerAudioDevice() -> AVAudioSessionPortDescription? {
    let builtinRoutes = [AVAudioSessionPortBuiltInSpeaker];
    return getAudioDeviceFromTypes(builtinRoutes)
  }
  
  func setOutputAudioPort(headphonePluggedInNotfReceived : Bool = false) {
    if !externalAudioActive() {
      let portOverride = headphonePluggedInNotfReceived ?
        AVAudioSessionPortOverride.None :
        (self.headphonePluggedIn ?
          AVAudioSessionPortOverride.None :
          AVAudioSessionPortOverride.Speaker)
      do {
        try AVAudioSession.sharedInstance().overrideOutputAudioPort(portOverride)
      } catch let error as NSError {

      }
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    self.avPlayer!.removeObserver(self, forKeyPath: "status")
  }
}
