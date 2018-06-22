//
//  CreateRoomViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController {
  
  @IBOutlet weak var roomNameTextField: CustomTextField!
  @IBOutlet weak var maxPlayersTextField: CustomTextField!
  
  fileprivate let serverManager = ServerManager.shared

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }

  @IBAction func createButtonPressed(_ sender: UIButton) {
    guard let maxPlayers = Int(maxPlayersTextField.text!) else { return }
    
    serverManager.createRoom(name: roomNameTextField.text!, maxPlayers: maxPlayers) { (errorMessage) in
      guard errorMessage == nil else {
        self.showAlert(message: errorMessage!)
        return
      }
      
      DataManager.shared.joinedRoom = DataManager.shared.rooms.count
      
      let storyboard = UIStoryboard(name: "Creation", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "UserListRoom")
//      self.navigationController?.pushViewController(vc, animated: true)
//      self.dismiss(animated: true, completion: nil)
      self.present(vc, animated: true, completion: nil)
    }
  }
  
  @IBAction func closeButtonPressed(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
