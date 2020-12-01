//
//  OtherUserProfiles.swift
//  HammockUP
//
//  Created by Anthony Guillard on 29/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Firebase

class OtherUserProfiles: UIViewController {
    
    //MARK: - Global class variables
    let databaseReference = Database.database().reference(withPath: "Users")
    let usernameReference = Database.database().reference(withPath: "Usernames")
    
    //friend button
    lazy var friendButt: UIButton = {
        let button = UIButton(frame: CGRect(x: 20, y: 190, width: 130, height: 40))
        button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        button.layer.cornerRadius = 5.0
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    var searchedUserPseudo = ""
    //reference to storage of profile pictures
    let profilePicRef = Storage.storage().reference(withPath: "User Profile Pictures")
    let maxPicSize = 4 * 1000 * 1000 //4 Mb
    // get current user
    let currentUser = Auth.auth().currentUser
    
    //profile picture
    lazy var userProfilePic: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width*0.1444, height: view.frame.height*0.1444))
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height/2
        return imageView
    }()
    
    //define bio text
    lazy var userBioText: UITextView = {
        let textField = UITextView()
        //make text fields unmodifiable
        textField.isEditable = false
        textField.font = UIFont(name: "Avenir", size: 16.0)
        textField.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textField.layer.cornerRadius = 10.0
        textField.textColor = .white
        return textField
    }()
    
    //bio label
    lazy var userBio: UILabel = {
        let label = UILabel()
        label.text = "Few words about myself:"
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        return label
    }()
    
    //total activity text
    lazy var activityText: UITextView = {
        let textField = UITextView()
        //make text fields unmodifiable
        textField.isEditable = false
        textField.font = UIFont(name: "Avenir", size: 16.0)
        textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textField.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        textField.layer.cornerRadius = 10.0
        textField.textColor = .white
        //activity text
        //get searched useruid
        var searchedUserUid = ""
        var reviews = 0
        var creations = 0
        var deletions = 0
        usernameReference.observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                if subSnap.value as! String == self.searchedUserPseudo {
                    searchedUserUid = subSnap.key
                    self.databaseReference.child("UserID: \(searchedUserUid)").child("User Activity").observeSingleEvent(of: .value, with: {(snapshot) in
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
                                textField.text = "Reviewed \(reviews) spots\n\nCreated \(creations) spots \n\nDeleted \(deletions) spots"
                            }
                            return
                        }
                    })
                }
            }
        })
        return textField
    }()
    
    //activity label
    lazy var activity: UILabel = {
        let label = UILabel()
        label.text = "User activity:"
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        return label
    }()
    
    //tab bar that holds the buttons
    lazy var buttonHolder: UITabBar = {
        let tabBar = UITabBar()
        tabBar.backgroundColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)
        tabBar.barTintColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)
        tabBar.itemPositioning = .fill
        tabBar.unselectedItemTintColor = UIColor(red: 185/255, green: 187/255, blue: 182/255, alpha: 1)

        //create button items
        let communityButton = UITabBarItem(title: "", image: UIImage(named: "group"), selectedImage: UIImage(named: "group"))
        let hammockButton = UITabBarItem(title: "", image: UIImage(named: "map"), selectedImage: UIImage(named: "map"))
        let profileButton = UITabBarItem(title: "", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))
        
        //tags
        communityButton.tag = 1 //first button
        hammockButton.tag = 2 // second button
        profileButton.tag = 3 //third button
        tabBar.items = [communityButton, hammockButton, profileButton]
        tabBar.isTranslucent = true
        return tabBar
    }()
    
    //user pseudo to display
    lazy var userPseudoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = searchedUserPseudo
        return label
    }()
    
    //earned badges label
    lazy var badgesEarnedLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.textColor = .white
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.text = "Badges earned:"
       return label
    }()
    
    //creator badge to display
    lazy var badgeImageView1: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width - 80, y: 540, width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        //choose which image to display
        //get searched useruid
        var searchedUserUid = ""
        var creations = 0
        usernameReference.observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                if subSnap.value as! String == self.searchedUserPseudo {
                    searchedUserUid = subSnap.key
                    self.databaseReference.child("UserID: \(searchedUserUid)").child("User Activity").observeSingleEvent(of: .value, with: {(snapshot) in
                        for child in snapshot.children {
                            let subSnap = child as! DataSnapshot
                            //gather number of spots created
                            if subSnap.key == "Number of Spots created" {
                                creations = subSnap.value as! Int
                                //get which badge to display
                                let badgeType = self.createBadge(numberCreations: creations)
                                DispatchQueue.main.async{
                                    //if badge is not earned do not display or charge it maybe a text instead
                                    if badgeType == "" {
                                        
                                    }
                                    //if the badge is earned then display it
                                    else {
                                        imageView.image = UIImage(named: badgeType)
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
        return imageView
    }()
    
    //reviewer badge to display
    lazy var badgeImageView2: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width - 80, y: 540 + 90, width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        //choose which image to display
        //get searched useruid
        var searchedUserUid = ""
        var reviews = 0
        usernameReference.observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                if subSnap.value as! String == self.searchedUserPseudo {
                    searchedUserUid = subSnap.key
                    self.databaseReference.child("UserID: \(searchedUserUid)").child("User Activity").observeSingleEvent(of: .value, with: {(snapshot) in
                        for child in snapshot.children {
                            let subSnap = child as! DataSnapshot
                            //gather number of spots created
                            if subSnap.key == "Number of Spots reviewed" {
                                reviews = subSnap.value as! Int
                                //get which badge to display
                                let badgeType = self.reviewBadge(numberReviews: reviews)
                                DispatchQueue.main.async {
                                    // if the badge is not earned then dispkay text or nothing
                                    if badgeType == "" {
                                        
                                    }
                                    //if the badge is earned display it
                                    else {
                                        imageView.image = UIImage(named: badgeType)
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
        return imageView
    }()
    
    
    //MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        
        //add buttons, labels, text to the view
        view.addSubview(userPseudoLabel)
        view.addSubview(userProfilePic)
        view.addSubview(userBio)
        view.addSubview(userBioText)

        view.addSubview(activity)
        view.addSubview(activityText)
        view.addSubview(badgesEarnedLabel)
        view.addSubview(badgeImageView1)
        view.addSubview(badgeImageView2)
        view.addSubview(buttonHolder)

        //load functions to display
        retrieveBio()
        retrieveProfilePic()
        friendButton()
        
        //delegate for tab bar
        buttonHolder.delegate = self
        
        //add constraints
        setConstraintOtherProfile()
    }
    
    //friend button
    func friendButton() {
        //gather usr bio from database
        //get user uid profile
        var retrievedPseudo = "" //obtained pseudo of database
        var friendWith = false // check if user we are with is
        var requestReceived = false //whether we received a request from the person who we are looking the profile of
        //avoid displaying friend button if user viewing own profile
        usernameReference.child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //gather connected user name
            retrievedPseudo = snapshot.value as! String
            
            //if user profile is different than our own
            if retrievedPseudo != self.searchedUserPseudo {
                //retrieve user friends, because if user is a friend then do not add button to add as a friend
                self.databaseReference.child("UserID: \(self.currentUser!.uid)").child("Friends with").observeSingleEvent(of: .value, with: { (snapshot2) in
                    for child in snapshot2.children {
                        let snap = child as! DataSnapshot
                        //if we see this person's pseudo in the node this means we are friends
                        //hence do not add allow the connect button to be pressed but display connected
                        if snap.value as! String == self.searchedUserPseudo {
                            friendWith = true
                            DispatchQueue.main.async {
                                self.friendButt.setTitle("Connected", for: .normal)
                                self.friendButt.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
                                self.friendButt.isUserInteractionEnabled = false
                                self.view.addSubview(self.friendButt)
                                self.friendButt.anchor(top: self.userPseudoLabel.topAnchor, leading: self.userPseudoLabel.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 2 * self.view.frame.width / 3, bottom: 0, right: 10), size: .init(width: 0, height: 40))
                                //and exit to be quicker
                                return
                            }
                        }
                    }//end of for grandchild in snapshot2.children
                    //if we are not friends with this person we can connect with her/him by adding the button to the view and make it interactable or we can accept the request if he sent a request
                    if friendWith == false {
                        self.databaseReference.child("UserID: \(self.currentUser!.uid)").child("Received Connection Requests From").observeSingleEvent(of: .value, with: { (snappy) in
                            for i in snappy.children {
                                let subSnappy = i as! DataSnapshot
                                //if username is in our connection requests
                                if subSnappy.value as! String == self.searchedUserPseudo {
                                    requestReceived = true
                                    DispatchQueue.main.async {
                                        self.friendButt.setTitle("Accept Request", for: .normal)
                                        self.friendButt.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
                                        self.view.addSubview(self.friendButt)
                                        self.friendButt.anchor(top: self.userPseudoLabel.topAnchor, leading: self.userPseudoLabel.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 2 * self.view.frame.width / 3, bottom: 0, right: 10), size: .init(width: 0, height: 40))
                                        self.friendButt.isUserInteractionEnabled = true
                                        //accept friend requets button and the method of accept from other VC
                                        self.friendButt.addTarget(self, action: #selector(self.btnAcceptConnection), for: .touchUpInside)
                                        //self.friendButt.setTitle("Connected", for: .normal)
                                        return
                                    }
                                }
                            }
                            if requestReceived == false { // if he didnt ask us to be a connection then we propose the option to add this user
                                DispatchQueue.main.async {
                                    self.friendButt.setTitle("Connect", for: .normal)
                                    self.view.addSubview(self.friendButt)
                                    self.friendButt.anchor(top: self.userPseudoLabel.topAnchor, leading: self.userPseudoLabel.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 2 * self.view.frame.width / 3, bottom: 0, right: 10), size: .init(width: 0, height: 40))

                                    self.friendButt.isUserInteractionEnabled = true
                                    self.friendButt.addTarget(self, action: #selector(self.sendConnectionRequest), for: .touchUpInside)
                                    self.friendButt.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
                                    return
                                }//end of dispatchqueu
                            }//end of if requestreceived = false
                        })//end of received connection request closure
                    }//end of if condition on friends or not
                })//end of friends with
            }//end of if gotten pseudo from firebase different than searched pseudo
            else { //else of if gotten pseudo is different than search so this case is if they are equal
                self.friendButt.removeFromSuperview()
                //self.friendButt.deActiveAnchor(top: self.userProfilePic.bottomAnchor, leading: self.userProfilePic.leadingAnchor, bottom: nil, trailing: self.userProfilePic.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 40))
                return
            }
        })//end of closure to search for pseudo
    }//end of function
    
    //go back to previous VC
    @objc func goBackToPreviousVC (_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
       // performSegue(withIdentifier: "", sender: sender)
    }
    
    //accept request when user already sent a request
    @objc func btnAcceptConnection(_ sender: UIButton){
        //initialize retrieved pseudo that's used to match to other names in database
        var retrievedPseudo = ""
        //currently connected user pseudo
        var currUserPseudo = ""
        
        //accept friend request for connected user
        //add name of demanding user to current user's friend list
        databaseReference.child("UserID: \(currentUser!.uid)").child("Friends with").childByAutoId().setValue(searchedUserPseudo)
        // and also remove the name of the demanding person from request list
        databaseReference.child("UserID: \(currentUser!.uid)").child("Received Connection Requests From").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //if searched pseudo of demanding person is equal to the one in the table then delete this request
                if subSnap.value as! String == self.searchedUserPseudo {
                    //delete value by setting it to nil
                    self.databaseReference.child("UserID: \(self.currentUser!.uid)").child("Received Connection Requests From").child(subSnap.key).setValue(nil)
                    DispatchQueue.main.async {
                        //reload button and display it as connected
                        sender.setTitle("Connected", for: .normal)
                        sender.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
                    }
                }
            }
        })
        
        //add friend for accepted user who sent an invite
        usernameReference.observeSingleEvent(of: .value, with: { (snapshotUser) in
            //gather currently connected user username
            self.usernameReference.child(self.currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshotCurrUser) in
                currUserPseudo = snapshotCurrUser.value as! String
                for child in snapshotUser.children {
                    let subSnapUser = child as! DataSnapshot
                    //get child key
                    let key = subSnapUser.key
                    retrievedPseudo = subSnapUser.value as! String
                    if retrievedPseudo == self.searchedUserPseudo {
                        //add currently connected user to friends list of this user
                        self.databaseReference.child("UserID: \(key)").child("Friends with").childByAutoId().setValue(currUserPseudo)
                        
                        //remove sent connection to since usr has accepted it
                        self.databaseReference.child("UserID: \(key)").child("Sent Connection Requests To").observeSingleEvent(of: .value, with: { (snappy) in
                            for grandChild in snappy.children {
                                let grandSnappy = grandChild as! DataSnapshot
                                //check if the suer pseudo connected is equal to the one in the database link of the viewed profile user
                                if grandSnappy.value as! String == currUserPseudo {
                                    self.databaseReference.child("UserID: \(key)").child("Sent Connection Requests To").child(grandSnappy.key).setValue(nil)
                                }//end of if grandsnappy value is equal to current user pseudo
                            }//for grandchild in snappychildren
                        })//end of observation on sent connection request node
                    }//end of if retrieved pseudo is equal to the one of the profile viewed
                }//end of child in snapshotuserc hildren
            })//end of osbervation on its pseudo to gather the current user pseudo
        })//end of observation of usernamereference
    }//end of function
    
    //send connection function
    @objc func sendConnectionRequest(_ sender: UIButton) {
        //get user uid profile
        var retrievedPseudo = ""
        var searchedUserIDkey = ""
        //gather usr bio from database
        //gather username from database
        usernameReference.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //gather the username and see if it matches the one of the profile being displayed
                retrievedPseudo = subSnap.value as! String
                //if the username from database is equal to the one of the selected profile
                if retrievedPseudo == self.searchedUserPseudo {
                    //gather the user UID
                    searchedUserIDkey = subSnap.key
                    //acknowledge we sent request to this user
                    self.databaseReference.child("UserID: \(self.currentUser!.uid)").child("Sent Connection Requests To").childByAutoId().setValue(self.searchedUserPseudo)
                    //tell user we sent him a request and gather our pseudo to let him know
                    self.usernameReference.child(self.currentUser!.uid).observeSingleEvent(of: .value, with: { (snappy) in
                        let sendingUserPseudo = snappy.value as! String
                        // tell this user we sent him a request
                        self.databaseReference.child("UserId: \(searchedUserIDkey)").child("Received Connection Requests From").childByAutoId().setValue(sendingUserPseudo)
                        //update buttoon
                        DispatchQueue.main.async {
                            self.friendButt.setTitle("Request Sent", for: .normal)
                            self.friendButt.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
                            //user can then not interact with the button
                            self.friendButt.isUserInteractionEnabled = false
                        }
                    })//end of closure of user pseudo
                }
            }
        })
    }
    
    //display user bio on screen
    func retrieveBio() {
        var retrievedPseudo = ""
        
        //gather user bio from database
        usernameReference.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //get child key
                let key = subSnap.key
                retrievedPseudo = subSnap.value as! String
                if retrievedPseudo == self.searchedUserPseudo {
                    self.databaseReference.child("UserID: \(key)").child("User Bio").observeSingleEvent(of: .value, with: { (snapBio) in
                        DispatchQueue.main.async {
                            self.userBioText.text = snapBio.value as? String
                            //if user has not added a description and if it is still by default then grey it so user knows it can be an input
                            if self.userBioText.text == "No description yet" {
                                self.userBioText.textColor = .lightGray
                            }
                        }
                    })
                }
            }
        })
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
    
    //retrieve selected user profile picture from firebase storage
    func retrieveProfilePic() {
        var retrievedPseudo = ""
        //gather usr bio from database
        usernameReference.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                //get child key
                let key = subSnap.key
                retrievedPseudo = subSnap.value as! String
                if retrievedPseudo == self.searchedUserPseudo {
                    //then we retrieve profile picture
                    let fullKeyProfilePic = "User: " + key
                    self.profilePicRef.child(fullKeyProfilePic).getData(maxSize: Int64(self.maxPicSize), completion: { imData, error in
                        if let error = error{
                            //if an error has error tell user
                            self.showErrorController(error: "\(error.localizedDescription) Could not load profile pic sorry")
                        } else {
                            DispatchQueue.main.async{
                                //transform data from storage to image if no errors
                                self.userProfilePic.image = UIImage(data: imData!)
                                return
                            }
                        }
                    })
                }
            }
        })
    }
    
    //functions for badges only have badges for reviews and creations
    func reviewBadge (numberReviews: Int) -> String {
        var badgeLevel = ""
        switch true {
        case (numberReviews >= 100):
            badgeLevel = "Hammock expert"
            return badgeLevel
        case (numberReviews >= 50):
            badgeLevel = "Hammock enthusiast"
            return badgeLevel
        case (numberReviews >= 10):
            badgeLevel = "Hammock amateur"
            return badgeLevel
        default:
            badgeLevel = ""
            return badgeLevel
        }
    }
    
    //functions for badges for creations
    func createBadge (numberCreations: Int) -> String {
        var badgeLevel = ""
        switch true {
        case (numberCreations >= 50):
            badgeLevel = "Nature expert"
            return badgeLevel
        case (numberCreations >= 20):
            badgeLevel = "Nature seeker"
            return badgeLevel
        case (numberCreations >= 5):
            badgeLevel = "Nature amateur"
            return badgeLevel
        default:
            badgeLevel = ""
            return badgeLevel
        }
    }
    
    //MARK: - Constraints
    func setConstraintOtherProfile() {
        
        //button holder
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 85))
        
        //username label
        userPseudoLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 30, left: 20, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.1444, height: view.frame.height * 0.03))
        
        //imagepic
        userProfilePic.anchor(top: userPseudoLabel.bottomAnchor, leading: userPseudoLabel.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.1444, height: view.frame.height * 0.1444))
        
        //connect button
        //friendButt.anchor(top: userProfilePic.bottomAnchor, leading: userProfilePic.leadingAnchor, bottom: nil, trailing: userProfilePic.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 40))
        
        //bio label
        userBio.anchor(top: userProfilePic.bottomAnchor, leading: userProfilePic.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.05, left: 0, bottom: 0, right: 20), size: .init(width: 0, height: view.frame.height * 0.03))
        
        //bio text
        userBioText.anchor(top: userBio.bottomAnchor, leading: userBio.leadingAnchor, bottom: nil, trailing: userBio.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.175))
        
        //activity label
        activity.anchor(top: userBioText.bottomAnchor, leading: userBioText.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.05, left: 0, bottom: 0, right: view.frame.width/2), size: .init(width: 0, height: view.frame.height * 0.03))
        
        //activity tex
        activityText.anchor(top: activity.bottomAnchor, leading: activity.leadingAnchor, bottom: nil, trailing: activity.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.175))
        
        //badge label
        badgesEarnedLabel.anchor(top: activity.topAnchor, leading: activity.trailingAnchor, bottom: activity.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 30, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        
        //badge image view 1
        badgeImageView1.anchor(top: activityText.topAnchor, leading: activity.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
        
        //badge image view 2
        badgeImageView2.anchor(top: badgeImageView1.bottomAnchor, leading: activity.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0), size: .init(width: view.frame.height * 0.0888, height: view.frame.height * 0.0888))
    }
    
}

//MARK: - UITabBar Delegate
extension OtherUserProfiles: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "otherProfileToConnections", sender: item)
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "otherProfileToMap", sender: item)
            //go to map
        }
        else {
            performSegue(withIdentifier: "otherProfileToProfile", sender: item)
        }
    }
}
