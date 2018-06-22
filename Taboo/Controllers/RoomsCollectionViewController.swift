//
//  RoomsCollectionViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class RoomsCollectionViewController: UICollectionViewController {
  
  fileprivate let dataManager = DataManager.shared
  fileprivate let serverManager = ServerManager.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    
    setupObservers()
  }
  
  fileprivate func setupObservers() {
    serverManager.updateRooms { (rooms) in
      guard let rooms = rooms else { return }
      self.dataManager.rooms = rooms
      
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  
  fileprivate func setupNavigationBar() {
    navigationItem.backBarButtonItem?.tintColor = .white
    navigationItem.rightBarButtonItem?.tintColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
  }
  
  @objc func addButtonPressed() {
    let storyboard = UIStoryboard(name: "Creation", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "CreationView")
    navigationController?.present(vc, animated: true)
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
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  

  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let room = dataManager.rooms[indexPath.row]
    
    if room.connectedUsers!.count == room.maxUsers {
      self.showAlert(message: "This room reached the maximum number of player", title: "Busy Room")
    } else if room.isGameStarted {
      self.showAlert(message: "This room already started a match!", title: "Already Started")
    } else {
      serverManager.join(room: dataManager.rooms[indexPath.row]) { (success) in
        guard success == true else { return }
        
        self.dataManager.joinedRoom = indexPath.row
        
        let storyboard = UIStoryboard(name: "Creation", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserListRoom")
        //      self.navigationController?.pushViewController(vc, animated: true)
        //      self.dismiss(animated: true, completion: nil)
        self.present(vc, animated: true, completion: nil)
      }
    }
    return true
  }
  
}
