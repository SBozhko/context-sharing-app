//
//  OnboardingGetNameViewController.swift
//  Jarvis
//
//  Created by Abhishek Sen on 8/10/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit

class OnboardingGetNameViewController: UIViewController {

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var nameEnteredButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    nameEnteredButton.hidden = true
    nameTextField.attributedPlaceholder = NSAttributedString(string:"What's your name?",
                                                             attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Regular", size: 10.0)!,
                                                                          NSForegroundColorAttributeName: UIColor.whiteColor()])
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  @IBAction func nameEnteredButtonPressed(sender: AnyObject) {
    /* Get name from text field and save it */
    NSUserDefaults.standardUserDefaults().setValue(nameTextField.text, forKey: nameKey)
    /* Register our Credentials info */
    _ = Credentials.sharedInstance
    performSegueWithIdentifier("askPermissionsSegue", sender: self)
  }
}

extension OnboardingGetNameViewController : UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if let _text = textField.text {
      nameEnteredButton.hidden = _text.characters.count <= 0
    } else {
      nameEnteredButton.hidden = true
    }
    return true
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    nameTextField.placeholder = nil
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    nameTextField.attributedPlaceholder = NSAttributedString(string:"What's your name?", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])  }
}
