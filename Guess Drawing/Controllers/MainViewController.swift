//
//  MainViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  @IBOutlet weak var loginView: LoginFormView!
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
  fileprivate let dataManager = DataManager.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    view.addGestureRecognizer(tapGesture)
    
    backgroundImageView.addSubview(blurView)
    blurView.frame = self.view.frame
    
    serverManager.connect { (data, ack) in
      print("user connected")
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard let name = loginView.usernameTextField.text, !name.isEmpty else {
      self.showAlert(message: "Please insert a valid nickname!")
      return
    }
    
    serverManager.login(name: name) { (rooms, user) in
      if let rooms = rooms {
        self.dataManager.rooms = rooms
      }
      
      self.dataManager.user = user
    
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
  
  // MARK: Actions
  @objc fileprivate func tapHandler(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
}
