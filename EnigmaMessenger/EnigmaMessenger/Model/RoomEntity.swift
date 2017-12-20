//
//  File.swift
//  WowJax
//
//  Created by JIS on 2017/02/23.
//  Copyright © 2017 JIS. All rights reserved.
//

import Foundation
import SwiftyJSON

class RoomEntity : Equatable{
    
    var _name = ""
    var _targetId = 0
    var _lastMessage = ""
    var _lastTime = ""
    var _unRead = 0
    var _phonenumber = ""
    var _displayName = ""
    
    init() {
        
        
    }
    
    init(dict: JSON) {
        
        _targetId = Int(dict[Constants.RES_TARGETID].stringValue)!
        _name = dict[Constants.RES_ROOMNAME].stringValue
        _lastMessage = dict[Constants.RES_LASTMESSAGE].stringValue.decodeEmoji
        _lastTime = dict[Constants.RES_LASTTIME].stringValue
        _unRead = Int(dict[Constants.RES_UNREAD].stringValue)!
        _phonenumber = dict[Constants.RES_PHONENUMBER].stringValue
        
        if let find = g_users.index(of: UserEntity(id:_targetId)) {
            _displayName = g_users[find]._name
        } else {
            
            if let find2 = g_contacts.index(of: ContactEntity(name: "", phone: _phonenumber)) {
                _displayName = g_contacts[find2]._name
            } else {
                _displayName = _phonenumber
            }
        }
    }
    
    func getTimeAgo() -> String {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier:"UTC")
        let date = formatter.date(from: _lastTime)
        
        if date != nil {
            let ago = date!.timeAgo
            return ago
        }
        
        return ""
    }
    
    
    static func ==(lhs:RoomEntity, rhs:RoomEntity) -> Bool { // Implement Equatable
        return lhs._name == rhs._name
    }
    
}
