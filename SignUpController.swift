//
//  SignUpController.swift
//  HammockUP
//
//  Created by Anthony Guillard on 29/04/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.

import UIKit
import Firebase

class SignUpController: UIViewController {

    // database reference for user information
    let userReference = Database.database().reference(withPath: "Users")
    //reference to storage of profile pictures
    let profilePicRef = Storage.storage().reference(withPath: "User Profile Pictures")
    
    //gloabl variable definition
    //create account label
    lazy var signUpLabel: UILabel = {
        let label = UILabel()
        //let label = UILabel(frame: CGRect(x: 0 , y: 100, width: view.frame.width, height: 40))
        label.text = "Create a Pacha account"
        label.textColor = .white
        //label.backgroundColor = UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.font = UIFont(name:"Rockwell", size: 24.0)
        label.textAlignment = .center
        return label
    }()
    
    //email field
    lazy var emailAddressField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        //textField.placeholder = "Enter your email address here"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.backgroundColor = .clear
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.75)
        textField.layer.cornerRadius = 5.0
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //password field
    lazy var passwordField: UITextField = {
        let textField = UITextField()
        //textField.isSecureTextEntry = true
        textField.textColor = .white
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        //textField.placeholder = "Enter your password here"
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your password", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.75)
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 5.0
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //first name field
    lazy var firstNameField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        //textField.placeholder = "Enter your email address here"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.backgroundColor = .clear
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.75)
        textField.layer.cornerRadius = 5.0
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your first name", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //last name field
    lazy var lastNameField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        //textField.placeholder = "Enter your email address here"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.backgroundColor = .clear
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.75)
        textField.layer.cornerRadius = 5.0
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your last name", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //username field
    lazy var usernameField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        //textField.placeholder = "Enter your email address here"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.backgroundColor = .clear
        //textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.75)
        textField.layer.cornerRadius = 5.0
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your username", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)])
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir", size: 18.0)
        return textField
    }()
    
    //create accoutn button
    lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 0.85)
        button.setTitle("Create account", for: .normal)
        button.layer.cornerRadius = 5.0
        button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        button.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        return button
    }()
    
    //backgroudn image
    lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        imageView.image = UIImage(named: "coloradoImage")
        return imageView
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
    
    //line under email address
    lazy var usernameLine: Line = {
        let line = Line()
        line.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        return line
    }()
    
    //line under password field
    lazy var firstNameLine: Line = {
        let line = Line()
        line.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        return line
    }()
    //line under email address
    lazy var lastNameLine: Line = {
        let line = Line()
        line.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        return line
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        view.addSubview(backgroundImage)
        
        //add all text fields and buttons
        view.addSubview(createAccountButton)
        view.addSubview(usernameField)
        view.addSubview(lastNameField)
        view.addSubview(emailAddressField)
        view.addSubview(passwordField)
        view.addSubview(firstNameField)
        view.addSubview(signUpLabel)
        
        view.addSubview(emailLine)
        view.addSubview(passwordLine)
        view.addSubview(firstNameLine)
        view.addSubview(lastNameLine)
        view.addSubview(usernameLine)
        
        //log in user after setting up his account
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.performSegue(withIdentifier: "signUpToMap", sender: nil)
                    self.emailAddressField.text = nil
                    self.passwordField.text = nil
                }
            }
        }
        // Do any additional setup after loading the view.
        setUpSignUpConstraints()
    }
    
    //create account function
    @objc func createAccount() {
        
        //check if all fields are filled in
        if emailAddressField.text == "" || passwordField.text == "" || usernameField.text == "" || lastNameField.text == "" || firstNameField.text == "" {
            let alert = UIAlertController(title: "Missing information", message: "Please fill in all the required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            //and exit out of function to not create any account 
            return
        }
            
        //if all fields are filled in sign up user
        else {
            //check if pseudo is different than existing ones before saving it
            //where usernames are sorted
            var pseudoTaken = false
            Database.database().reference(withPath: "Usernames").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    let subSnap = child as! DataSnapshot
                   //if pseudo chosen is equal to ones of the already chosen one then present alert to say to choose another one and do not create an account
                    if self.usernameField.text == subSnap.value as? String{
                        //display alert saying the username is already taken
                        let alertSignUp = UIAlertController(title: "User name already taken", message: "Please choose another username", preferredStyle: .alert)
                        alertSignUp.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertSignUp, animated: true, completion: nil)
                        //exit out of this method
                        pseudoTaken = true
                        return
                   }
                   //if pseudo does not exist then carry on
               }
           })
           
            //if pseudo not taken yet
            //create user with input text
            if pseudoTaken == false {
                Auth.auth().createUser(withEmail: emailAddressField.text!, password: passwordField.text!) { user, error in
                    if error == nil {
                        //if no error sign in user
                        Auth.auth().signIn(withEmail: self.emailAddressField.text!,password: self.passwordField.text!)
                        //create child reference to users with their user ID
                        // also gather his name and his last name for users to search for them later on
                        let specUserID = self.userReference.child("UserID: \(user!.user.uid)")
                        //set first and last name
                        //add also username to both nodes that have it
                        specUserID.child("First Name").setValue(self.firstNameField.text)
                        specUserID.child("Last Name").setValue(self.lastNameField.text)
                        specUserID.child("Pseudo").setValue(self.usernameField.text)
                        //dispay every pin by default
                        specUserID.child("Settings").child("Display every pin").setValue(1)
                        //search by name by default
                        specUserID.child("Settings").child("Search by name").setValue(1)
                        //display only hammocks by default
                        specUserID.child("Settings").child("Kayak Display").setValue(0)
                        specUserID.child("Settings").child("Hammock Display").setValue(1)
                        specUserID.child("Settings").child("Hike Display").setValue(0)
                        specUserID.child("Settings").child("Pov Display").setValue(0)
                        specUserID.child("Settings").child("Fitness Display").setValue(0)
                        //display hammocks by default
                        specUserID.child("Settings").child("Location Display").setValue(2)
                        print("GAVE LOC DISPLAY")
                        //define username
                        Database.database().reference(withPath: "Usernames").child(user!.user.uid).setValue(self.usernameField.text)
                        //give user a default bio and activity
                        specUserID.child("User Bio").setValue("No description yet")
                        //total activity: spots created, spots deleted, spots reviewed
                        specUserID.child("User Activity").child("Number of Spots created").setValue(0)
                        specUserID.child("User Activity").child("Number of Spots deleted").setValue(0)
                        specUserID.child("User Activity").child("Number of Spots reviewed").setValue(0)
                        //give user  a default profile picure
                        self.giveUserDefaultProfilePic()
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                        }
                        
                   }
                   //if error then tell user
                   else {
                       //if cant sign up display error
                       let alertSignUp = UIAlertController(title: "Sign Up Failed", message: error?.localizedDescription, preferredStyle: .alert)
                       alertSignUp.addAction(UIAlertAction(title: "OK", style: .default))
                       self.present(alertSignUp, animated: true, completion: nil)
                   }
               }
            }
        //create account here
        //if successful perform segue to map VC
        }
    }
        
    //put default profile image
    func giveUserDefaultProfilePic() {
        
        //give default hammock profile picture
        let profileImage = UIImage(named: "profilePicture")
        print("IN GIVE DEFAULT PROFILE PIC")
        //transform image to data
        guard let _ = profileImage, let imageData = profileImage!.jpegData(compressionQuality: 1.0)
            else {
                showErrorController(error: "Something went wrong")
                return
        }
        
        //retrieve user ID from firebase
        let user = Auth.auth().currentUser
        if let user = user {
            let UserUid = user.uid
            //store image data on firebase storage
            let userProfilePicRef = profilePicRef.child("User: \(UserUid)")
            userProfilePicRef.putData(imageData, metadata: nil) { (metadata, error) in
                //if errors
                if let error = error{
                    self.showErrorController(error: error.localizedDescription)
                    return
                }
                userProfilePicRef.downloadURL(completion: { (URL, err) in
                    if let err = err {
                        self.showErrorController(error: err.localizedDescription)
                        return
                    }
                    guard let URL = URL else {
                        self.showErrorController(error: "Something went wrong")
                        return
                    }
                    //store url reference with user info
                    let databaseReference = Database.database().reference(withPath: "Users")
                    let urlString = URL.absoluteString
                    databaseReference.child("UserID: \(UserUid)").updateChildValues(["Profile Picture": urlString])
                })
            }
        }
    }
    
    //error alert displayed when error happens
    func showErrorController(error: String) {
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
    //function that holds all constraints
    func setUpSignUpConstraints() {
        
        // for sign up label
        signUpLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 12, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.05))

        //email address field
        emailAddressField.anchor(top: signUpLabel.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 12, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        emailLine.anchor(top: emailAddressField.bottomAnchor, leading: emailAddressField.leadingAnchor, bottom: nil, trailing: emailAddressField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //password field
        passwordField.anchor(top: emailAddressField.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 30, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        passwordLine.anchor(top: passwordField.bottomAnchor, leading: passwordField.leadingAnchor, bottom: nil, trailing: passwordField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //first name field
        firstNameField.anchor(top: passwordField.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 30, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        firstNameLine.anchor(top: firstNameField.bottomAnchor, leading: firstNameField.leadingAnchor, bottom: nil, trailing: firstNameField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //last name field
        lastNameField.anchor(top: firstNameField.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 30, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        lastNameLine.anchor(top: lastNameField.bottomAnchor, leading: lastNameField.leadingAnchor, bottom: nil, trailing: lastNameField.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //username field
        usernameField.anchor(top: lastNameField.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 30, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))
        usernameLine.anchor(top: usernameField.bottomAnchor, leading: usernameField.leadingAnchor, bottom: nil, trailing: usernameField
            .trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2))
        
        //create accoutn button
        createAccountButton.anchor(top: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 24, left: view.frame.width * 0.065, bottom: 0, right: view.frame.width * 0.065), size: .init(width: 0, height: view.frame.height * 0.065))

        //print("HEIGHT IS: \(view.frame.height) and WIDTH IS : \(view.frame.width)")
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue,         r: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
