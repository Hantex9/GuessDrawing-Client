//
//  MatchInfoView.swift
//  Taboo
//
//  Created by Alessandro Izzo on 24/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

class MatchInfoView: UIView {

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
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 36.0)
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowRadius = 3.0
    label.layer.shadowOpacity = 1.0
    label.layer.shadowOffset = CGSize(width: 4, height: 4)
    label.layer.masksToBounds = false
    return label
  }()
  
  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 26.0)
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowRadius = 3.0
    label.layer.shadowOpacity = 1.0
    label.layer.shadowOffset = CGSize(width: 4, height: 4)
    label.layer.masksToBounds = false
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  fileprivate func setupView() {
    addSubview(blurView)
    blurView.contentView.addSubview(titleLabel)
    blurView.contentView.addSubview(descriptionLabel)
    
    NSLayoutConstraint.activate([
      blurView.topAnchor.constraint(equalTo: self.topAnchor),
      blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      
      descriptionLabel.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
      descriptionLabel.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
      titleLabel.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20),
      titleLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -10)
      
    ])
  }
  
}
