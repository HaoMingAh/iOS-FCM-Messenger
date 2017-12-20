//
//  ProgresHUD.swift
//  SmarterApp
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProgressHUD: NSObject {

    class func initHUD() {
        
        // background and foregroud color will be applied on custom style.
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 14))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    }
    
    class func show() {
        
        SVProgressHUD.show()
    }
    
    //成功
    class func showSuccessWithStatus(string: String) {
        self.ProgressHUDShow(type: .Success, status: string)
    }
    
    //失败 ，NSError
    class func showErrorWithObject(error: NSError) {
        self.ProgressHUDShow(type: .ErrorObject, status: nil, error: error)
    }
    
    //失败，String
    class func showErrorWithStatus(string: String) {
        self.ProgressHUDShow(type: .ErrorString, status: string)
    }
    
    //转菊花
    class func showWithStatus(string: String) {
        self.ProgressHUDShow(type: .Loading, status: string)
    }
    
    //警告
    class func showWarningWithStatus(string: String) {
        self.ProgressHUDShow(type: .Info, status: string)
    }
    
    //dismiss消失
    class func dismiss() {
        SVProgressHUD.dismiss()
    }
    
    //私有方法
    private class func ProgressHUDShow(type: HUDType, status: String? = nil, error: NSError? = nil) {
        switch type {
        case .Success:
            SVProgressHUD.showSuccess(withStatus: status)
            break
        case .ErrorObject:
            guard let newError = error else {
                SVProgressHUD.showError(withStatus: "Error")
                return
            }
            
            if newError.localizedFailureReason == nil {
                SVProgressHUD.showError(withStatus: "Error")
            } else {
                SVProgressHUD.showError(withStatus: error!.localizedFailureReason)
            }
            break
        case .ErrorString:
            SVProgressHUD.showError(withStatus: status)
            break
        case .Info:
            SVProgressHUD.showInfo(withStatus: status)
            break
        case .Loading:
            SVProgressHUD.show(withStatus: status)
            break
        }
    }
    
    private enum HUDType: Int {
        case Success, ErrorObject, ErrorString, Info, Loading
    }
}
