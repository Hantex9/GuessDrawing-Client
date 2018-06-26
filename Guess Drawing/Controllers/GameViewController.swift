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
  @IBOutlet weak var clearButton: UIButton! {
    didSet{
      clearButton.translatesAutoresizingMaskIntoConstraints = false
      clearButton.layer.cornerRadius = 5
      clearButton.layer.shadowColor = UIColor.black.cgColor
      clearButton.layer.shadowRadius = 1.5
      clearButton.layer.shadowOpacity = 0.5
      clearButton.layer.shadowOffset = CGSize(width: 0, height: 2)
      clearButton.layer.masksToBounds = false
      let rect = clearButton.bounds.insetBy(dx: -1, dy: -1)
      clearButton.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
  @IBOutlet weak var closeButton: UIButton! {
    didSet{
      closeButton.layer.cornerRadius = 5
      closeButton.layer.shadowColor = UIColor.black.cgColor
      closeButton.layer.shadowRadius = 1.5
      closeButton.layer.shadowOpacity = 0.5
      closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
      closeButton.layer.masksToBounds = false
      let rect = closeButton.bounds.insetBy(dx: -1, dy: -1)
      closeButton.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
  @IBOutlet weak var chatView: ChatView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var roundLabel: UILabel!
  @IBOutlet weak var chatTopConstraint: NSLayoutConstraint!
  
  fileprivate let matchInfoView = MatchInfoView()
  
  fileprivate let serverManager = ServerManager.shared
  fileprivate let dataManager = DataManager.shared
  
  fileprivate var playerRoom: Room? {
    get {
      let index = dataManager.rooms.lastIndex { $0.id == dataManager.joinedRoom }
      guard let indexRoom = index else { return nil }
      guard indexRoom < dataManager.rooms.count else { return nil }
      return dataManager.rooms[indexRoom]
    }
    set {
      let index = dataManager.rooms.lastIndex { $0.id == dataManager.joinedRoom }
      guard let indexRoom = index else { return }
      guard let newValue = newValue else { return }
      dataManager.rooms[indexRoom] = newValue
    }
  }
  
  fileprivate var roomInstance: Room? = nil
  fileprivate var oldWinningWord: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Notification for the Keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    tapGesture.cancelsTouchesInView = true
    view.addGestureRecognizer(tapGesture)

    drawView.clipsToBounds = true
    drawView.isMultipleTouchEnabled = false
    drawView.delegate = self
    
    chatView.tableView.delegate = self
    chatView.tableView.dataSource = self
    chatView.setup()
    
    self.roomInstance = playerRoom
    
    NSLayoutConstraint.activate([
      clearButton.bottomAnchor.constraint(equalTo: chatView.topAnchor, constant: -40.0),
      clearButton.trailingAnchor.constraint(equalTo: chatView.trailingAnchor, constant: -15),
      clearButton.widthAnchor.constraint(equalToConstant: 100),
      clearButton.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    setupObservers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateChatView()
  }
  
  @objc fileprivate func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.view.frame.origin.y -= keyboardSize.height
//      scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
//      scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
    } else {
      self.view.frame.origin.y -= 40
    }
  }
  
  @objc fileprivate func keyboardWillHide(notification: NSNotification) {
      self.view.frame.origin.y = 0
//    scrollView.contentInset = UIEdgeInsets.zero
//    scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
  }
  
  @objc func tapHandler(_ sender: UITapGestureRecognizer) {
    self.chatView.messageTextField.resignFirstResponder()
  }
  
  fileprivate func updateChatView() {
    guard let playerRoom = playerRoom else { return print("NO PLAYERROOOOM") }
    scoreLabel.text = "Score\n\(dataManager.user.score)"
    scoreLabel.sizeToFit()
    
    oldWinningWord = playerRoom.winningWord!
    
    roundLabel.text = "Round\n\(playerRoom.round!)/\(playerRoom.maxRound!)"
    
    if let userTurn = playerRoom.userTurn {
      drawView.isUserInteractionEnabled = userTurn.id == dataManager.user.id
      chatView.messageTextField.isEnabled = !(userTurn.id == dataManager.user.id)
      chatView.sendButton.isEnabled = !(userTurn.id == dataManager.user.id)
      clearButton.isHidden = !(userTurn.id == dataManager.user.id)
      
      if let winningWord = playerRoom.winningWord {
        let word = (userTurn.id == dataManager.user.id) ? winningWord : winningWord.replaceWithUnderscores()
        chatView.winningWord.setTitle(word.uppercased(), for: .normal)
      }
    }
  }
  
  fileprivate func setupObservers() {
    
    serverManager.roomsListener { (rooms) in // TODO
      guard let rooms = rooms else { return }
      self.dataManager.rooms = rooms
      
      if let _ = self.playerRoom, let _ = self.playerRoom?.connectedUsers {
        self.playerRoom!.connectedUsers!.sort { $0.score > $1.score }
      } else { return }

      
      DispatchQueue.main.async {
        self.chatView.tableView.reloadData()
      }
    }
    
    serverManager.drawListener { (lastPoint, newPoint) in
      guard let lastPoint = lastPoint, let newPoint = newPoint else { return }
      
      self.drawView.touchesReceived(lastPoint: lastPoint, newPoint: newPoint)
    }
    
    serverManager.clearListener {
      self.drawView.clear()
    }
    
    serverManager.chatListener { (newMessage) in
      self.chatView.chatTextView.text += "\(newMessage)\n"
    }
    
    serverManager.winListener { (winner) in
      guard let winner = winner else { return }
      guard let playerRoom = self.playerRoom else { return }
      let message = "\(winner.name) guess the word!\n\nDrawing Turn:\n" + playerRoom.userTurn!.name
      print(playerRoom.round!)
      self.setupNextRound(title: "NEXT ROUND!", message: message)
    }
    
    serverManager.endGameListener { (rankingUsers) in
      print("HO CHIAMATO L'END GAME LISTENER, DOVREBBE CHIAMARLO 1 VOLTE SOLE")
      guard var users = rankingUsers else { return }
      users.sort { $0.score > $1.score }
      
      self.view.addSubview(self.matchInfoView)
      self.matchInfoView.frame = self.view.frame
      self.matchInfoView.titleLabel.text = "GAME IS OVER"
      self.matchInfoView.descriptionLabel.text = "WINNER:\n\n\(users.first!.name)\n\(users.first!.score) points"
      
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5, execute: {
        self.serverManager.exitRoom(room: self.roomInstance!, completion: {
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let vc = storyboard.instantiateViewController(withIdentifier: "RoomsView")
          
          let transition = CATransition()
          transition.duration = 0.3
          transition.type = CATransitionType.fade
          self.navigationController?.view.layer.add(transition, forKey:nil)
          
          self.navigationController?.pushViewController(vc, animated: false)
          self.navigationController?.viewControllers = [vc]
        })
      })
    }
    
    serverManager.drawingUserDisconnectedListener { (user) in
      guard let user = user else { return }
      guard var playerRoom = self.playerRoom else { return }
      print("THE USER \(user.name) disconnected while was drawing")
      playerRoom.connectedUsers!.removeAll { $0.id == user.id }
      if playerRoom.connectedUsers!.count >= 2 {
        let message = "Drawing Turn:\n\(playerRoom.connectedUsers![(playerRoom.round!) % playerRoom.connectedUsers!.count].name)"
        self.setupNextRound(title: "DRAWING USER DISCONNECTED", message: message)
      } else {
        print("show endgame view")
      }
      
    }
  }
  
  fileprivate func setupNextRound(title: String, message: String) {
    self.view.endEditing(true)
    drawView.isUserInteractionEnabled = false
    chatView.winningWord.setTitle(oldWinningWord.uppercased(), for: .normal)
    chatView.messageTextField.isEnabled = false
    chatView.sendButton.isEnabled = false
    
    self.drawView.addSubview(matchInfoView)
    matchInfoView.frame = self.view.frame
    matchInfoView.titleLabel.text = title
    matchInfoView.descriptionLabel.text = message
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5, execute: {
      self.drawView.clear()
      self.updateChatView()
      self.matchInfoView.removeFromSuperview()
    })
  }
  
  // - MARK: Actions
  
  @IBAction func clearButtonPressed(_ sender: UIButton) {
    guard let playerRoom = playerRoom else { return }
    guard let userTurn = playerRoom.userTurn, userTurn.id == dataManager.user.id else { return }
    drawView.clear()
    serverManager.clearDraw(in: playerRoom)
  }
  
  @IBAction func sendButtonPressed(_ sender: UIButton) {
    guard let playerRoom = playerRoom else { return }
    guard let message = chatView.messageTextField.text, !message.isEmpty else { return }
    chatView.messageTextField.text = ""
    
    serverManager.sendChatMessage(message: message, in: playerRoom) { user in
      guard let user = user else { return }
      self.dataManager.user = user
    }
  }
  
  @IBAction func exitButtonPressed(_ sender: UIButton) {
    let alert = UIAlertController(title: "Exit", message: "Are you sure that you want exit? You will lose your score", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "closeAlert"), style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: "exitAlert"), style: .cancel) { _ in
      self.serverManager.exitRoom(room: self.roomInstance!, completion: {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RoomsView")
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.navigationController?.view.layer.add(transition, forKey:nil)
        
        self.navigationController?.pushViewController(vc, animated: false)
        self.navigationController?.viewControllers = [vc]
      })

    })
    
    self.present(alert, animated: true)
  }
  
  
}

extension GameViewController: DrawViewDelegate {
  func shouldDraw(lastPoint: CGPoint, newPoint: CGPoint) {
    guard let playerRoom = playerRoom else { return }
    serverManager.sendDrawing(in: playerRoom, lastPoint: lastPoint, newPoint: newPoint)
  }
  
}

extension GameViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let playerRoom = playerRoom else { return 0 }
    return playerRoom.connectedUsers!.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell") as! RankingTableViewCell
    guard let playerRoom = playerRoom else { return cell }
    guard let user = playerRoom.connectedUsers?[indexPath.row] else { return cell }
    
    cell.usernameLabel.text = user.name
    cell.usernameLabel.sizeToFit()
    cell.scoreLabel.text = "\(user.score)"
    cell.scoreLabel.sizeToFit()
    
    return cell
  }
  
  
}
