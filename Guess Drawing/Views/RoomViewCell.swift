//
//  RoomViewCell.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class RoomViewCell: UICollectionViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var idLabel: UILabel!
  @IBOutlet weak var playerCountLabel: UILabel!
  @IBOutlet weak var maxRoundLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var joinButtonPressed: UIButton!
  
  override func awakeFromNib() {
    setup()
  }
  
  fileprivate func setup() {
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 2, height: 2)
    self.layer.shadowRadius = 13/2
    
    self.layer.cornerRadius = 8
    
    containerView.layer.cornerRadius = 8
    
    self.layer.masksToBounds = false
    
    let rect = self.bounds.insetBy(dx: -3, dy: -3)
    self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
  }
  
}
