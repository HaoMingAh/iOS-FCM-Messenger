//
//  MainViewController.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import LocalAuthentication

var g_allRooms = [RoomEntity]()

class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var ui_tableView: UITableView!
    @IBOutlet weak var ui_searchbar: UISearchBar!
    
    var _isFirstLoading = true
    
    var _rooms = [RoomEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_tableView.keyboardDismissMode = .onDrag
        
        loadRooms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initTopbar()
        
        ui_searchbar.text = ""
        
        _rooms.removeAll()
        _rooms.append(contentsOf: g_allRooms)
        ui_tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if !_isFirstLoading {
            loadRooms()
        }
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
        
        let more = UIBarButtonItem(image:UIImage(named:"icon_edit")!, style:.plain, target:self, action:#selector(didTapMore))
        more.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = more
        
        self.title = "Messages"
        
        
    }
    
    func loadRooms() {
        
        let URL = Constants.REQ_LOADROOMS + "\(g_user._id)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                self._isFirstLoading = false
                
                if response.result.isFailure {
                    return
                }
                
                if let result = response.result.value  {
                    
                    g_allRooms.removeAll()
                    
                    let dict = JSON(result)
                    
                    let result_code = dict[Constants.RES_CODE].intValue
                    
                    if result_code == Constants.CODE_SUCESS {
                        
                        let rooms = dict[Constants.RES_ROOMINFOS].arrayValue
                        
                        for one in rooms {
                            
                            let room = RoomEntity(dict: one)
                            
                            if !room._lastMessage.isEmpty && !g_allRooms.contains(room){
                                g_allRooms.append(room)
                            }
                        }
                        
                        g_allRooms.sort(by:self.compareRoom)
                        
                        if let keywords = self.ui_searchbar.text {
                            self.search(keywords)
                        } else {
                            self._rooms.append(contentsOf: g_allRooms)
                            self.ui_tableView.reloadData()
                        }
                    }
                    
                }
                
        }
    }
    
    func deleteRoom(_ room : RoomEntity) {
        
        
        let URL = Constants.REQ_DELETEROOM + "\(room._name)/\(g_user._id)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                
                
        }

    }
    
    func search(_ keywords : String) {
        
        _rooms.removeAll()
        
        if keywords.isEmpty {
            _rooms.append(contentsOf: g_allRooms)
        } else {
            
            for one in g_allRooms {
                
                if one._displayName.lowercased().contains(keywords.lowercased()) {
                    _rooms.append(one)
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
    

    func didTapMore() {
        
        if g_authenticated {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
            
        } else {
         
            auth()
        }
    }
    

    
    func auth() {
        
        let authenticationContext = LAContext()
        var error:NSError?
        
        // 2. Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            
            self.showSettingAlert()
            return
            
        }
        
        authenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: R.string.VERIFY) { (success, evaluateError) in
            if (success) {
                
                self.onSuccessAuth()
                
            } else {
                if let error = error {
                    
                    let message = error.localizedDescription
                    self.showAlertDialog(title: R.string.ERROR, message: message, positive: R.string.OK , negative: R.string.CANCEL)
                    
                }
            }
        }
        
        
    }
    
    func onSuccessAuth() {
        
        g_authenticated = true
        DispatchQueue.main.async(execute:  {
            self.ui_tableView.reloadData()
        })
    }
    
    func showSettingAlert() {
        
        let alert = UIAlertController(title: R.string.ERROR, message: R.string.FINGER_NOTAVAILABLE, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: R.string.SETTING, style: .default, handler: { action in
            
            g_isAuthNeeded = true
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        DispatchQueue.main.async(execute:  {
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _rooms.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomCell
        cell.selectionStyle = .none
        
        let room = _rooms[indexPath.row]
        cell.entity = room
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !g_authenticated {
            auth()
            return
        }
        
        let room = _rooms[indexPath.row]
        
        let id1 = Int(room._name.components(separatedBy:"_")[0])!
        let id2 = Int(room._name.components(separatedBy:"_")[1])!
        
        var targetId = id1
        if targetId == g_user._id {
            targetId = id2
        }
        
        var user = UserEntity(id: targetId)
        user._phoneNumber = room._phonenumber
        user._name = room._displayName
        
        if let find = g_users.index(of: user) {
            user = g_users[find]
        }
        
        let vc = ChatViewController()
        vc._target = user
        vc.senderDisplayName = user._name
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            if g_authenticated {
                deleteRoom(_rooms[indexPath.row])
                _rooms.remove(at:indexPath.row)
                ui_tableView.reloadData()
            } else {
                auth()
            }
        }
    }
    
    func compareRoom(this:RoomEntity, that:RoomEntity) -> Bool {
        
        let result = this._lastTime.compare(that._lastTime)
        
        if result == ComparisonResult.orderedDescending {
            return true
        }
        
        return false
    }
    

}
