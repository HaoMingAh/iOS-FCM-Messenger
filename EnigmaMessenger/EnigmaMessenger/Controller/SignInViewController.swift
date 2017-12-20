//
//  SignInViewController.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/18/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit
import Material
import libPhoneNumber_iOS
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import LocalAuthentication

class SignInViewController: BaseViewController,  CountryPhoneCodePickerDelegate, UITextFieldDelegate{

    @IBOutlet weak var ui_imvCountry: UIImageView!
    @IBOutlet weak var ui_countryPicker: CountryPicker!
    @IBOutlet weak var ui_txvPhone: TextField!
    @IBOutlet weak var ui_txvCode: TextField!
    @IBOutlet weak var ui_btnContinue: FlatButton!
    @IBOutlet weak var ui_btnSend: FlatButton!
    
    var _countryCode = "US"
    var _phonenumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.handleTapView(_:)))
        self.view.addGestureRecognizer(tapper)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initUI() {
        
        let locale = Locale.current
        if let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
            _countryCode = code
        }
        
        ui_countryPicker.countryPhoneCodeDelegate = self
        ui_countryPicker.setCountry(_countryCode)
        
        ui_imvCountry.image = UIImage(named:_countryCode.lowercased())
        
        _ = ui_txvPhone.becomeFirstResponder()
        ui_countryPicker.isHidden = true

        
        let textFields : [TextField] = [ui_txvPhone, ui_txvCode];
        
        for textField in textFields {
            
            textField.placeholderNormalColor = Color(netHex: Constants.PRIMARY_COLOR)
            textField.placeholderActiveColor = Color(netHex: Constants.PRIMARY_COLOR)
            textField.dividerNormalColor = Color(netHex: Constants.PRIMARY_COLOR)
            textField.dividerActiveColor = Color(netHex: Constants.PRIMARY_COLOR)
        }
        
        ui_txvCode.isHidden = true
        ui_btnContinue.isHidden = true
        
    }
    

    func checkValid() -> Bool {
        
        if let phonenumber = ui_txvPhone.text {
            
            if phonenumber.isEmpty {
                showToast(message: R.string.INPUT_PHONE)
                return false
            }
            
            let phoneNumberUtil = NBPhoneNumberUtil.init()
            
            do {
                let phone = try phoneNumberUtil.parse(phonenumber, defaultRegion: _countryCode)
                
                if phoneNumberUtil.isValidNumber(phone) {
                    
                    self._phonenumber = try phoneNumberUtil.format(phone, numberFormat: .E164)
                    return true
                }
                
            } catch { }
            
            showToast(message: R.string.INPUT_PHONE)
            return false
        }
        
        return false
    }
    
    func sendCode() {
        
        ui_txvPhone.resignFirstResponder()
        showLoadingView()
        
        let URL = Constants.REQ_SENDCODE + _phonenumber.encodeString()!
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                self.hideLoadingView()
                
                if response.result.isFailure {
                    self.showToast(message: R.string.CONNECT_FAIL)
                    return
                }
                
                if let result = response.result.value  {
                    
                    let dict = JSON(result)
                    
                    let result_code = dict[Constants.RES_CODE].intValue
                    
                    if result_code == Constants.CODE_SUCESS {
                        
                        self.ui_btnSend.setTitle(R.string.RESEND, for: .normal)
                        self.ui_txvCode.isHidden = false
                        _ = self.ui_txvCode.becomeFirstResponder()
                        self.ui_btnContinue.isHidden = false

                    } else {
                        self.showToast(message: R.string.CONNECT_FAIL)
                    }
                }
                
        }

    }
    
    func register() {

        showLoadingView()
        
        let URL = Constants.REQ_REGISTER + _phonenumber.encodeString()! + "/\(ui_txvCode.text!)/1"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                
                if response.result.isFailure {
                    self.hideLoadingView()

                    self.showToast(message: R.string.CONNECT_FAIL)
                    return
                }
                
                if let result = response.result.value  {
                    
                    let dict = JSON(result)
                    
                    let result_code = dict[Constants.RES_CODE].intValue
                    
                    if result_code == Constants.CODE_SUCESS {
                        
                        let userId = dict[Constants.RES_USERID].intValue
                        g_user = UserEntity(id: userId)
                        Defaults[.userid] = userId
                        self.getContacts()
                    
                    } else if result_code == 101 {
                        self.hideLoadingView()
                        self.showToast(message: R.string.USER_NOTEXIST)
                    } else if result_code == 102 {
                        self.hideLoadingView()
                        self.showToast(message: R.string.INPUT_CODE)
                    } else if result_code == 200 {
                        
                        let userId = dict[Constants.RES_USERID].intValue
                        g_user = UserEntity(id:userId)
                        Defaults[.userid] = userId
                        self.saveContacts()
                    } else {
                        self.hideLoadingView()
                        self.showToast(message: R.string.CONNECT_FAIL)
                    }
                }
                
        }

    }
    
    func getContacts() {
        
        let URL = Constants.REQ_GETCONTACTS + "\(g_user._id)"
        
        Alamofire.request(URL, method:.get)
            .responseJSON { response in
                
                
                if response.result.isFailure {
                    self.onSuccess()
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
                    }
                    
                    self.onSuccess()
                }
                
        }
        

    }
    
    func saveContacts() {
        
        if g_contacts.count == 0 {
            onSuccess()
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
                                
                                self.onSuccess()

                            } else {
                                self.hideLoadingView()
                                self.showToast(message: R.string.CONNECT_FAIL)
                            }
                            
                        }
                        
                    }
                    
                case .failure:
                    self.showToast(message: R.string.CONNECT_FAIL)
                    self.hideLoadingView()
                }
                
        }
        )
    
    }
    
    func onSuccess() {
        
        sendTokenToServer()
    }
    
    func sendTokenToServer() {
        
        if let token = Defaults[.token] {
            
            let URL = Constants.REQ_REGISTERTOKEN + "\(g_user._id)/\(token)"
            
            Alamofire.request(URL, method:.get)
                .responseJSON { response in
                    
                    self.gotoAuth()
                    
            }
        } else {
            self.gotoAuth()
        }
        
    }
    
    func gotoAuth() {
        
        hideLoadingView()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        vc._toWhere = 0
        present(vc, animated: true, completion: nil)
    }
    
    
    func gotoMain() {
        
        hideLoadingView()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNav")
        present(vc!, animated: true, completion: nil)
    }
    
    func handleTapView(_ sender:UITapGestureRecognizer) {
        
        self.view.endEditing(true)
        ui_countryPicker.isHidden = true
    }
    
    @IBAction func onCountry(_ sender: Any) {
        
        ui_countryPicker.isHidden = false
        ui_txvPhone.resignFirstResponder()
    }
    
    
    @IBAction func onSendCode(_ sender: Any) {
        
        if checkValid() {
            
            ui_countryPicker.isHidden = true
            sendCode()
        }
    }
    
    @IBAction func onContinue(_ sender: Any) {
        
        ui_txvCode.resignFirstResponder()
       
        if ui_txvCode.text?.characters.count != 6 {
            showToast(message: R.string.INPUT_CODE)
            return
        }
        
        register()
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        ui_countryPicker.isHidden = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 20
    }
    
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String) {
        
        ui_imvCountry.image = UIImage(named:countryCode.lowercased())
        _countryCode = countryCode
    }

}
