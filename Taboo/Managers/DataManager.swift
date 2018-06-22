//
//  DataManager.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import Foundation


class DataManager {
  
  public static let shared = DataManager()
  
  var user: User!
  var rooms: [Room] = []
  var joinedRoom: Int?
  
  private init() {
    
  }

}
