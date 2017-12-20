import UIKit
import libPhoneNumber_iOS

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol CountryPhoneCodePickerDelegate {
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String)
}

struct Country {
    var code: String?
    var name: String?
    var phoneCode: String?
    
    init(code: String?, name: String?, phoneCode: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
    }
}

class CountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countries: [Country]!
    var countryPhoneCodeDelegate: CountryPhoneCodePickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        super.dataSource = self;
        super.delegate = self;
        
        countries = countryNamesByCode()
    }
    
    // MARK: - Country Methods
    
    func setCountry(_ code: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].code == code {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
    }
    
    func countryNamesByCode() -> [Country] {
        var countries = [Country]()
        
        for code in Locale.isoRegionCodes {
            let countryName = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: code)
            
            let phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
            let phoneCode = "+\(phoneNumberUtil!.getCountryCode(forRegion: code)!)"
            
            if phoneCode != "+0" {
                let country = Country(code: code, name: countryName, phoneCode: phoneCode)
                countries.append(country)
            }
        }
        
        countries = countries.sorted(by: { $0.name < $1.name })
        
        return countries
    }
    
    // MARK: - Picker Methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var resultView: CountryView
        
        if view == nil {
            resultView = (Bundle.main.loadNibNamed("CountryView", owner: self, options: nil)?[0] as! CountryView)
        } else {
            resultView = view as! CountryView
        }
        
        resultView.setup(countries[row])
        
        return resultView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        if let countryPhoneCodeDelegate = countryPhoneCodeDelegate {
            countryPhoneCodeDelegate.countryPhoneCodePicker(self, didSelectCountryCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!)
        }
    }
}
