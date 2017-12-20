//
//  MessageCell.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {

    @IBOutlet weak var ui_lblMessage: UILabel!
    @IBOutlet weak var ui_lblName: UILabel!
    @IBOutlet weak var ui_lblTime: UILabel!
    @IBOutlet weak var ui_unread: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var entity : RoomEntity! {
        
        didSet {
            
            if g_authenticated {
                ui_lblName.text = entity._displayName
                ui_lblMessage.text = entity._lastMessage
            } else {
                ui_lblName.text = getRectString(len: entity._displayName.characters.count)
                ui_lblMessage.text = getCircleString(len: entity._lastMessage.characters.count)
            }
            
            ui_lblTime.text = entity.getTimeAgo()
            
            
            if entity._unRead > 0 {
                ui_unread.isHidden = false
            } else {
                ui_unread.isHidden = true
            }
            
        }
    }
    
    func getRectString(len : Int) -> String {
        
        var ret = ""
        for _ in 0..<len {
            ret += "□"
        }
        
        return ret
    }
    
    func getCircleString(len : Int) -> String {
        
        var ret = ""
        for _ in 0..<len {
            ret += "○"
        }
        
        return ret
    }

}
