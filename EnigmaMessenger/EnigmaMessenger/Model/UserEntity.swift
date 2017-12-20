//
//  UserEntity.swift
//  WowJax
//
//  Created by JIS on 2017/02/23.
//  Copyright © 2017 JIS. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserEntity : Equatable {
    
    var _id = 0
    var _name = ""
    var _phoneNumber = ""

    
    init() {}
    
    init(id:Int) {
        _id = id
    }
    
    init(dict: JSON) {
        
        _id = Int(dict[Constants.RES_USERID].stringValue)!
        _name = dict[Constants.RES_NAME].stringValue
        _phoneNumber = dict[Constants.RES_PHONENUMBER].stringValue
    }
    
    
    static func ==(lhs:UserEntity, rhs:UserEntity) -> Bool { // Implement Equatable
        return lhs._id == rhs._id
    }
    
}
