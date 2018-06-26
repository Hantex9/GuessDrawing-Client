//
//  LoginView.swift
//  Taboo
//
//  Created by Alessandro Izzo on 24/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class LoginFormView: UIView {
  
  @IBOutlet weak var usernameTextField: UITextField! {
    didSet {
      usernameTextField.layer.masksToBounds = true
      usernameTextField.borderStyle = UITextField.BorderStyle.roundedRect
      usernameTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
  }
  @IBOutlet weak var playButton: UIButton!
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  fileprivate func setup() {
    self.layer.cornerRadius = 8
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 2, height: 2)
    layer.shadowRadius = 13/2
    
    let rect = bounds.insetBy(dx: -3, dy: -3)
    layer.shadowPath = UIBezierPath(rect: rect).cgPath

  }
  
}

