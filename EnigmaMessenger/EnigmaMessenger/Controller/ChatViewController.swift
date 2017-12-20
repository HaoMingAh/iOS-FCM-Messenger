/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Photos
import Firebase
import JSQMessagesViewController
import IQKeyboardManagerSwift
import Alamofire
import SwiftyJSON


final class ChatViewController: JSQMessagesViewController {
  
  // MARK: Properties
  private let imageURLNotSetKey = "NOTSET"

  
  private var _messages: [JSQMessage] = []
  private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    var _target:UserEntity!
    var _roomName = ""
  
  lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
  lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var upperRefreshControl = UIRefreshControl()
  
  // MARK: View Lifecycle
  
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.senderId = String(g_user._id)
        
        initTopbar()
        
        self.collectionView.showsVerticalScrollIndicator = false
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width : 0, height: 0)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width : 0, height: 0)
        collectionView!.collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        upperRefreshControl.addTarget(self, action: #selector(loadMore(_:)), for: .valueChanged)
        collectionView!.addSubview(upperRefreshControl)
        
        _roomName = makeRoomName()
        
        enterRoom()
        
        self.loadMessages(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        g_currentVC = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setRead()
        
    }
    
    func initTopbar() {
        
        let color = UIColor(netHex: Constants.PRIMARY_COLOR)
        
        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let back = UIBarButtonItem(image:UIImage(named:"btn_back")!, style:.plain, target:self, action:#selector(didTapBack))
        back.tintColor = UIColor.white
        let more = UIBarButtonItem(image:UIImage(named:"icon_phone_white")!, style:.plain, target:self, action:#selector(didTapPhone))
        more.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = more
        
        self.title = _target._name

        
    }

    func enterRoom() {
        
        let URL = Constants.REQ_CREATEROOM + "\(g_user._id)/\(_target._id)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
        
        }
        
    }
    
    func loadMessages(_ isLoadMore : Bool) {
        
        var skip = 0
        
        if isLoadMore {
            skip = self._messages.count
        }
        
        let URL = Constants.REQ_LOADMESSAGESBYUSER + "\(_roomName)/\(g_user._id)/\(skip)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                if isLoadMore {
                    self.stopRefreshing()
                }
                
                if response.result.isFailure {
                    return
                }
                
                if let result = response.result.value  {
                    
                    let dict = JSON(result)
                    
                    let result_code = dict[Constants.RES_CODE].intValue
                    
                    if result_code == Constants.CODE_SUCESS {
                        
                        let infos = dict[Constants.RES_MESSAGES].arrayValue
                        
                        for info in infos {
                            
                            let sender = Int(info[Constants.RES_SENDER].stringValue)!
                            let text = info[Constants.RES_MESSAGE].stringValue
                            let time = info[Constants.RES_CREATEDAT].stringValue
                            //let status = Int(info[Constants.RES_STATUS].stringValue)!
                            
                            var senderName = ""
                            
                            if sender != g_user._id {
                                senderName = self._target._name
                            }
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            formatter.timeZone = TimeZone(identifier:"UTC")
                            let date = formatter.date(from: time)!
                            
                            if let msg = JSQMessage(senderId: "\(sender)", senderDisplayName: senderName, date : date, text: text.decodeEmoji) {
                                self._messages.insert(msg, at:0)
                            }

                        }
                        
                        
                        if isLoadMore {
                            
                            let bottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                            self.collectionView.reloadData()
                            self.view.layoutIfNeeded()
                            self.collectionView.contentOffset = CGPoint(x:0, y:self.collectionView.contentSize.height - bottomOffset)

                        } else {
                            self.finishReceivingMessage()
                        }
                        
                    }
                }
                
        }
    }
    
    func loadMore(_ sender : UIRefreshControl) {
        
        loadMessages(true)
    }
    
    func stopRefreshing() {
        
        if upperRefreshControl.isRefreshing {
            upperRefreshControl.endRefreshing()
        }
    }
    
    func sendMessage(text:String) {
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append("\(g_user._id)".data(using:String.Encoding.utf8)!, withName: "sender")
                multipartFormData.append("\(self._target._id)".data(using:String.Encoding.utf8)!, withName: "target")
                multipartFormData.append(text.encodeEmoji.data(using:String.Encoding.utf8)!, withName: "message")
                
        },
            to: Constants.REQ_SENDMESSAGE,
            encodingCompletion: { encodingResult in
                
                
            }
        )

    }
    
    func setRead() {
        
        let URL = Constants.REQ_READMESSAGE + "\(_roomName)/\(g_user._id)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
        }
        
        
    }
    
    func didTapBack() {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func didTapPhone() {
        
        let phone = _target._phoneNumber
        
        guard let number = URL(string: "tel://" + phone) else { return }
        UIApplication.shared.open(number)
    }
    
    
    func onBack(_ sender:UIButton) {
        
        dismiss(animated:true)
    }
  
  // MARK: Collection view data source (and related) methods
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    
    return _messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return _messages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    
    let message = _messages[indexPath.item] // 1
    
    if message.senderId == senderId { // 2
        return outgoingBubbleImageView
    } else { // 3
        return incomingBubbleImageView
    }
  }

  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = _messages[indexPath.item]
    
    
    if message.senderId == self.senderId { // 1
        
        cell.textView?.textColor = UIColor.white// 2
        cell.cellBottomLabel.text = getTimeString(date: message.date)
        cell.cellBottomLabel.textColor = UIColor.gray
        
    } else {
        cell.textView?.textColor = UIColor.black // 3
        cell.cellBottomLabel.text = getTimeString(date: message.date)
        cell.cellBottomLabel.textColor = UIColor.gray
    }
    
    return cell
  }
  
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return 0
  }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        return 24

    }
  
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {

        let message = _messages[indexPath.item]
        
        if indexPath.item == 0 {
            return 24
        }
        
        if indexPath.item - 1 > 0 {
            
            let prevMessage = self._messages[indexPath.item - 1]
            
            if getDayString(date: message.date) != getDayString(date: prevMessage.date) {
                return 24
            }
        }
        
        return 0
    }
    
      override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        
        let message = _messages[indexPath.item]
     
        if indexPath.item == 0 {
            
            let attribute = NSAttributedString(string: getDayString(date: message.date))
            return attribute
        }
        
        if indexPath.item - 1 > 0 {
            
            let prevMessage = self._messages[indexPath.item - 1]
            
            if getDayString(date: message.date) != getDayString(date: prevMessage.date) {
                let attribute = NSAttributedString(string: getDayString(date: message.date))
                return attribute
            }
        }
        
        return nil
    }
    
  override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
//    let message = messages[indexPath.item]
//    switch message.senderId {
//    case senderId:
//      return nil
//    default:
//      guard let senderDisplayName = message.senderDisplayName else {
//        assertionFailure()
//        return nil
//      }
//      return NSAttributedString(string: senderDisplayName)
//    }
    
    return nil
  }

  
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
    
    self.addMessage(withId: senderId, name: senderDisplayName, date: Date(), text: text)
    
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    
    sendMessage(text: text)
    
    finishSendingMessage()
    
    
    // updateUserChannel(msg: text)
    // isTyping = false
  }
  
  func sendPhotoMessage() {

    
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    
    finishSendingMessage()

  }
  
  func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
    
    
  }
    
    func onReceiveMessage(message:String) {
        
        self.addMessage(withId: "\(_target._id)", name: "\(_target._name)", text: message)
        self.finishReceivingMessage()
        
    }
  
  // MARK: UI and User Interaction
  
  private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(netHex:Constants.PRIMARY_COLOR))
  }

  private func setupIncomingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    
    let color = UIColor(netHex:0xf88905)
    return bubbleImageFactory!.incomingMessagesBubbleImage(with: color)
  }

  override func didPressAccessoryButton(_ sender: UIButton) {
    
    
  }
  
  private func addMessage(withId id: String, name: String, text: String) {
    if let message = JSQMessage(senderId: id, displayName: name, text: text.decodeEmoji) {
      _messages.append(message)
    }
  }
    
    private func addMessage(withId id: String, name: String, date: Date, text: String) {
        
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text.decodeEmoji) {
            _messages.append(message)
        }
    }
  
  private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
    if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
      _messages.append(message)
      
      if (mediaItem.image == nil) {
        photoMessageMap[key] = mediaItem
      }
      
      collectionView.reloadData()
    }
  }
  
  // MARK: UITextViewDelegate methods
  
  override func textViewDidChange(_ textView: UITextView) {
    super.textViewDidChange(textView)
    // If the text is not empty, the user is typing
//    isTyping = textView.text != ""
  }
  
    func makeRoomName() -> String {
        
        if g_user._id < _target._id {
            return "\(g_user._id)_\(_target._id)"
        }
        
        return "\(_target._id)_\(g_user._id)"
    }
    
    func getTimeString(date : Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: date)
        
        return dateString
    }

    func getDayString(date : Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let dateString = formatter.string(from: date)
        
        return dateString
    }
}


