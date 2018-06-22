//
//  Room.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import Foundation

struct Room: Codable {
  let id: Int
  let name: String
  var connectedUsers: [User]?
  let maxUsers: Int
  var isGameStarted: Bool
}
