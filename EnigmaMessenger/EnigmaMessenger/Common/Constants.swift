//
//  Constants.swift
//  Emojily
//
//  Created by JIS on 7/10/16.
//  Copyright © 2016 JIS. All rights reserved.
//

import UIKit

struct Constants {
    
    static let SAVE_ROOT_PATH = "En1gma"
    
    // color
    static let PRIMARY_COLOR = 0x4caf50
    
    
    // web service
    static let BASE_URL = ""
   
    static let REQ_SENDCODE = BASE_URL + "sendCode/";
    static let REQ_REGISTER = BASE_URL + "register/";
    static let REQ_GETCONTACTS = BASE_URL + "getContacts/";
    static let REQ_SAVECONTACTS = BASE_URL + "saveContacts";
    static let REQ_REGISTERTOKEN = BASE_URL + "registerToken/";
    static let REQ_CREATEROOM = BASE_URL + "createRoom/";
    static let REQ_LOADROOMS = BASE_URL + "loadRooms/";
    static let REQ_SENDMESSAGE = BASE_URL + "sendMessage";
    static let REQ_LOADMESSAGES = BASE_URL + "loadMessages/";
    static let REQ_LOADMESSAGESBYUSER = BASE_URL + "loadMessagesByUser/";
    static let REQ_READMESSAGE = BASE_URL + "readMessage/";
    static let REQ_DELETEROOM = BASE_URL + "deleteAllMessages/"
   
   
    static let PARAM_ID = "id";
    static let PARAM_CONTACTS = "contacts";
    static let PARAM_SENDER = "sender";
    static let PARAM_TARGET = "target";
    static let PARAM_MESSAGE = "message";
   
    static let RES_CODE = "result_code";
    static let RES_USERID = "user_id";
    static let RES_PHONENUMBER = "phonenumber";
    static let RES_NAME = "name";
    static let RES_CONTACTINFOS = "contact_infos";
    static let RES_ROOMINFOS = "room_infos";
    static let RES_TARGETID = "target_id";
    static let RES_ROOMNAME = "room_name";
    static let RES_LASTMESSAGE = "last_message";
    static let RES_LASTTIME = "last_time";
    static let RES_UNREAD = "unread";
    static let RES_MESSAGES = "messages";
    static let RES_SENDER = "sender";
    static let RES_MESSAGE = "message";
    static let RES_CREATEDAT = "created_at";

        
    static let CODE_SUCESS = 0
    
    
    static let SLASH = "ssllaasshh"
    

   
}







