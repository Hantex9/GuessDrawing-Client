//
//  CreateRoomViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController {
  
  @IBOutlet weak var roomNameTextField: UITextField! {
    didSet {
      roomNameTextField.layer.borderWidth = 0.5
      roomNameTextField.layer.borderColor = UIColor.gray.cgColor
      roomNameTextField.layer.cornerRadius = 3.0
    }
  }
  @IBOutlet weak var maxPlayersTextField: UITextField! {
    didSet {
      maxPlayersTextField.layer.borderWidth = 0.5
      maxPlayersTextField.layer.borderColor = UIColor.gray.cgColor
      maxPlayersTextField.layer.cornerRadius = 3.0
    }
  }
  @IBOutlet weak var maxRoundTextField: UITextField! {
    didSet {
      maxRoundTextField.layer.borderWidth = 0.5
      maxRoundTextField.layer.borderColor = UIColor.gray.cgColor
      maxRoundTextField.layer.cornerRadius = 3.0
    }
  }
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8
      
      containerView.layer.shadowColor = UIColor.black.cgColor
      containerView.layer.shadowOpacity = 0.5
      containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
      containerView.layer.shadowRadius = 13/2
      
      let rect = containerView.bounds.insetBy(dx: -3, dy: -3)
      containerView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  
  
  private let blurView: UIVisualEffectView = {
    let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    blurEffect.setValue(5.0, forKeyPath: "blurRadius")
    blurEffect.setValue(1.0, forKeyPath: "scale")
    blurEffect.setValue(UIColor.black, forKey: "colorTint")
    blurEffect.setValue(0.25, forKeyPath: "colorTintAlpha")
    
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.translatesAutoresizingMaskIntoConstraints = false
    return blurEffectView
  }()
  
  fileprivate let serverManager = ServerManager.shared

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
    
    backgroundImageView.addSubview(blurView)
    blurView.frame = view.frame
    
    //Notification for the Keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
  }
  
  @objc fileprivate func keyboardWillShow(notification: NSNotification) {
    self.view.frame.origin.y -= 80.0
  }
  
  @objc fileprivate func keyboardWillHide(notification: NSNotification) {
    self.view.frame.origin.y = 0
  }

  @IBAction func createButtonPressed(_ sender: UIButton) {
    guard !roomNameTextField.text!.isEmpty else {
      self.showAlert(message: "Please insert the room name.")
      return
    }
    
    guard let maxPlayers = Int(maxPlayersTextField.text!), maxPlayers <= 10 && maxPlayers >= 2 else {
      self.showAlert(message: "The number of players should be from 2 to 10")
      return
    }
    guard let maxRound = Int(maxRoundTextField.text!), maxRound <= 20 && maxRound >= 1 else {
      self.showAlert(message: "The number of round should be from 1 to 20")
      return
    }
    
    serverManager.createRoom(name: roomNameTextField.text!, maxPlayers: maxPlayers, maxRound: maxRound) { (room, errorMessage) in
      guard errorMessage == nil else {
        self.showAlert(message: errorMessage!)
        return
      }
      guard let room = room else { return }
      
      DataManager.shared.joinedRoom = room.id
      
      let storyboard = UIStoryboard(name: "Creation", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "UserListRoom")
      let transition = CATransition()
      transition.duration = 0.2
      transition.type = CATransitionType.fade
      self.navigationController?.view.layer.add(transition, forKey:nil)
      self.navigationController?.pushViewController(vc, animated: false)
      self.navigationController?.viewControllers = [vc]
    }
  }
  
  @objc fileprivate func tapHandler(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction func closeButtonPressed(_ sender: UIButton) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "RoomsView")
    
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.fade
    self.navigationController?.view.layer.add(transition, forKey:nil)
    
    self.navigationController?.pushViewController(vc, animated: false)
    self.navigationController?.viewControllers = [vc]
  }
  
}
