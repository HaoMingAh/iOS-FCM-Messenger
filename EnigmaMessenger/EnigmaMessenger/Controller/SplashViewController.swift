//
//  ViewController.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import APAddressBook
import Alamofire
import SwiftyJSON

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadContacts()
        
        if let userId = Defaults[.userid] {
            login(userId)
        } else {
            self.gotoLogin()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContacts() {
        
        let addBook = APAddressBook()
        addBook.loadContacts { (apContacts, error) in
            
            if apContacts != nil {
                
                for one in apContacts! {
                    
                    if let apname = one.name, let apphone = one.phones {
                        
                        if apphone.count > 0 {
                            let name = "\(apname.firstName ?? "") \(apname.lastName ?? "")"
                            let phone = apphone[0].number!.replacingOccurrences(of: " " , with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                            let contact = ContactEntity(name: name, phone:phone)
                            
                            g_contacts.append(contact)
                        }
                    }
                }
                
            }
        }
        
    }
    
    func login(_ userId : Int) {
        
        g_user = UserEntity(id: userId)
        getContacts()
        
    }
    
    func getContacts() {
        
        let URL = Constants.REQ_GETCONTACTS + "\(g_user._id)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                
                if response.result.isFailure {
                    self.gotoLogin()
                    return
                }
                
                if let result = response.result.value  {
                    
                    let dict = JSON(result)
                    
                    let result_code = dict[Constants.RES_CODE].intValue
                    
                    if result_code == Constants.CODE_SUCESS {
                        
                        let contacts = dict[Constants.RES_CONTACTINFOS].arrayValue
                        
                        for one in contacts {
                            let user = UserEntity(dict: one)
                            g_users.append(user)
                        }
                        
                        self.gotoMain()
                        
                    } else {
                        self.gotoLogin()
                    }
                }
                
        }

    }
    
    func gotoLogin() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(vc!, animated: true, completion: nil)
        }
        
    }

    func gotoMain() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNav")
            self.present(vc!, animated: true, completion: nil)
        }
        
    }
}

