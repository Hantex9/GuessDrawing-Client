//
//  GameViewController.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

  @IBOutlet weak var drawView: DrawView!
  @IBOutlet weak var clearButton: UIButton!
  
  fileprivate var path = UIBezierPath()
  fileprivate var startPoint = CGPoint()
  fileprivate var touchPoint = CGPoint()
  
  fileprivate let serverManager = ServerManager.shared
  fileprivate let dataManager = DataManager.shared
  
  fileprivate var playerRoom: Room? {
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

    drawView.clipsToBounds = true
    drawView.isMultipleTouchEnabled = false
    drawView.delegate = self
    
    serverManager.fetchDraw { (lastPoint, newPoint) in
      guard let lastPoint = lastPoint, let newPoint = newPoint else { return }
      
      self.drawView.touchesReceived(lastPoint: lastPoint, newPoint: newPoint)
    }
    
    serverManager.onClearDraw {
      self.drawView.clear()
    }
  }
  
  @IBAction func clearButtonPressed(_ sender: UIButton) {
    drawView.clear()
    guard let playerRoom = playerRoom else { return print("è nil playerroom")}
    serverManager.clearDraw(in: playerRoom)
  }
  
}

extension GameViewController: DrawViewDelegate {
  func shouldDraw(lastPoint: CGPoint, newPoint: CGPoint) {
    guard let playerRoom = playerRoom else { return }
    serverManager.sendDrawing(in: playerRoom, lastPoint: lastPoint, newPoint: newPoint)
  }
}
