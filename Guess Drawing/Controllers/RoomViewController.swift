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
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var roomNameLabel: UILabel!
  @IBOutlet weak var playersCountLabel: UILabel!
  @IBOutlet weak var maxRoundLabel: UILabel!
  
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
  
  fileprivate let dataManager = DataManager.shared
  fileprivate let serverManager = ServerManager.shared
  fileprivate var joinedRoom: Room? {
    get {
      let index = dataManager.rooms.lastIndex { $0.id == dataManager.joinedRoom }
      guard let indexRoom = index else { return nil }
      guard indexRoom < dataManager.rooms.count else { return nil }
      return dataManager.rooms[indexRoom]
    }
    set {
      let index = dataManager.rooms.lastIndex { $0.id == dataManager.joinedRoom }
      guard let indexRoom = index else { return }
      guard let newValue = newValue else { return }
      dataManager.rooms[indexRoom] = newValue
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupObservers()
    
    setupView()
  }
  
  fileprivate func setupView() {
    
    backgroundImageView.addSubview(blurView)
    blurView.frame = self.view.frame
    
    navigationController?.navigationBar.isHidden = true
    
    if let joinedRoom = joinedRoom {
      roomNameLabel.text = joinedRoom.name
      roomNameLabel.sizeToFit()
      
      maxRoundLabel.text = "\(joinedRoom.maxRound!)"
      playersCountLabel.text = "\(joinedRoom.connectedUsers!.count)"
    }
    
    containerView.layer.cornerRadius = 8
    
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.5
    containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
    containerView.layer.shadowRadius = 13/2
    
    let rect = containerView.bounds.insetBy(dx: -3, dy: -3)
    containerView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
  }
  
  fileprivate func setupObservers() {
    
    serverManager.roomsListener { (rooms) in // TODO
      guard let rooms = rooms else { return }
      self.dataManager.rooms = rooms
      
      if let joinedRoom = self.joinedRoom {
        
        self.maxRoundLabel.text = "\(joinedRoom.maxRound!)"
        self.roomNameLabel.text = joinedRoom.name
        self.playersCountLabel.text = "\(joinedRoom.connectedUsers!.count)"
      }
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
    
    serverManager.startGameListener {
      let storyboard = UIStoryboard(name: "Game", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "GameView")
      let transition = CATransition()
      transition.duration = 0.3
      transition.type = CATransitionType.fade
      self.navigationController?.view.layer.add(transition, forKey:nil)
      
      self.navigationController?.pushViewController(vc, animated: false)
      self.navigationController?.viewControllers = [vc]
    }
  }
  
  @IBAction func readyButtonPressed(_ sender: UIButton) {
    guard let joinedRoom = joinedRoom else { return }
    serverManager.ready(room: joinedRoom, user: dataManager.user) {
      
    }
  }
  
  @IBAction func exitButtonPressed(_ sender: UIButton) {
    guard let joinedRoom = joinedRoom else { return }
    serverManager.exitRoom(room: joinedRoom) { () in
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
    cell.readyCheckmark.isHidden = !user.isReady
    
    return cell
  }
}
