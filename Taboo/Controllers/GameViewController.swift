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
  
  override func viewDidLoad() {
    super.viewDidLoad()

    drawView.clipsToBounds = true
    drawView.isMultipleTouchEnabled = false
    
  }
}
