//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-02.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFIeld: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //update UI accordingly
    func isLoggingIn(isLoggingIn:Bool){
        DispatchQueue.main.async {
            if isLoggingIn {
                self.activityIndicator.startAnimating()
            }
            else {
                self.activityIndicator.stopAnimating()
            }
            self.emailTextField.isEnabled = !isLoggingIn
            self.passwordTextFIeld.isEnabled = !isLoggingIn
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        isLoggingIn(isLoggingIn: true)
        if emailTextField.text == "" || passwordTextFIeld.text == "" {
            isLoggingIn(isLoggingIn: false)
            let alertController = UIAlertController(title: "Error", message: "Please enter a valid email address and password", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Dismiss", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            loginSessionRequest(email: emailTextField.text! , password: passwordTextFIeld.text!)
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let url = APIHelper.Endpoints.signUp.url
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func loginSessionRequest(email:String,password:String) {
        let httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        APIHelper.loginRequest(httpBody: httpBody) { (didLogin,isNetworkError,error) in
            self.isLoggingIn(isLoggingIn: false)
            if error != nil || !didLogin {
                let alertController:UIAlertController
                if isNetworkError  {
                    alertController = UIAlertController(title: "Error", message: "Network Error. Please try again later.", preferredStyle: .alert)
                }
                else {
                    alertController = UIAlertController(title: "Error", message: "Invalid credentials. Please try again.", preferredStyle: .alert)
                }
                DispatchQueue.main.async {
                    let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "segueOne", sender: nil)
                
            }
        }
    }
}
