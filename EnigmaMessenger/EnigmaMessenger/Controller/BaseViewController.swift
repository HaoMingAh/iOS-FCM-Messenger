//
//  BaseViewController.swift
//  WowJax
//
//  Created by JIS on 7/7/16.
//  Copyright © 2016 JIS. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
import CRToast
import SwiftyUserDefaults

var g_currentVC : UIViewController?


class BaseViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        g_currentVC = self
    }

    
    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        DispatchQueue.main.async(execute:  {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    
    func showLoadingView() {
        
        showLoadingViewWithTitle(title: "")
    }
    
    
    func showLoadingViewWithTitle(title: String) {
        
        if title == "" {
            
            ProgressHUD.show()
            
        } else {
            
            ProgressHUD.showWithStatus(string: title)
        }
    }
    
    // hide loading view
    func hideLoadingView() {
        
        ProgressHUD.dismiss()
    }
    
    
    func showToast(message : String) {
        
        let options = [
            kCRToastTextKey : message,
            kCRToastTextAlignmentKey : NSNumber(value:NSTextAlignment.center.rawValue),
            kCRToastBackgroundColorKey : UIColor(netHex:Constants.PRIMARY_COLOR),
            kCRToastNotificationTypeKey : NSNumber(value:CRToastType.custom.rawValue),
            kCRToastNotificationPreferredHeightKey : NSNumber(value: 32),
            kCRToastNotificationPresentationTypeKey : NSNumber(value: CRToastPresentationType.cover.rawValue),
            kCRToastFontKey : UIFont.systemFont(ofSize: 14)
            
        ] as [String : Any]
        
        CRToastManager.showNotification(options: options, completionBlock: nil)
    }
    

    
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(hex:Int) {
        
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        let alpha = (hex >> 24) & 0xff
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha:CGFloat(alpha) / 255.0)
    }
}

extension String {
    func encodeString() -> String? {
        
        let converted = replacingOccurrences(of: "/", with: Constants.SLASH)
        
        let customAllowedSet =  NSCharacterSet(charactersIn:"!*'();:@&=+$,/?%#[] ").inverted
        return converted.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!.encodeEmoji
    }
    
    var decodeEmoji: String {
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue) as String?
        
        if decodedStr != nil {
            return decodedStr!
        }
        
        return self
    }
    
    var encodeEmoji: String {
    
        let encodedStr = NSString(cString: self.cString(using: String.Encoding.nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue) as String?
        
        if encodedStr != nil {
            return encodedStr!
        }
        
        return self
    }
}


public extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x:0, y:0, width:size.width, height:size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

extension Array where Element : Equatable {
    
    mutating func remove(object : Element) {
        if let index = index(of:object) {
            remove(at: index)
        }
    }
}


extension DefaultsKeys {
    
    static let userid = DefaultsKey<Int?>("userid")
    static let token = DefaultsKey<String?>("token")
    
}

