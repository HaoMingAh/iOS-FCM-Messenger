//
//  ContactsCell.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    @IBOutlet weak var ui_lblName: UILabel!
    @IBOutlet weak var ui_lblPhone: UILabel!
    @IBOutlet weak var ui_btnCall: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var entity : UserEntity! {
        
        didSet {
            
            ui_lblName.text = entity._name
            ui_lblPhone.text = entity._phoneNumber
        }
    }

}
