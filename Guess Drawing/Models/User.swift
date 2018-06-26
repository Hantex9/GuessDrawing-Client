//
//  User.swift
//  Taboo
//
//  Created by Alessandro Izzo on 22/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import Foundation

struct User: Codable {
  let id: String
  let name: String
  let isReady: Bool
  var score: Int
}
