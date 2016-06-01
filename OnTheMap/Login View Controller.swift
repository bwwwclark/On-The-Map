//
//  Login View Controller.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation
import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    
    var session: NSURLSession!
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //get shared URL session
        session = NSURLSession.sharedSession()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
        spinner.hidesWhenStopped = true
        
    }
    
    func ViewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        spinner.hidden = true
        
    }
    
    
    @IBAction func loginButton(sender: AnyObject) {
        
        if ((emailTextField.text!.isEmpty) || (passwordTextField.text!.isEmpty)) {
            showAlert("Empty Email or Password")
        } else {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            spinner.hidden = false
            spinner.startAnimating()
            UdacityClient.sharedInstance().loginWithUdacity(email, password: password, completionHandler: closureForLoginDidSucceed)
        }
    }
    func closureForLoginDidSucceed(success: Bool, message: String, error: NSError?) -> Void {
        if success {
            completeLogin(message)
        } else {
            showAlert(message)
        }
    }
    
    func completeLogin(message: String) {
        //Log in
        dispatch_async(dispatch_get_main_queue(), {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
        self.spinner.stopAnimating()
        self.presentViewController(controller, animated: true, completion: nil)
        print(message)
        })
    }
    
    func showAlert(error: String) {
        //show an alert
        dispatch_async(dispatch_get_main_queue(), {
            self.spinner.stopAnimating()
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissAnyVisibleKeyboards()
        loginButton(UIButton)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func dismissAnyVisibleKeyboards() {
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            view.endEditing(true)
        }
    }
}
    
    


