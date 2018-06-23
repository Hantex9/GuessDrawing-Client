//
//  DrawView.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

protocol DrawViewDelegate {
  func shouldDraw(lastPoint: CGPoint, newPoint: CGPoint)
}

class DrawView: UIView {
  
  var drawColor = UIColor.black    // Color for drawing
  var lineWidth: CGFloat = 2.5              // Line width
  
  private var lastPoint: CGPoint!         // Point for storing the last position
  private var bezierPath: UIBezierPath!   // Bezier path
  private var pointCounter: Int = 0       // Counter of ponts
  private let pointLimit: Int = 128       // Limit of points
  private var preRenderImage: UIImage!    // Pre render image
  
  var delegate: DrawViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    initBezierPath()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    initBezierPath()
  }
  
  fileprivate func initBezierPath() {
    bezierPath = UIBezierPath()
    bezierPath.lineCapStyle = .round
    bezierPath.lineJoinStyle = .round
  }
  
  fileprivate func renderToImage() {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
    if preRenderImage != nil {
      preRenderImage.draw(in: self.bounds)
    }
    
    bezierPath.lineWidth = lineWidth
    drawColor.setFill()
    drawColor.setStroke()
    bezierPath.stroke()
    
    preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: AnyObject? = touches.first
    lastPoint = touch!.location(in: self)
    pointCounter = 0
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: AnyObject? = touches.first
    let newPoint = touch!.location(in: self)
    
    delegate?.shouldDraw(lastPoint: lastPoint, newPoint: newPoint)
    bezierPath.move(to: lastPoint)
    bezierPath.addLine(to: newPoint)
    lastPoint = newPoint
    
    showDrawing()
    
  }
  
  func touchesReceived(lastPoint: CGPoint, newPoint: CGPoint) {
    bezierPath.move(to: lastPoint)
    bezierPath.addLine(to: newPoint)
    
    showDrawing()
  }
  
  fileprivate func showDrawing() {
    pointCounter += 1
    
    if pointCounter == pointLimit {
      pointCounter = 0
      renderToImage()
      setNeedsDisplay()
      bezierPath.removeAllPoints()
    }
    else {
      setNeedsDisplay()
    }
  }
  
  func clear() { 
    preRenderImage = nil
    bezierPath.removeAllPoints()
    setNeedsDisplay()
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    if preRenderImage != nil {
      preRenderImage.draw(in: self.bounds)
    }
    
    bezierPath.lineWidth = lineWidth
    drawColor.setFill()
    drawColor.setStroke()
    bezierPath.stroke()
  }

}
