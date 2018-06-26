//
//  RoomsCollectionViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class RoomsCollectionViewController: UICollectionViewController {
  
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
  
  private let addButton: UIButton = {
    let btn = UIButton()
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("+", for: .normal)
    btn.backgroundColor = UIColor(red: 91/255, green: 184/255, blue: 91/255, alpha: 1.0)
    btn.tintColor = .white
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 48)
    btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)
    btn.layer.cornerRadius = 65/2
    btn.layer.shadowColor = UIColor.black.cgColor
    btn.layer.shadowRadius = 2.0
    btn.layer.shadowOpacity = 1.0
    btn.layer.shadowOffset = CGSize(width: 0, height: 2)
    btn.layer.masksToBounds = false
    btn.isUserInteractionEnabled = true
    btn.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    return btn
  }()
  
  private let noRoomLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 30)
    label.textColor = .white
    label.text = "No room to show, create one you!"
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowRadius = 3.0
    label.layer.shadowOpacity = 1.0
    label.numberOfLines = 0
    label.layer.shadowOffset = CGSize(width: 4, height: 4)
    label.layer.masksToBounds = false
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  
  fileprivate let dataManager = DataManager.shared
  fileprivate let serverManager = ServerManager.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundImageView.addSubview(blurView)
    blurView.frame = view.frame
    
    self.view.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.heightAnchor.constraint(equalToConstant: 65),
      addButton.widthAnchor.constraint(equalToConstant: 65),
      addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
      addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
    ])
    
    setupObservers()
    updateRoomLabel()
  }
  
  fileprivate func setupObservers() {
    serverManager.roomsListener { (rooms) in
      guard let rooms = rooms else { return }
      self.dataManager.rooms = rooms
      
      self.updateRoomLabel()
      
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  
  fileprivate func updateRoomLabel() {
    if dataManager.rooms.isEmpty {
      self.view.addSubview(noRoomLabel)
      NSLayoutConstraint.activate([
        noRoomLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        noRoomLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        noRoomLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
        noRoomLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30)
      ])
    } else {
      noRoomLabel.removeFromSuperview()
    }
  }
  
  fileprivate func joinRoom(index: Int) {
    let room = dataManager.rooms[index]
    
    if room.connectedUsers!.count == room.maxUsers {
      self.showAlert(message: "This room reached the maximum number of player", title: "Busy Room")
    } else if room.isGameStarted {
      self.showAlert(message: "This room already started a match!", title: "Already Started")
    } else {
      serverManager.join(room: dataManager.rooms[index]) { (success) in
        guard success == true else { return }
        
        self.dataManager.joinedRoom = self.dataManager.rooms[index].id
        
        let storyboard = UIStoryboard(name: "Creation", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserListRoom")
        //      self.navigationController?.pushViewController(vc, animated: true)
        //      self.dismiss(animated: true, completion: nil)
//        self.present(vc, animated: true, completion: nil)
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.fade
        self.navigationController?.view.layer.add(transition, forKey:nil)
        self.navigationController?.pushViewController(vc, animated: false)
        self.navigationController?.viewControllers = [vc]
      }
    }
  }

  // - MARK: Actions
  @objc func joinButtonPressed(_ sender: UIButton) {
    joinRoom(index: sender.tag)
  }
  
  @objc func addButtonPressed() {
    let transition = CATransition()
    transition.duration = 0.2
    transition.type = CATransitionType.fade
    self.navigationController?.view.layer.add(transition, forKey:nil)
    let storyboard = UIStoryboard(name: "Creation", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "CreationView")
    self.navigationController?.pushViewController(vc, animated: false)
    self.navigationController?.viewControllers = [vc]
  }

  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataManager.rooms.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomCell", for: indexPath) as! RoomViewCell
    let room = dataManager.rooms[indexPath.item]
    
    cell.idLabel.text = (room.isGameStarted) ? "PLAYING" : "OPEN"
    cell.idLabel.sizeToFit()
    cell.nameLabel.text = room.name
    cell.playerCountLabel.text = "\(room.connectedUsers!.count)/\(room.maxUsers)"
    cell.playerCountLabel.sizeToFit()
    cell.maxRoundLabel.text = "\(room.maxRound!)"
    cell.maxRoundLabel.sizeToFit()
    
    cell.joinButtonPressed.addTarget(self, action: #selector(joinButtonPressed), for: .touchUpInside)
    cell.joinButtonPressed.tag = indexPath.row
    cell.joinButtonPressed.isUserInteractionEnabled = true
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
}
