//
//  OwnUserProfile.swift
//  HammockUP
//
//  Created by Anthony Guillard on 27/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class OwnUserProfile: UIViewController{
    
    
    //MARK: - Global structure variables
    //define bio text
    lazy var bioText: UITextView = {
        let textField = UITextView()
        //make text fields unmodifiable
        textField.isEditable = false
        textField.isUserInteractionEnabled = false
        textField.adjustsFontForContentSizeCategory = true
        textField.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textField.layer.cornerRadius = 10.0
        textField.textColor = .white
        textField.font = UIFont(name: "Avenir", size: 16.0)
        return textField
    }()
    
    //bio label
    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Few words about myself:"
        //label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        return label
    }()
    
    //define save button
    lazy var saveButton: UIButton = {
        let button = UIButton()
        //button.setTitle("Save", for: .normal)
        //button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        //button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        //button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        button.setImage(UIImage(named: "checkmark"), for: .normal)
        button.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        //button.layer.cornerRadius = 5.0
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    //total activity text
    lazy var activityText: UITextView = {
        let textField = UITextView()
        //make text fields unmodifiable
        textField.isEditable = false
        textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textField.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        textField.layer.cornerRadius = 10.0
        textField.font = UIFont(name: "Avenir", size: 16.0)
        textField.sizeToFit()
        
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = .white
        //gather activity for text
        var reviews = 0
        var creations = 0
        var deletions = 0
        //reference to user activity
        usersReference.child("UserID: \(user!.uid)").child("User Activity").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //gathr number of reviews
                if subSnap.key == "Number of Spots reviewed" {
                    reviews = subSnap.value as! Int
                }
                //gather number of spots created
                else if subSnap.key == "Number of Spots created" {
                    creations = subSnap.value as! Int
                }
                //gathernumber of deletions
                else if subSnap.key == "Number of Spots deleted" {
                    deletions = subSnap.value as! Int
                }
                //activity text
                DispatchQueue.main.async{
                    textField.text = "Reviewed \(reviews) spots\n\nCreated \(creations) spots\n\nDeleted \(deletions) spots"
                }
            }
        })
        return textField
    }()
    
    //number of connections text
    lazy var userFriendsCount: UITextView = {
        let textView = UITextView()
        //make text fields unmodifiable
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        textView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        textView.layer.cornerRadius = 10.0
        textView.textColor = .white
        textView.textAlignment = .center
        textView.font = UIFont(name: "Avenir-Heavy", size: 18.0)
        textView.text = "Connections:\n0"
        textView.adjustsFontForContentSizeCategory = true
        //gather number of friends/connections
        //initialize value that gathers number of friends
        var numberConnections = 0
        usersReference.child("UserID: \(user!.uid)").child("Friends with").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let snappy = child as! DataSnapshot
                numberConnections += 1
            }
            DispatchQueue.main.async {
                textView.text = "Connections:\n\(numberConnections)"
            }
        })
        return textView
    }()
    
    //activity label
    lazy var activityLabel: UILabel = {
        let label = UILabel()
        label.text = "User activity:"
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //edit profile button
    lazy var editButt: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        button.setImage(UIImage(named: "editprofile"), for: .normal)
        //button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        //button.setTitle("Edit profile", for: .normal)
        //button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        //button.layer.cornerRadius = 5.0
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    //change photo button
    lazy var changePhotoButt: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(showImagePickerControllerActionSheet), for: .touchUpInside)
        button.setImage(UIImage(named: "changephoto"), for: .normal)
        //button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        //button.setTitle("Change photo", for: .normal)
        //button.layer.cornerRadius = 5.0
        //button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    //define cancel button
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        //button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        button.addTarget(self, action: #selector(cancelChanges), for: .touchUpInside)
        //button.setTitle("Cancel", for: .normal)
        //button.layer.cornerRadius = 5.0
        //button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    //profile picture to display
    lazy var profileImageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 10, y: 10, width: view.frame.height * 0.1444, height: view.frame.height * 0.1444))
        image.contentMode = .scaleToFill
        image.layer.masksToBounds = true
        image.layer.cornerRadius = image.frame.width/2
        return image
    }()
    
    //own pseudo to display 
    lazy var ownPseudoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        //label.adjustsFontForContentSizeCategory = true
        //gather user pseudo from database
        Database.database().reference(withPath: "Usernames").child(user!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
            DispatchQueue.main.async{
                label.text = snapshot.value as? String
            }
        })
        return label
    }()
    
    //badges earned label
    lazy var badgesEarnedLabel: UILabel = {
        let label = UILabel()
        label.text = "Badges earned:"
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        return label
    }()
    
    //image view of creator badge //laurels for creator
    lazy var badgeImageView1: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width - 80, y: 550, width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        //gather activity for text
        var creations = 0
        //reference to user activity
        usersReference.child("UserID: \(user!.uid)").child("User Activity").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //gathr number of reviews
                if subSnap.key == "Number of Spots created" {
                    creations = subSnap.value as! Int
                    //get which badge to display
                    let badgeType = self.createBadge(numberCreations: creations)
                    DispatchQueue.main.async{
                        //if user has not earned any badges write a note
                        if badgeType == "" {
                        }
                        //if he has earn a badge display it
                        else {
                            imageView.image = UIImage(named: badgeType)
                        }
                    }
                }
            }
        })
        return imageView
    }()
    
    //image view of reviewer badge // trophy for reviewr
    lazy var badgeImageView2: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width - 80, y: 550 + 90, width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        //gather activity for text
        var reviews = 0
        //reference to user activity to display correct badge
        usersReference.child("UserID: \(user!.uid)").child("User Activity").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //gathr number of reviews
                if subSnap.key == "Number of Spots reviewed" {
                    reviews = subSnap.value as! Int
                    //get which badge to display
                    let badgeType = self.reviewBadge(numberReviews: reviews)
                    DispatchQueue.main.async{
                        //if no badge is earned for this trophy then give a text or a small image
                        if badgeType == "" {
                            
                        }
                        //if badge is earned display it
                        else {
                            imageView.image = UIImage(named: badgeType)
                        }
                    }
                }
            }
        })
        return imageView
    }()
    
    //no badge text
    lazy var noBadgeText: UITextView = {
        let textView = UITextView()
        //make text fields unmodifiable
        textView.isEditable = false
        textView.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        textView.layer.cornerRadius = 10.0
        textView.font = UIFont(name: "Avenir", size: 16.0)
        textView.sizeToFit()
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .lightGray
        textView.text = "Review and create spots to earn unique badges!"
        return textView
    }()
    
    
    //tab bar that holds the buttons
    lazy var buttonHolder: UITabBar = {
        let tabBar = UITabBar()
        tabBar.backgroundColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 157/255, blue: 121/255, alpha: 1)
        tabBar.barTintColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 157/255, blue: 121/255, alpha: 1)
        tabBar.itemPositioning = .fill
        tabBar.unselectedItemTintColor = UIColor(red: 185/255, green: 187/255, blue: 182/255, alpha: 1)
        tabBar.tintColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        //create button items
        let communityButton = UITabBarItem(title: "", image: UIImage(named: "group"), selectedImage: UIImage(named: "group"))
        let hammockButton = UITabBarItem(title: "", image: UIImage(named: "map"), selectedImage: UIImage(named: "map"))
        let profileButton = UITabBarItem(title: "", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))
        //tags
        communityButton.tag = 1 //first button
        hammockButton.tag = 2 // second button
        profileButton.tag = 3 //third button
        tabBar.items = [communityButton, hammockButton, profileButton]
        //make current VC highlighted button
        tabBar.selectedItem = profileButton

        tabBar.isTranslucent = true
        return tabBar
    }()
    
    //max size of a picture to be uploaded and downloaded in bytes
    let maxPicSize = 4 * 1000 * 1000 //4MB
    //reference to storage of profile pictures
    let profilePicRef = Storage.storage().reference(withPath: "User Profile Pictures")
    //retrieve user ID from firebase
    let user = Auth.auth().currentUser
    //reference to user bracker of firebase storage
    let usersReference = Database.database().reference(withPath: "Users")
    //booleans that hold whether or not there is a picture of badge
    var badge1Display = false
    var badge2Display = false
    var pressedPencil = false
        
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        //view color
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)
        
        //add to display the following
        view.addSubview(bioText)
        view.addSubview(bioLabel)
        view.addSubview(activityText)
        view.addSubview(activityLabel)
        view.addSubview(editButt)
        view.addSubview(ownPseudoLabel)
        view.addSubview(badgeImageView1)
        view.addSubview(badgeImageView2)
        view.addSubview(badgesEarnedLabel)
        view.addSubview(userFriendsCount)
        view.addSubview(profileImageView)
        view.addSubview(buttonHolder)
        
        /*if badge2Display == false && badge1Display == false {
            view.addSubview(noBadgeText)
            noBadgeText.anchor(top: activityText.topAnchor, leading: badgesEarnedLabel.leadingAnchor, bottom: activityText.bottomAnchor, trailing: bioText.trailingAnchor)
        }*/
        
        //display profile pic from online and his bio
        retrieveProfilePic()
        retrieveBio()
        
        //make delegate of textview for bio text ann duser friend count
    bioText.delegate = self
        userFriendsCount.delegate = self
        
        //delegate for button tabbar
        buttonHolder.delegate = self
        
        //make constraints appear
        setConstraintsOwnProfile()
    }

    // define actions when pressing save button
    @objc func saveChanges (sender: UIButton) {
        sender.flash()
        let userBio = bioText.text
        let databaseReference = Database.database().reference(withPath: "Users")
        //update bio text and store it in the firebase database
        databaseReference.child("UserID: \(user!.uid)").updateChildValues(["User Bio": userBio!])
        //and redeactivate user interactions with bio
        bioText.isUserInteractionEnabled = false
        bioText.isEditable = false
        pressedPencil = false
        //gather input bio to display it
        retrieveBio()
        //remove buttons from VC as we are no longer editing
        saveButton.removeFromSuperview()
        cancelButton.removeFromSuperview()
        changePhotoButt.removeFromSuperview()
        view.addSubview(editButt)
        
        //remove constraints of buttons
        changePhotoButt.deActiveAnchor(top: profileImageView.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: profileImageView.frame.width/2 - view.frame.height * 0.0222, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.04))
        saveButton.deActiveAnchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width / 2 + view.frame.height * 0.0333, bottom: view.frame.height * 0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        cancelButton.deActiveAnchor(top: nil, leading: nil, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: view.frame.height * 0.03, right: view.frame.width / 2 + view.frame.height * 0.0333), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        
         //readd edit button
        editButt.anchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width/2 - view.frame.height * 0.0222, bottom: view.frame.height*0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
    }
    
    /*
    @objc func goToConnections (sender: UITextView) {
    //when clicking on connections number, go to connections list
        print("IN GO TO CONNECTIONS")
        performSegue(withIdentifier: "goToConnections", sender: sender)
    }*/

    
    @objc func cancelChanges (sender: UIButton) {
        sender.flash()
        //deactivity user interactions with bio
        bioText.isUserInteractionEnabled = false
        bioText.isEditable = false
        pressedPencil = false
        //gather previous bio to display it
        retrieveBio()
        //remove buttons to disappear
        cancelButton.removeFromSuperview()
        saveButton.removeFromSuperview()
        changePhotoButt.removeFromSuperview()
        view.addSubview(editButt)
        
        //remove constraints of buttons
        changePhotoButt.deActiveAnchor(top: profileImageView.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: profileImageView.frame.width/2 - view.frame.height * 0.0222, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.04))
        saveButton.deActiveAnchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width / 2 + view.frame.height * 0.0333, bottom: view.frame.height * 0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        cancelButton.deActiveAnchor(top: nil, leading: nil, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: view.frame.height * 0.03, right: view.frame.width / 2 + view.frame.height * 0.0333), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        
        //readd edit button
        editButt.anchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width/2 - view.frame.height*0.0222, bottom: view.frame.height*0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        //editButt.anchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width/2 - view.frame.height * 0.022, bottom: view.frame.height * 0.03, right: 0), size: .init(width: 0, height: view.frame.height * 0.0444))
    }
    
    @objc func editProfile (sender: UIButton) {
        sender.pulsate()
        //remove edit button from VC since we only save or cancel
        editButt.removeFromSuperview()
        //backButt.removeFromSuperview()
        //make bio text editable when pressing edit profile
        bioText.isUserInteractionEnabled = true
        bioText.isEditable = true
        bioText.isSelectable = true
        pressedPencil = true
        //add change, save and cancel button to view
        self.view.addSubview(changePhotoButt)
        self.view.addSubview(saveButton)
        self.view.addSubview(cancelButton)
        
        //remove edit button
        //editButt.deActiveAnchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width/2 - view.frame.height * 0.0222, bottom: view.frame.height*0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        //constraints for the buttons
        changePhotoButt.anchor(top: profileImageView.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: profileImageView.frame.width/2 - view.frame.height * 0.0222, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.04))
        saveButton.anchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width / 2 + view.frame.height * 0.0333, bottom: view.frame.height * 0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        //cancel button
        cancelButton.anchor(top: nil, leading: nil, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: view.frame.height * 0.03, right: view.frame.width / 2 + view.frame.height * 0.0333), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))

    }
    
    //get user pseudo
    /*
    func getOwnPseudo() -> String {
        var ownPseudo = ""
        Database.database().reference(withPath: "Usernames").child(user!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
            DispatchQueue.main.async{
                ownPseudo = snapshot.value as! String
                print("Pseudo is \(ownPseudo)")
            }
        })
        return ownPseudo
    }
    */
    
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
    
    //display user bio on screen
    func retrieveBio() {
        let databaseReference = Database.database().reference(withPath: "Users")
        //gather usr bio from database
        databaseReference.child("UserID: \(user!.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChildren() {
                for child in snapshot.children {
                    let subSnap = child as! DataSnapshot
                    //get child key
                    let key = subSnap.key
                    if key == "User Bio"{
                        DispatchQueue.main.async {
                            //display his bio in application
                            self.bioText.text = subSnap.value as? String
                            //if user has not edited his bio and it is the one by default
                            if self.bioText.text == "No description yet" {
                                self.bioText.textColor = .lightGray
                            }
                        }
                    }
                }
            }
        })
    }
    
    //retrieve profile picture from firebase storage
    func retrieveProfilePic() {
        let ownProfilePicRef = profilePicRef.child("User: \(user!.uid)")
        //gather his pic
        ownProfilePicRef.getData(maxSize: Int64(maxPicSize), completion: { imData, error in
            if let error = error {
                //if an error has error tell user
                self.showErrorController(error: "\(error.localizedDescription) Could not load profile pic sorry")
            } else {
                //transform data from storage to image if no errors
                self.profileImageView.image = UIImage(data: imData!)
            }
        })
    }
    

    //functions for badges only have badges for reviews and gives corresponding image string
    func reviewBadge (numberReviews: Int) -> String {
        var badgeLevel = ""
        switch true {
        case (numberReviews >= 10):
            badgeLevel = "greenlaurelwreathonestar"
            return badgeLevel
        case (numberReviews >= 50):
            badgeLevel = "greenlaurelwreathtwostars"
            return badgeLevel
        case (numberReviews >= 100):
            badgeLevel = "greenlaurelwreaththreestars"
            return badgeLevel
        default:
            badgeLevel = ""
            badge1Display = false
            return badgeLevel
        }
    }
    
    //functions for badges for creations it gives the string corresponding to the right badge
    func createBadge (numberCreations: Int) -> String {
        var badgeLevel = ""
        switch true {
        case (numberCreations >= 5):
            badgeLevel = "firstbadgereview"
            return badgeLevel
        case (numberCreations >= 20):
            badgeLevel = "secondbadgereview"
            return badgeLevel
        case (numberCreations >= 50):
            badgeLevel = "thirdbadgereview"
            return badgeLevel
        default:
            badgeLevel = ""
            badge2Display = false
            return badgeLevel
        }
    }
    
    //MARK: - Constraints for view
    func setConstraintsOwnProfile() {
        
        //for own pseudo
        ownPseudoLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: 20, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.1444, height: view.frame.height * 0.03))
        
        //profile pic
        profileImageView.anchor(top: ownPseudoLabel.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.1444, height: view.frame.height * 0.1444))
        
        
        //change photo button
        //changePhotoButt.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 265, left: 20, bottom: 0, right: 0), size: .init(width: 130, height: 30))
        //changePhotoButt.anchor(top: ownPseudoLabel.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: ownPseudoLabel.trailingAnchor, padding: .init(top: 230, left: 0, bottom: 0, right: 0), size: .init(width: 130, height: 40))
        
        //bio label
        bioLabel.anchor(top: profileImageView.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.05, left: 0, bottom: 0, right: 20), size: .init(width: 0, height: view.frame.height * 0.03))
        
        //bio text
        bioText.anchor(top: bioLabel.bottomAnchor, leading: ownPseudoLabel.leadingAnchor, bottom: nil, trailing: bioLabel.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.175))
        
        //activity label
        activityLabel.anchor(top: bioText.bottomAnchor, leading: bioText.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.05, left: 0, bottom: 0, right: view.frame.width/2), size: .init(width: 0, height: view.frame.height * 0.03))
        
        //activity tex
        activityText.anchor(top: activityLabel.bottomAnchor, leading: activityLabel.leadingAnchor, bottom: nil, trailing: activityLabel.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.175))
        
        //badge label
        badgesEarnedLabel.anchor(top: activityLabel.topAnchor, leading: activityLabel.trailingAnchor, bottom: activityLabel.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 30, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        
        //badge image view 1
        badgeImageView1.anchor(top: activityText.topAnchor, leading: activityLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        
        //badge image view 2
        badgeImageView2.anchor(top: badgeImageView1.bottomAnchor, leading: activityLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        
          //readd edit button
        editButt.anchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width/2 - view.frame.height*0.0222, bottom: view.frame.height*0.03, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
        
        //button holder view
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))

        //usersfriend count
        userFriendsCount.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 15, left: view.frame.width / 2 , bottom: 0, right: 10), size: .init(width: 0, height: 60))
        
        //save button
        //saveButton.anchor(top: editButt.topAnchor, leading: editButt.leadingAnchor, bottom: editButt.bottomAnchor, trailing: editButt.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: view.frame.width / 4))
        
        //cancel button
        //cancelButton.anchor(top: editButt.topAnchor, leading: editButt.leadingAnchor, bottom: editButt.bottomAnchor, trailing: editButt.trailingAnchor, padding: .init(top: 0, left: view.frame.width / 4, bottom: 0, right: 0))
    }
}


//MARK: - UIImagePicker Delegate, Navigation delegate
//to let user pick his profile pic from his photos or his camera
extension OwnUserProfile: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //display where to choose photo from
    @objc func showImagePickerControllerActionSheet() {
        //lets choose from library
        let photoLibrary = UIAlertAction(title: "Choose from library", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        //or camera
        let cameraLibrary = UIAlertAction(title: "Take a pic from camera", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        //or cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(style: .actionSheet, title: "Choose your image", message: nil, actions: [photoLibrary, cameraLibrary, cancelAction], completion: nil)
    }
    
    // show library
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //save image on firebase storage upon selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //if image has been edited
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
            
            //transform image to data
            guard let _ = profileImageView.image, let imageData = profileImageView.image?.jpegData(compressionQuality: 1.0) else{
                showErrorController(error: "Something went wrong")
                return
            }
            
            //get bytes of images
            let numBytes = imageData.count
            
            //if image too large then stop and tell user it is too big
            if numBytes > maxPicSize {
                print("IMAGE BYTES : \(numBytes)")
                self.showErrorController(error: "Please upload a photo of less than 4Mb")
                //dismiss image picker
                dismiss(animated: true, completion: nil)
                //exit as we do not accept more than 4Mb photos
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
            
        //if it is original image
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImageView.image = originalImage
            let imageData = profileImageView.image?.jpegData(compressionQuality: 1.0)
            print("Image Data \(String(describing: imageData))")
            //retrieve user ID from firebase
            let user = Auth.auth().currentUser
            if let user = user {
                let userUid = user.uid
                print("UserID: \(userUid)")
                let userProfilePicRef = profilePicRef.child("UserID: \(userUid)")
                userProfilePicRef.putData(imageData!, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    return
                    }
                }
            }
        }
        //dismiss image picker
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - text view delegate
extension OwnUserProfile: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //if textView.textColor == UIColor.lightGray {
        /*if textView == bioText {
            textView.text = ""
            textView.textColor = UIColor.white
        }*/
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        var boolToReturn = false
        if textView == userFriendsCount {
            //go to connections list when tapping on the text view containing the number of connections
            performSegue(withIdentifier: "goToConnections", sender: textView)
            boolToReturn = false
        }
        else if textView == bioText && pressedPencil == true {
            if textView.text == "No description yet" {
                textView.textColor = .white
                textView.text = ""
            }
            textView.textColor = .white
            boolToReturn = true
        }
        return boolToReturn
    }
}

//MARK: - UITabBar Delegate
extension OwnUserProfile: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "profileToConnections", sender: item)
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "profileToMap", sender: item)
            //go to map
        }
        else {
            //do nothing as we are in map
        }
    }
}
