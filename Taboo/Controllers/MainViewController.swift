//
//  MainViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  
  fileprivate let serverManager = ServerManager.shared
  fileprivate let dataManager = DataManager.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    serverManager.connect { (data, ack) in
      print("user connected")
    }
    
  }
  
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard let name = usernameTextField.text else { return }
    
    serverManager.login(name: name) { (rooms, user) in
      if let rooms = rooms {
        self.dataManager.rooms = rooms
      }
    
      print(rooms, user)
      
      self.dataManager.user = user
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "RoomsView")
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}
