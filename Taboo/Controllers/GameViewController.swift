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
  
  fileprivate var path = UIBezierPath()
  fileprivate var startPoint = CGPoint()
  fileprivate var touchPoint = CGPoint()
  
  fileprivate let serverManager = ServerManager.shared
  fileprivate let dataManager = DataManager.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()

    drawView.clipsToBounds = true
    drawView.isMultipleTouchEnabled = false
    drawView.delegate = self
    
    serverManager.fetchDrawing { (lastPoint, newPoint) in
      guard let lastPoint = lastPoint, let newPoint = newPoint else { return }
      
      self.drawView.touchesReceived(lastPoint: lastPoint, newPoint: newPoint)
    }
  }
}

extension GameViewController: DrawViewDelegate {
  func shouldDraw(lastPoint: CGPoint, newPoint: CGPoint) {
    serverManager.sendDrawing(in: dataManager.rooms[dataManager.joinedRoom!],lastPoint: lastPoint, newPoint: newPoint)
  }
}
