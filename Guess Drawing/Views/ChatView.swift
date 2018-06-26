//
//  ChatView.swift
//  Taboo
//
//  Created by Alessandro Izzo on 23/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class ChatView: UIView {

  @IBOutlet weak var messageTextField: UITextField!
  @IBOutlet weak var chatTextView: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var winningWord: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var chatTopConstraint: NSLayoutConstraint!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = 20
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowRadius = 7/2
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 1, height: 2)
    self.layer.masksToBounds = false
    var rect = self.bounds.insetBy(dx: -2, dy: -2)
    self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    
    winningWord.layer.cornerRadius = 5
    winningWord.layer.shadowColor = UIColor.black.cgColor
    winningWord.layer.shadowRadius = 1.5
    winningWord.layer.shadowOpacity = 0.5
    winningWord.layer.shadowOffset = CGSize(width: 0, height: 2)
    winningWord.layer.masksToBounds = false
    rect = winningWord.bounds.insetBy(dx: -1, dy: -1)
    winningWord.layer.shadowPath = UIBezierPath(rect: rect).cgPath
  }
  
  func setup() {
    
    chatTextView.layer.cornerRadius = 10
    chatTextView.layer.masksToBounds = true
    chatTextView.layer.borderWidth = 0.5
    chatTextView.layer.borderColor = UIColor.lightGray.cgColor
    
    tableView.layer.cornerRadius = 10
    tableView.layer.masksToBounds = true
    tableView.layer.borderWidth = 0.5
    tableView.layer.borderColor = UIColor.lightGray.cgColor
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
    self.addGestureRecognizer(panGesture)
    
  }
  
  @objc func panHandler(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: self)
    
    chatTopConstraint.constant += translation.y
    if chatTopConstraint.constant > 555 {
      chatTopConstraint.constant = 555
    } else if chatTopConstraint.constant < 140 {
      chatTopConstraint.constant = 140
    }
  
    self.layoutIfNeeded()
    sender.setTranslation(CGPoint.zero, in: self)
  }
}
