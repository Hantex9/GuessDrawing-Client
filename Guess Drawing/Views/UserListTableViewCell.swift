//
//  UserListTableViewCell.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var readyCheckmark: UIImageView!
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

}
