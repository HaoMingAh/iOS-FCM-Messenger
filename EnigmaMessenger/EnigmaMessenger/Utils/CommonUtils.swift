//
//  CommonUtils.swift
//  Fiit
//
//  Created by JIS on 2016/12/10.
//  Copyright © 2016 JIS. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation
import UIKit


func isValidEmail(testStr:String) -> Bool {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
    
}


func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}



func getDigitsOfNumber(number:Int) -> Int {
    
    let strNumber = String(number)
    
    let array = strNumber.characters.map{Int(String($0)) ?? 0}
    return array.count
    
}

func getLocalTimeString(fromTime:String) -> String {
    
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    df.timeZone = TimeZone(abbreviation: "UTC")
    
    let fromDate = df.date(from: fromTime)
    
    df.timeZone = NSTimeZone.local
    df.dateFormat = "yyyy.MM.dd"
    
    let localTime = df.string(from: fromDate!)
    
    return localTime;
}


func getLocalTimeString(fromDate:Date) -> String {
    
    let df = DateFormatter()
    df.dateFormat = "yyyy.MM.dd"
    df.timeZone = NSTimeZone.local
    
    let localTime = df.string(from: fromDate)
    
    return localTime;
    
}


func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    
    let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}



func vibrate() {
    
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

let systemSoundID = 1007
func playSound() {
    
    AudioServicesPlayAlertSound(UInt32(systemSoundID))
}

func blur(theImage:UIImage) ->UIImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    let context = CIContext(options: nil)
    let inputImage = CIImage(cgImage: theImage.cgImage!)
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    
    filter?.setValue(NSNumber(value: 25.0), forKey:"inputRadius")
    let result = filter?.value(forKey: kCIOutputImageKey)
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
//    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    let cgImage = context.createCGImage(result as! CIImage, from: inputImage.extent)
    let returnImage = UIImage(cgImage: cgImage!)

    return returnImage;

}


func heightForView(text:String, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

