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
  
  func createRoom(name: String, maxPlayers: Int, maxRound: Int, completion: @escaping (Room?, String?) -> Void) {
    let json = ["name": name, "maxPlayers": maxPlayers, "maxRound": maxRound] as Any
    socket.emitWithAck("create room", with: [json]).timingOut(after: 0) { (data) in
      let message = data[0] as! String
      if message != "success" {
        completion(nil, message)
      } else {
        do {
          let json = try JSONSerialization.data(withJSONObject: data[1], options: .prettyPrinted)
          let room = try JSONDecoder().decode(Room.self, from: json)
          completion(room, nil)
        } catch {
          print(error.localizedDescription)
          completion(nil, nil)
        }
      }
    }
  }
  
  func roomsListener(completion: @escaping ([Room]?) -> Void) {
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
  
  func exitRoom(room: Room, completion: @escaping () -> Void) {
    let jsonRoom = try? JSONEncoder().encode(room)
    let json = ["room": jsonRoom]
    socket.emitWithAck("user exit room", json).timingOut(after: 0) { (data) in
      completion()
    }
  }
  
  func startGameListener(completion: @escaping () -> Void) {
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
  
  func clearDraw(in room: Room) {
    let jsonRoom = try? JSONEncoder().encode(room)
    let json = ["room": jsonRoom]
    socket.emit("clear draw", json)
  }
  
  func clearListener(completion: @escaping () -> Void) {
    socket.on("clear draw") { (data, ack) in
      completion()
    }
  }
  
  func drawListener(completion: @escaping (CGPoint?, CGPoint?) -> Void) {
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
  
  func sendChatMessage(message: String, in room: Room, completion: @escaping (User?) -> Void) {
    let jsonRoom = try! JSONEncoder().encode(room)
    let json = ["room": jsonRoom, "message": message] as [String : Any]
    socket.emitWithAck("chat message", json).timingOut(after: 0) { (data) in
      do {
        let jsonUser = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let user = try JSONDecoder().decode(User.self, from: jsonUser)
        completion(user)
      } catch {
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  func chatListener(completion: @escaping(String) -> Void) {
    socket.on("chat message") { (data, ack) in
      let message = String(describing: data[0])
      completion(message)
    }
  }
  
  func winListener(completion: @escaping(User?) -> Void) {
    socket.on("win") { (data, ack) in
      do {
        let jsonUser = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let user = try JSONDecoder().decode(User.self, from: jsonUser)
        completion(user)
      } catch {
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  func endGameListener(completion: @escaping([User]?) -> Void) {
    socket.on("end game") { (data, ack) in
      do {
        let jsonUsers = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let users = try JSONDecoder().decode([User].self, from: jsonUsers)
        completion(users)
      } catch {
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  func drawingUserDisconnectedListener(completion: @escaping(User?) -> Void) {
    socket.on("drawing user disconnected") { (data, ack) in
      do {
        let jsonUser = try JSONSerialization.data(withJSONObject: data[0], options: .prettyPrinted)
        let user = try JSONDecoder().decode(User.self, from: jsonUser)
        completion(user)
      } catch {
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
}
