//
//  ContactsViewController.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Contacts
import ContactsUI
import APAddressBook

class ContactsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate, CNContactViewControllerDelegate{

    @IBOutlet weak var ui_tableView: UITableView!
    @IBOutlet weak var ui_searchbar: UISearchBar!
    
    var _contacts = [UserEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_tableView.keyboardDismissMode = .onDrag
        
        initTopbar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ui_searchbar.text = ""
        _contacts.removeAll()
        _contacts.append(contentsOf:g_users)
        
        loadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
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
        let more = UIBarButtonItem(image:UIImage(named:"icon_plus")!, style:.plain, target:self, action:#selector(didTapMore))
        more.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = more
        
        self.title = "Contacts"
        
        
    }
    

    
    func didTapMore() {
        
        addPhoneNumber(phNo: "")
    }
    
    
    func didTapBack() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadContacts() {
        
        g_contacts.removeAll()
        
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
                
                self.saveContacts()
            }
        }
        
    }

    
    func saveContacts() {
        
        if g_contacts.count == 0 {
            return
        }
        
        var contacts = [Dictionary<String, Any>]()
        for contact in g_contacts {
            let one = ["name" : contact._name, "phoneNumber" :contact._phoneNumber] as [String : Any]
            contacts.append(one)
        }
        
        let data = try! JSONSerialization.data(withJSONObject: contacts, options: [])
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append("\(g_user._id)".data(using:String.Encoding.utf8)!, withName: Constants.PARAM_ID)
                multipartFormData.append(data, withName: Constants.PARAM_CONTACTS)
        },
            to: Constants.REQ_SAVECONTACTS,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let result = response.result.value {
                            
                            let dict = JSON(result)
                            
                            let result_code = dict[Constants.RES_CODE].intValue
                            
                            if result_code == Constants.CODE_SUCESS {
                                
                                let infos = dict[Constants.RES_CONTACTINFOS].arrayValue
                                
                                for info in infos {
                                    
                                    let user = UserEntity(dict:info)
                                    
                                    if !g_users.contains(user) {
                                        g_users.append(user)
                                    }
                                }
                                
                                self.search(self.ui_searchbar.text!)
                                
                            }
                            
                        }
                        
                    }
                    
                case .failure:
                    break
                }
                
        }
        )
        
    }
    
    func search(_ keywords : String) {        
        
        _contacts.removeAll()
        
        if keywords.isEmpty {
            _contacts.append(contentsOf: g_users)
        } else {
            
            for one in g_users {
                
                if one._name.lowercased().contains(keywords.lowercased()) || one._phoneNumber.contains(keywords) {
                    _contacts.append(one)
                }
            }
        }
        
        ui_tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        search(searchText)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        
        if let keywords = searchBar.text {
            
            search(keywords)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func addPhoneNumber(phNo : String) {

        let store = CNContactStore()
        let contact = CNMutableContact()
        let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :phNo ))
        contact.phoneNumbers = [homePhone]
        let controller = CNContactViewController(forUnknownContact : contact)// .viewControllerForUnknownContact(contact)
        controller.contactStore = store
        controller.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _contacts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
        cell.selectionStyle = .none
        
        let user = _contacts[indexPath.row]
        cell.entity = user
        
        cell.ui_btnCall.tag = indexPath.row
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = _contacts[indexPath.row]
        
        let vc = ChatViewController()
        vc._target = user
        vc.senderDisplayName = user._name
        
        self.navigationController?.pushViewController(vc, animated: true)

    }

    @IBAction func onCall(_ sender: UIButton) {
        
        let phone = _contacts[sender.tag]._phoneNumber
        
        guard let number = URL(string: "tel://" + phone) else { return }
        UIApplication.shared.open(number)
        
    }
    

}
