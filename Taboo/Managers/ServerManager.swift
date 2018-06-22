//
//  SocketManager.swift
//  Taboo
//
//  Created by Alessandro Izzo on 21/06/18.
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import Foundation
import SocketIO

class ServerManager {
  
  public static let shared = ServerManager()
  
  private let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
  private let socket: SocketIOClient!
  
  private init() {
    socket = manager.defaultSocket
  }
  
  func connect(completion: @escaping ([Any], SocketAckEmitter) -> Void) {
    socket.on("connect") { (data, ack) in
      completion(data, ack)
    }
    socket.connect()
  }
  
  func login(name: String, completion: @escaping ([Room]?, User?) -> Void) {
    socket.emitWithAck("login", name).timingOut(after: 0) { (data) in
      
      do {
        var json = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let rooms = try JSONDecoder().decode([Room].self, from: json)
        
        json = try JSONSerialization.data(withJSONObject: data[1], options: .prettyPrinted)
        let user = try JSONDecoder().decode(User.self, from: json)
        
        completion(rooms, user)
      } catch {
        print(error.localizedDescription)
        completion(nil, nil)
      }
    }
  }
  
  func createRoom(name: String, maxPlayers: Int, completion: @escaping (String?) -> Void) {
    let json = ["name": name, "maxPlayers": maxPlayers] as Any
    socket.emitWithAck("create room", with: [json]).timingOut(after: 0) { (data) in
      let message = data[0] as! String
      if message != "success" {
        completion(message)
      } else {
        completion(nil)
      }
    }
  }
  
  func updateRooms(completion: @escaping ([Room]?) -> Void) {
    socket.on("update rooms") { (data, ack) in
      print(data[0])
      do {
        let json = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let rooms = try JSONDecoder().decode([Room].self, from: json)
        completion(rooms)
      } catch {
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  func join(room: Room, completion: @escaping (Bool) -> Void) {
    let json = try? JSONEncoder().encode(room)
    socket.emitWithAck("join room", [json]).timingOut(after: 0) { (data) in
      let message = String(describing: data[0])
      if message == "ok" {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  func ready(room: Room, user: User, completion: @escaping () -> Void) {
    
    let jsonRoom = try? JSONEncoder().encode(room)
    let jsonUser = try? JSONEncoder().encode(user)
    let json = ["room": jsonRoom, "user": jsonUser]
    socket.emitWithAck("ready", with: [json]).timingOut(after: 0) { (data) in
      completion()
    }
  }
  
  func updateReadyUsers(completion: @escaping ([User]?) -> Void) {
    socket.on("refresh room") { (data, ack) in
      do {
        let json = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let users = try JSONDecoder().decode([User].self, from: json)
        completion(users)
      } catch {
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  func exitRoom(user: User, room: Room, completion: @escaping () -> Void) {
    let jsonRoom = try? JSONEncoder().encode(room)
    let jsonUser = try? JSONEncoder().encode(user)
    let json = ["room": jsonRoom, "user": jsonUser]
    socket.emitWithAck("user exit room", json).timingOut(after: 0) { (data) in
      completion()
    }
  }
  
  func checkStartGame(completion: @escaping () -> Void) {
    socket.on("start game") { (data, ack) in
      completion()
    }
  }
  
  func sendDrawing(in room: Room, lastPoint: CGPoint, newPoint: CGPoint) {
    let jsonLastPoint = try? JSONEncoder().encode(lastPoint)
    let jsonNewPoint = try? JSONEncoder().encode(newPoint)
    let jsonRoom = try? JSONEncoder().encode(room)
    let json = ["lastPoint": jsonLastPoint, "newPoint": jsonNewPoint, "room": jsonRoom]
    socket.emit("draw", json)
  }
  
  func fetchDrawing(completion: @escaping (CGPoint?, CGPoint?) -> Void) {
    socket.on("update draw") { (data, ack) in
      do {
        let jsonPoints = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let points = try JSONDecoder().decode([CGPoint].self, from: jsonPoints)
        completion(points[0], points[1])
      } catch {
        print(error.localizedDescription)
        completion(nil, nil)
      }
    }
  }
}
