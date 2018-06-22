//
//  Extensions.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//


import UIKit

extension UIViewController {
  
  func showAlert(message: String, title: String = NSLocalizedString("Error", comment: "errorAlertMessage")) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "closeAlert"), style: .cancel, handler: nil))
    
    self.present(alert, animated: true)
  }
  
  func showAlert(message: String, title: String = NSLocalizedString("Error", comment: "errorAlertMessage"), handler: @escaping () -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "closeAlert"), style: .cancel) { _ in
      handler()
    })
    
    self.present(alert, animated: true)
  }
}
