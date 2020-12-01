//
//  LogInViewController.swift
//  HammockUP
//
//  Created by Anthony Guillard on 21/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    //Outlets
    //Gloqbl structure variables
    // database reference for user information
    let userReference = Database.database().reference(withPath: "Users")
    //reference to storage of profile pictures
    let profilePicRef = Storage.storage().reference(withPath: "User Profile Pictures")
    
    //email field
    lazy var emailAddressField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        //textField.placeholder = "Enter your email address here"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        //textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.contentHorizontalAlignment = .leading
        textField.backgroundColor = .clear
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.0)
        textField.layer.cornerRadius = 5.0
        

        textField.attributedPlaceholder = NSAttributedString(string: "Email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //password field
    lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.textColor = UIColor.white
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        //textField.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        //textField.placeholder = "Enter your password here"
        //rgb(245,245,245)
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        textField.backgroundColor = .clear
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0)
        textField.layer.cornerRadius = 5.0
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //line under email address
    lazy var emailLine: Line = {
        let line = Line()
        line.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        return line
    }()
    
    //line under password field
    lazy var passwordLine: Line = {
        let line = Line()
        line.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        return line
    }()
    
    //sign up button
    lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 0.85)
        button.setTitle("Don't have an account? Create one!", for: .normal)
        button.layer.cornerRadius = 5.0
        button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        button.addTarget(self, action: #selector(signUpUser), for: .touchUpInside)
        return button
    }()
    
    //log in button
    lazy var logInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 0.85)
        button.setTitle("Log in", for: .normal)
        button.layer.cornerRadius = 5.0
        button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        button.addTarget(self, action: #selector(logInUser), for: .touchUpInside)
        return button
    }()
    
    //app logo in image view
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "pachaImage")
        imageView.image = UIImage(named: "logoforApp")
        return imageView
    }()
    
    //forgot password
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 0.85)
        button.setTitle("Forgot password?", for: .normal)
        button.layer.cornerRadius = 5.0
        button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        return button
    }()
    
    lazy var appName: UILabel = {
        let label = UILabel()
        label.text = "Pacha"
        label.textColor = .white
        //label.backgroundColor = UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.font = UIFont(name:"Rockwell", size: 35.0)
        label.textAlignment = .center
        return label
    }()
    
    lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        imageView.image = UIImage(named: "coloradoImage")
        return imageView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(patternImage: UIImage(named: "coloradoImage")!)
        //let screenSize: CGRect = UIScreen.main.bounds
           
        //var bgImage = UIImageView(image: UIImage(named: "backgroundImage"))
        //bgImage.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        //self.view.addSubview(bgImage)
        //view.backgroundColor = UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        //make buttons and field appear
        view.addSubview(backgroundImage)
        view.addSubview(emailAddressField)
        view.addSubview(passwordField)
        view.addSubview(logInButton)
        view.addSubview(signUpButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(appName)
        view.addSubview(logoImage)
        
        view.addSubview(emailLine)
        view.addSubview(passwordLine)
        
        //add constraints to view
        setLogInConstraints()
        
        //log in user
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                //add a bit of delay so everything loads
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // add delay of a tenth of a second so that everything loads
                   // Code you want to be delayed
                    self.performSegue(withIdentifier: "loggedInToMap", sender: nil)
                    self.emailAddressField.text = nil
                    self.passwordField.text = nil
                    //send emails to a limit of 10 (follow up in map view)
                    user?.reload { (error) in
                        switch user!.isEmailVerified {
                        case true:
                            print("email verified")
                        case false:
                            return
                           // user?.sendEmailVerification { (error) in
                               // guard error != nil else {
                             //       //self.checkAndSendVerificationEmails(user: user!)
                                //    return print("user email sent")
                                //}
                           // }
                        }
                    }
                }
            }
        }
    }
    
    //check number of emaisl have been sent (after 10 confirmation emails we delete account)
    func checkAndSendVerificationEmails(user: User) {
        
        var numEmailsSent = 0
        //check number of emails from database
        userReference.child("UserID: \(user.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let snappy = child as! DataSnapshot
                //check if we have already sent emails
                if snappy.key == "Number Emails Sent" {
                    numEmailsSent = snappy.value as! Int
                }
            }
            //if first time we are sending an email we set value to 1 to number of emails sent
            if numEmailsSent == 0 {
                self.userReference.child("UserID: \(user.uid)").child("Number Emails Sent").setValue(1)
            }
            // if no the first time we add one to the number of emails sent
            else {
                self.userReference.child("UserID: \(user.uid)").updateChildValues(["Number Emails Sent": numEmailsSent + 1])
            }
            
            //if we sent 10 emails
            if numEmailsSent == 10 {
                //delete account if sent 10 emails
                user.delete { error in
                    if error != nil {
                        print("Error")
                        // An error happened.
                    } else {
                        print("Account deleted")
                        //display alert to user
                        let emailsSentAlert = UIAlertController(title: "Account deleted", message: "You did not confirm your email, your account is deleted", preferredStyle: .alert)
                        //ok action
                        emailsSentAlert.addAction(UIAlertAction(title: "OK", style: .cancel))

                        self.present(emailsSentAlert, animated: true, completion: nil)
                  // Account deleted.
                    }
                }
            }
                //do not delete just say how many reminders he has
            else {
                //display alert to user
                let emailsSentAlert = UIAlertController(title: "Confirm Email", message: "\(10 - numEmailsSent) confirmation emails left before your account is deleted", preferredStyle: .alert)
                //ok action
                emailsSentAlert.addAction(UIAlertAction(title: "OK", style: .cancel))

                self.present(emailsSentAlert, animated: true, completion: nil)
            }
        })
    }
    
    //log in method
    @objc func logInUser(_ sender: UIButton) {
        //make sure it is filled
        guard
            let email = emailAddressField.text,
            let password = passwordField.text,
            email.count > 0,
            password.count > 0
        else {
            let alert = UIAlertController(title: "Sign In Failed", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        //sign in user with its credentials if correct
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
        if let error = error, user == nil {
            let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //forgot password function
    @objc func forgotPassword(_sender: UIButton) {
        //ask user to type in email to send him an email
        //we show an alet
        let emailAlert = UIAlertController(title: "Please enter your email address", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let emailField = emailAlert.textFields![0]
            Auth.auth().sendPasswordReset(withEmail: emailField.text!)
        }
        emailAlert.addTextField { textEmail in textEmail.placeholder = "Enter your email"
        }
        let cancelAction = UIAlertAction(title: "Cancel",style: .cancel)
        
        emailAlert.addAction(saveAction)
        emailAlert.addAction(cancelAction)
        self.present(emailAlert, animated: true, completion: nil)
        
    }
    
    //sign up method
    @objc func signUpUser(_ sender: UIButton) {
        
        //go to sign up vc
        performSegue(withIdentifier: "logInToSignUp", sender: sender)
    }
    
    //error alert displayed when error happens
    func showErrorController(error: String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)

        let alertOKAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default,handler: { action in
            print("OK Button Pressed")
            })

        let alertCancelAction = UIAlertAction(title:"Cancel", style: UIAlertAction.Style.destructive,handler: { action in
            print("Cancel Button Pressed")
         })

        alert.addAction(alertOKAction)
        alert.addAction(alertCancelAction)
        //display it to user
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Constraints
    //anchor to set the display for all iphones
    func setLogInConstraints() {
        
        //app Name text
        appName.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 6.7, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.05))
        
        //logo image view
        logoImage.anchor(top: appName.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 40, left: view.frame.width * 0.44, bottom: 0, right: view.frame.width * 0.44), size: .init(width: 0, height: view.frame.height / 12))
        
        //email address field
        emailAddressField.anchor(top: logoImage.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 30, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        emailLine.anchor(top: emailAddressField.bottomAnchor, leading: emailAddressField.leadingAnchor, bottom: nil, trailing: emailAddressField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //password field
        passwordField.anchor(top: emailAddressField.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 30, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        passwordLine.anchor(top: passwordField.bottomAnchor, leading: passwordField.leadingAnchor, bottom: nil, trailing: passwordField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //login button
        logInButton.anchor(top: passwordField.bottomAnchor, leading: passwordField.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: view.frame.height / 30, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.width/2.8, height: view.frame.height * 0.05))
        
        //forgotpassword button
        forgotPasswordButton.anchor(top: passwordField.bottomAnchor, leading: nil, bottom: nil, trailing: passwordField.trailingAnchor, padding: .init(top: view.frame.height / 30, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.width/2.8, height: view.frame.height * 0.05))
        
        //signupbutton/create account
        signUpButton.anchor(top: nil, leading: emailAddressField.leadingAnchor, bottom: view.bottomAnchor, trailing: emailAddressField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: view.frame.height / 20, right: 0), size: .init(width: 0, height: view.frame.height * 0.065))

    }
    
}

