/*
 Author: Zhenyuan Bo & Anqi Luo
 File Description: Log-in Utility File
 Date: Nov 23, 2020
 */

import UIKit
import Foundation

class LogInUtils{

    public static func showPopup(isSuccess: Bool, errorCode: Int? = nil, vc: UIViewController? = nil) {
        
        let ERROR_WRONG_PASSWORD_MSG = "Password is incorrect. Please try again."
        let ERROR_INVALID_EMAIL_MSG = "Email is incorrect. Please try again."
        let ERROR_USER_NOT_FOUND_MSG = "Email entered is not found. Please use a saved email account to sign in."
        let ERROR_EMAIL_IN_USE_MSG = "Email you are trying to register is already in use. Please try a different to register your account."
        let ERROR_WEAK_PASSWORD_MSG = "Password you entered is weak (less than 6 characters). Please provide a strong one to register your account."
        let ERROR_SIGN_IN_MSG = "Your credential is incorrect. Please try again."
        let ERROR_REGISTER_MSG = "Fail to register this account. Please try again."
        let PWD_RESET_SUCCESS_MSG = "A password reset link has been sent to your inbox. Please follow steps in there to reset it."
        let PWD_RESET_ERROR_MSG = "Password reset link fails to be sent. Please try again later."
        
        var errorMsg = ""
        var successMsg = ""
        
        if !isSuccess{
            if errorCode == 1{
                errorMsg = ERROR_WRONG_PASSWORD_MSG
            }else if errorCode == 2{
                errorMsg = ERROR_INVALID_EMAIL_MSG
            }else if errorCode == 3{
                errorMsg = ERROR_USER_NOT_FOUND_MSG
            }else if errorCode == 4{
                errorMsg = ERROR_EMAIL_IN_USE_MSG
            }else if errorCode == 5{
                errorMsg = ERROR_WEAK_PASSWORD_MSG
            }else if errorCode == 6{
                errorMsg = ERROR_SIGN_IN_MSG
            }else if errorCode == 7{
                errorMsg = ERROR_REGISTER_MSG
            }else if errorCode == 8{
                errorMsg = PWD_RESET_ERROR_MSG
            }
        }else{
            successMsg = PWD_RESET_SUCCESS_MSG
        }
        
        let alert = UIAlertController(title: isSuccess ? "Success": "Error", message: isSuccess ? successMsg: errorMsg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Understand!", style: UIAlertAction.Style.default, handler: nil))
        
        vc!.present(alert, animated: true, completion: nil)
    }
}
