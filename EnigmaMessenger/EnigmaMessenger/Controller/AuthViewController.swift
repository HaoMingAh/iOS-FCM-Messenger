//
//  AuthViewController.swift
//  EnigmaMessenger
//
//  Created by JIS on 7/28/17.
//  Copyright © 2017 JIS. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: BaseViewController {

    @IBOutlet weak var ui_imvFinger: UIImageView!
    
    var _toWhere = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ui_imvFinger.image = ui_imvFinger.image!.withRenderingMode(.alwaysTemplate)
        ui_imvFinger.tintColor = UIColor(netHex: Constants.PRIMARY_COLOR)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auth()
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
                    g_authenticated = true

                    if self._toWhere == -1 {
                        
                        DispatchQueue.main.async(execute:  {
                            self.dismiss(animated: true, completion: nil)
                        })
                    } else if self._toWhere == 0 {
                        self.gotoMain()
                    }
                } else {
                    if let error = error {

                        let message = error.localizedDescription
                        self.showAlertDialog(title: R.string.ERROR, message: message, positive: R.string.OK , negative: nil)

                    }
                }
        }
        
        
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
    
    func gotoMain() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNav")
        present(vc!, animated: true, completion: nil)
    }


}
