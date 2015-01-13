//
//  ViewController.swift
//  SnapchatClone
//
//  Created by Christopher Alan on 1/12/15.
//  Copyright (c) 2015 Christopher Alan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var usernameInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    
    
    @IBAction func loginButton(sender: AnyObject) {
        
        // show a progress bar if needed (slow internet etc.)
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        PFUser.logInWithUsernameInBackground(usernameInput.text, password:passwordInput.text) {
            (user: PFUser!, loginError: NSError!) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if user != nil {
                // Do stuff after successful login.
                self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                println("logged in!")
            } else {
                // The login failed. Check error to see why.
                self.displayAlert("Error", error: "Please check username and password.")
            }
        }
        
    }
    
    @IBAction func signupButton(sender: AnyObject) {
        
        var error = ""
        
        if usernameInput.text == "" || passwordInput.text == "" {
            
            error = "Please enter a username and password"
            // probably a good idea to set restrictions on the password here with an else statement
        }
        
        if error != "" {
            
            displayAlert("Error", error: error)
            
        } else {
            
            var user = PFUser()
            user.username = usernameInput.text
            user.password = passwordInput.text
            //user.email = "email@example.com"
            // other fields can be set just like with PFObject
            //user["phone"] = "415-392-0202"
            
            // show a progress bar if needed (slow internet etc.)
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool!, signupError: NSError!) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if signupError == nil {
                    // Hooray! Let them use the app now.
                    
                    self.displayAlert("Success", error: "")
                    
                } else {
                    if let errorString = signupError.userInfo?["error"] as? NSString {
                        
                        error = errorString
                        
                    } else {
                        
                        error = "Please try again later."
                        
                    }
                    // Show the errorString somewhere and let the user try again.
                    
                    self.displayAlert("Could not sign up", error: error)
                }
            }
            
        }
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
    
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // called when 'return' key pressed. return NO to ignore.
        usernameInput.resignFirstResponder()
        passwordInput.resignFirstResponder()
        return true
        
    }
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }


}

