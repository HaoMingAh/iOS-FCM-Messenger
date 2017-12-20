//
//  ContactEntity.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import Foundation


class ContactEntity : Equatable {
    
    var _name = ""
    var _phoneNumber = ""
    
    
    init(name: String, phone: String) {
        _name = name
        _phoneNumber = phone
    }

        
    static func ==(lhs:ContactEntity, rhs:ContactEntity) -> Bool { // Implement Equatable
        return lhs._phoneNumber.hasSuffix(rhs._phoneNumber) || rhs._phoneNumber.hasSuffix(lhs._phoneNumber)
    }
}
