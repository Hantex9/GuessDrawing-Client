//
//  RoomViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

import UIKit

class RoomViewController: UIViewController {
  
  
  @IBOutlet weak var tableView: UITableView!
  
  fileprivate let dataManager = DataManager.shared
  fileprivate let serverManager = ServerManager.shared
  fileprivate var joinedRoom: Room? {
    get {
      guard let indexRoom = dataManager.joinedRoom, indexRoom < dataManager.rooms.count else { return nil }
      return dataManager.rooms[indexRoom]
    }
    set {
      guard let indexRoom = dataManager.joinedRoom else { return }
      guard let newValue = newValue else { return }
      dataManager.rooms[indexRoom] = newValue
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupObservers()
  }
  
  
  fileprivate func setupObservers() {
    
    serverManager.updateReadyUsers { (usersInRoom) in
      self.joinedRoom?.connectedUsers = usersInRoom
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
    
    serverManager.checkStartGame {
      let storyboard = UIStoryboard(name: "Game", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "GameView")
      //      self.navigationController?.pushViewController(vc, animated: true)
      //      self.dismiss(animated: true, completion: nil)
      self.present(vc, animated: true, completion: nil)
    }
  }
  
  @IBAction func readyButtonPressed(_ sender: UIButton) {
    guard let joinedRoom = joinedRoom else { return }
    serverManager.ready(room: joinedRoom, user: dataManager.user) {
      
    }
  }
  
  @IBAction func exitButtonPressed(_ sender: UIButton) {
    guard let joinedRoom = joinedRoom else { return }
    serverManager.exitRoom(user: dataManager.user, room: joinedRoom) { () in
      self.joinedRoom = nil
      self.dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: - Table view data source & delegate
extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let joinedRoom = joinedRoom else { return 0 }
    return joinedRoom.connectedUsers!.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserListTableViewCell
    guard let joinedRoom = joinedRoom else { return cell }
    guard let user = joinedRoom.connectedUsers?[indexPath.row] else { return cell }
    cell.usernameLabel.text = user.name
    cell.readyLabel.isHidden = !user.isReady
    
    return cell
  }
}
