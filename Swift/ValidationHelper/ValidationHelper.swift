//
//  ValidationHelper.swift
//  helapay-for-business-ios
//
//  Created by Prashan Samarathunge on 2022-01-10.
//

import Foundation
import UIKit
import PencilKit
import Network

/**
 Used for validate TextFields and Objects
 
 -parameters:
 - editableTextField
 - nonEditableTextField
 - object that referenced to nonEditableTextField
 */
class ValidationHelper{
    //MARK: - Validation
    typealias AnyTextFields = [AnyObject]?
    typealias AnyDataFields = [AnyObject]?
    typealias AnyDataObjects = [AnyObject]?
    
    
    /// This function is used for validation of text fields and data objects.
    /// It checks if the text fields are empty and sets an error if they are.
    /// It also checks if data objects are nil and sets an error accordingly.
    /// The function returns true if all validations pass and false otherwise.
    ///
    /// - Important:
    ///   - For `editableTextFields`, the function checks if any are empty.
    ///   - For `dataObjects`, the function checks if any are nil.
    ///   - If either of these checks fail, the function sets an error message on the corresponding field and returns false.
    ///
    /// - Parameters:
    ///   - vC: The view controller where the function is being called.
    ///   - editableTextFields: An array of text fields that should be checked for empty values.
    ///   - dataTextFields: An array of data text fields corresponding to the data objects.
    ///   - dataObjects: An array of data objects that should be checked for nil values.
    ///   - emptyErrorEditable: An array of error messages that should be set for empty editable text fields.
    ///   - emptyErrorNonEditable: An array of error messages that should be set for nil data objects.
    ///
    /// - Returns: A boolean value indicating whether all validations passed (true) or not (false).

    @discardableResult static func fieldvalidation(
        _ vC:UIViewController,
        _ editableTextFields: [AnyObject]? = nil,
        _ dataTextFields: [AnyObject]? = nil,
        _ dataObjects: [Any?]? = nil,
        _ emptyErrorEditable : [String?]? = nil,
        _ emptyErrorNonEditable: [String?]? = nil) -> Bool{
            
            
            var isValidated:Bool = false
            
            if let textFields = editableTextFields as? [UITextField]{
                //Return true if validation satisfies all the pre-conditions of editableText
                if textFields.allSatisfy({ $0.text?.isEmpty as! Bool}) {
                    //                    AlertBoxHelper.alert(title: "Error".l10n(), message: "Fill the required details!".l10n(), viewController: vC)
                    //                    return false
                }
                
                
                for case let (index, element as UITextField) in textFields.enumerated(){
                    if textFields.contains(element), element.text!.isEmpty {
                        element.shake()
                        
                        isValidated = false
                        if  let errorMessage = emptyErrorEditable?[index] {
                            element.setError(errorMessage.l10n(), show: false)
                        }else{
                            element.setError("Error_Field_Required".l10n(), show: false)
                        }
                    }
                }
                
                //Set True if Editable textFields are not Empty
                if textFields.allSatisfy({ !($0.text?.isEmpty ?? false) as! Bool}) {
                    isValidated = true
                }
                
                //Check Objects for null or Empty inputs
                if let objdata = dataObjects as? [AnyObject?], let objTextField = dataTextFields as? [UIView]{
                    
                    for (index,element) in objdata.enumerated(){
                        
                        if (element == nil){
                            objTextField[index].shake()
                            if let onlyTextField = objTextField[index] as? UITextField {
                                if  let errorMessage = emptyErrorNonEditable?[index] {
                                    onlyTextField.setError(errorMessage.l10n(), show: false)
                                }else{
                                    onlyTextField.setError("Error_Required_Data".l10n(), show: false)
                                }
                            }
                            
                            isValidated = false
                        }
                    }
                }
                if isValidated && textFields.allSatisfy({ !($0.text?.isEmpty ?? false) as! Bool}) {
                    return true
                }
            }
            //Return False If Any Condition Fails to Satisfy Preconditions
            return false
        }
    
    /**
     This function validates an email string using a regular expression. The function checks if the email string matches the pattern of a typical email.
     
     - Important:
     - The email string must not contain any spaces, parentheses, or backslashes.
     - It must contain exactly one '@' character, and this character must be followed by at least one non-space, non-parentheses, non-backslash character, a period, and another non-space, non-parentheses, non-backslash character.
     - If the email string does not match this pattern, the function will return `false`.
     
     - Parameter email: A `String` containing the email to be validated.
     
     - Returns: A Boolean value indicating whether the email string is valid (`true`) or not (`false`).
     */
    static func validateEmail(_ email: String) -> Bool{
        // Fixes "Poor Email Validation" May 13
        // return Regex.isMatch("^[a-zA-Z0123456789]+@[a-zA-Z0123456789]+\\.[a-zA-Z0123456789]+$", target: email)
        return email.matchExists(for: "^[^\\s@()\\\\]+@[^\\s@()\\\\]+\\.[^\\s@()\\\\]+$")
        
    }
    
    enum CheckOptions:Int{
        case SINHALA = 0
        case ENGLISH_CAP
        case ENGLISH_SIMP
        case EMOJI_EXCLUDE
        case EMOJI_INCLUDE
        case DIGITS_INCLUDE
        case DIGITS_EXCLUDE
        case WHITESPACE_ALLOWED
        
    }
    
    static func shouldValidateTextFor(string:String, options:[CheckOptions]) -> Bool{
        var isValid:Bool = false
        let unicodeRangeArr:[ClosedRange<UInt32>] = [
            0x0D80...0x0DFF, //Sinhala
            0x0041...0x005A, //Capital
            0x0061...0x007A //Simple
        ]
        
        var mustCheckRange:[ClosedRange<UInt32>] = []
        var includeCriteriaPassed:Bool = false
        var otherCriteriaPassed:Bool = false
        var otherCriterias:[Bool] = []
        
        options.forEach {
            switch $0 {
            case .SINHALA:
                mustCheckRange.append(0x0D80...0x0DFF) //Range Sinhala
            case .ENGLISH_CAP:
                mustCheckRange.append(0x0041...0x005A) //Range Capital
            case .ENGLISH_SIMP:
                mustCheckRange.append(0x0061...0x007A) //Range Simple
            case .EMOJI_INCLUDE:
                otherCriterias.append(string.containsEmoji)
            case .EMOJI_EXCLUDE:
                otherCriterias.append(!string.containsEmoji)
            case .DIGITS_INCLUDE:
                otherCriterias.append((string.rangeOfCharacter(from: .decimalDigits) != nil))
            case .DIGITS_EXCLUDE:
                otherCriterias.append(!(string.rangeOfCharacter(from: .decimalDigits) != nil))
            default:
                break;
            }
        }
        
        //Check Include Criteria
        includeCriteriaPassed = false
        for checkRange in mustCheckRange {
            guard let firstScalar = string.unicodeScalars.first else {continue}
            if includeCriteriaPassed == true {
                break
            }
            
            includeCriteriaPassed = checkRange.contains(firstScalar.value)
        }
        
        
        //Check dependable other criterias
        for exp in otherCriterias {
            if otherCriteriaPassed == true {
                break
            }
            otherCriteriaPassed = exp
        }
        
        
        if !(options.contains(.SINHALA) || options.contains(.ENGLISH_SIMP) || options.contains(.ENGLISH_CAP)) {
            //xprint("\nString Validation Triggered OC:", otherCriteriaPassed, " FINAL: ",otherCriteriaPassed)
            return otherCriteriaPassed || (string.rangeOfCharacter(from: .whitespaces) != nil)
        }
        //xprint("\nString Validation Triggered: IC:",includeCriteriaPassed ," OC:", otherCriteriaPassed, " FINAL: ",includeCriteriaPassed || otherCriteriaPassed)
        return includeCriteriaPassed || otherCriteriaPassed || (string.rangeOfCharacter(from: .whitespaces) != nil)
        //return !string.containsEmoji && (isValid || string.rangeOfCharacter(from: .decimalDigits) != nil || string.rangeOfCharacter(from: .whitespaces) != nil)
    }
    
    /**
     This function validates a given string based on the provided options from the `CheckOptions` enum. The function checks if the string meets specified criteria such as containing certain unicode ranges (Sinhala, English uppercase, English lowercase), including/excluding emojis, including/excluding digits, and allowing whitespaces.
     
     - Important:
     - If a unicode range option is selected (Sinhala, English uppercase, English lowercase), the function checks if the first unicode scalar of the string falls within the specified range(s).
     - If the 'Emoji Include' option is selected, the function checks if the string contains any emojis.
     - If the 'Emoji Exclude' option is selected, the function checks that the string does not contain any emojis.
     - If the 'Digits Include' option is selected, the function checks if the string contains any digits.
     - If the 'Digits Exclude' option is selected, the function checks that the string does not contain any digits.
     - If no unicode range option is selected, the function returns true if any other criteria is met or if the string contains whitespaces.
     
     - Parameters:
     - string: A `String` containing the text to be validated.
     - options: An array of `CheckOptions` specifying which validations to apply.
     
     - Returns: A Boolean value indicating whether the string passes all specified validations.
     */
    static func shouldValidateNIC(changedChar:String,text:String) -> Bool {
        //NIC Limit
        if changedChar == "" {
            return true
        }else if text.matchExists(for: "^[0-9]{9}[VXvx]$") {
            return false
        }else if text.matchExists(for: "^[0-9]{12}$") {
            return false
        }else if changedChar.matchExists(for: "[a-uwyz\\D]") && !changedChar.matchExists(for: "[VXvx]") {
            return false
        }else {
            return text.count < 12
        }
    }
    
    /**
     This function formats a given mobile number to a specific format based on a set of regular expressions. The function checks the mobile number against each regular expression in order and applies the corresponding format transformation when a match is found.
     
     - Important:
     - The function supports mobile numbers starting with '0', '7', '94', and '+94'.
     - The function transforms numbers starting with '0' to start with '+94', numbers starting with '94' to start with '+94', and numbers starting with '7' to start with '+94'.
     - If the mobile number starts with '+94', no transformation is applied.
     - If the mobile number does not match any of the supported formats, the completion block is called (if provided), and the function returns `nil`.
     
     - Parameters:
     - text: A `String` containing the mobile number to be formatted.
     - completion: An optional completion block to be called if the mobile number does not match any of the supported formats. Default is `nil`.
     
     - Returns: A `String` containing the formatted mobile number, or `nil` if the number does not match any of the supported formats.
     */
    func formatMobileNumber(text:String ,completion: (() -> Void)? = nil) -> String?{
        let mobileNumber = text
        let textLength = mobileNumber.utf8.count
        let textRange = NSRange(location: 0, length: textLength)
        
        var strFormated:String?
        
        let listRegex = [
            "^0(\\d{9})$":"+94$1", //Replace +94 to start with 0
            "(^94\\d{9}$)":"+$1", //Add + to start with 94
            "(^7\\d{8}$)":"+94$1", //Add +94 to start with 7
            "^\\+94\\d{9}$":"" //No Change
        ]
        var validated = false
        for (key,value) in listRegex {
            if mobileNumber.matchExists(for: key) && !(value.isEmpty) {
                let validationRegex = NSRegularExpression(key)
                strFormated = validationRegex.stringByReplacingMatches(in: mobileNumber, options: [], range: textRange, withTemplate: value)
                validated = true
                break
            }else if mobileNumber.matchExists(for: key) && value.isEmpty{
                strFormated = mobileNumber
                validated = true
                break
            }else{
                validated = false
                strFormated = nil
            }
            
        }
        
        if !validated{
            completion?()
            return nil
        }
        
        xprint("Mobile Number: ",strFormated ?? "Invalid Number")
        return strFormated
    }
    
    /**
     This function validates the length of a mobile number being input into a text field. The function checks the current prefix of the number and restricts the length accordingly.
     
     Mainly used in:
     `func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool`
     
     - Important:
     - The function supports mobile numbers starting with '+94', '94', '0', and '7'.
     - The maximum allowed lengths for numbers starting with '+94', '94', '0', and '7' are 12, 11, 10, and 9 respectively.
     - If the number does not start with any of the supported prefixes, the maximum allowed length is 12.
     - If the `replacementString` is empty (i.e., characters are being deleted), the function always returns `true`.
    
     - Parameters:
     - textField: A `UITextField` containing the mobile number being input.
     - replacementString: A `String` containing the characters being added to the text field.
     
     - Returns: A Boolean value indicating whether the new length is valid (`true`) or not (`false`).
     */
    static func validateMobileNumber(_ textField: UITextField, _ replacementString: String) -> Bool {
        let text = textField.text ?? ""
        //Mobile Number Length Limit
        if replacementString == ""{
            return true
        }else if text.hasPrefix("+94"){
            return text.count < 12
        }else if text.hasPrefix("94"){
            return text.count < 11
        }else if text.hasPrefix("0"){
            return text.count < 10
        }else if text.hasPrefix("7"){
            return text.count < 9
        }else {
            return text.count < 12
        }
    }
}


