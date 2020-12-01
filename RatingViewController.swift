//
//  RatingViewController.swift
//  HammockUP
//
//  Created by Anthony Guillard on 14/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import GoogleMaps
import Cosmos
import TinyConstraints
import Firebase
import MGSwipeTableCell

class RatingViewController: UIViewController {
    
    //MARK: - Gloabl class variables
    //rating stars variable
    lazy var cosmosView: CosmosView = {
        var stars = CosmosView()
        stars.settings.fillMode = .half
        stars.settings.starSize = Double(view.frame.width/8)
        stars.settings.starMargin = 5
        stars.settings.filledColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        stars.settings.emptyColor = .white
        stars.settings.emptyBorderColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        stars.settings.filledBorderColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        //stars.settings.filledImage = UIImage(named: "staricon")
        //stars.settings.emptyImage = UIImage(named: "emptystaricon")
        stars.settings.disablePanGestures = true
        return stars
    }()
    
    //description of spot to ask user to comment or review
    lazy var DescripSpot : UITextView = {
        var textView = UITextView()
        textView.layer.cornerRadius = 10.0
        textView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        textView.textColor = .white
        textView.text = "Review the spot for your fellow Pachas 😊"
        textView.font = UIFont(name: "Rockwell", size: 24.0)
        textView.textAlignment = .center
        textView.isEditable = false
        return textView
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
    
    //initialize given user rating
    var userRating = 0.0
    //create reference to firebase database for hammockung spots
    let hammockingSpotsReference = Database.database().reference(withPath: "Hammocking Spots")
    let kayakingSpotsReference = Database.database().reference(withPath: "Kayaking Spots")
    let hikingSpotsReference = Database.database().reference(withPath: "Hiking Spots")
    let pointOfViewSpotsReference = Database.database().reference(withPath: "Point of View Spots")
    let fitnessSpotsReference = Database.database().reference(withPath: "Fitness Spots")
    //reference to user usernames
    let usernamesReference = Database.database().reference(withPath: "Usernames")
    //reference to users
    let usersReference = Database.database().reference(withPath: "Users")
    //marker empty to get value of tapped marker in mapViewController
    var passingMarker = GMSMarker()
    
    //define save and cancel buttons for comments
    lazy var saveCommentButton: UIButton = {
        var button = UIButton()
        //button.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        button.setImage(UIImage(named: "line"), for: .normal)
        //button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        //button.layer.cornerRadius = 2.0
        button.tintColor = .white
        button.addTarget(self, action: #selector(saveComment), for: .touchUpInside)
        //button.titleLabel?.font = UIFont(name: "Avenir", size: 16.0)
        return button
    }()
    
    //what other had to say abut this place label
    lazy var commentsLabel: UILabel = {
        let label = UILabel()
        var constraintTest = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        label.textColor = .white
        label.text = "Comments:"
        label.font = UIFont(name: "Avenir-Heavy", size: 18.0)
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        return label
    }()
    
    //comment user section
    lazy var userCommentField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textField.font = UIFont(name: "Avenir", size: 16.0)
        textField.textColor = .lightGray
        textField.layer.cornerRadius = 17.0
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        textField.text = "  Enter your comment here"
        textField.isEditable = true
        textField.delegate = self
        return textField
    }()
    
    //delete spot button
    lazy var deleteMarkerButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "trash"), for: .normal)
        button.addTarget(self, action: #selector(deleteMarker), for: .touchUpInside)
        return button
    }()
    
    //save rating spot button
    lazy var saveRatingButton : UIButton = {
        let button = UIButton()
        //button.setTitle("Save rating", for: .normal)
        //button.layer.cornerRadius = 5.0
        //button.tintColor = .white
        button.setImage(UIImage(named: "checkmark"), for: .normal)
        //button.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
        //button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        button.addTarget(self, action: #selector(saveRating), for: .touchUpInside)
        return button
    }()
    
    //swipe right gesture to go back to map
    //lazy var swipeRightToMap: UISwipeGestureRecognizer = {
      //  let gesture = UISwipeGestureRecognizer(target: self, action: #selector(cancelRating))
        //gesture.direction = .right
        //return gesture
    //}()
    
    //get currently connected user id
    let currentUserUid = Auth.auth().currentUser!.uid
    //comments array
    var comments: [String] = []
    //usernames for the ones who commented
    var usernames: [String] = []
    
    public func decideReferenceToUse(passedMarker: GMSMarker) -> DatabaseReference {
        //for the refereence to use
        var referenceToUse = DatabaseReference()
        switch passedMarker.icon {
        case UIImage(named: "pinHammock"):
            referenceToUse = hammockingSpotsReference
            break
        case UIImage(named: "pinHike"):
            referenceToUse = hikingSpotsReference
            break
        case UIImage(named: "pinKayak"):
            referenceToUse = kayakingSpotsReference
            break
        case UIImage(named: "pinBinoculars"):
            referenceToUse = pointOfViewSpotsReference
            break
        case UIImage(named: "pinFitness"):
            referenceToUse = fitnessSpotsReference
            break
        default:
            referenceToUse = hammockingSpotsReference
            print("belongs to no Image")
            break
        }
        return referenceToUse
    }
    
    //MARK: - load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        
        //get all comments to display on table view
        retrieveAllComments()
        //add star rating to view and place it in the middle
        view.addSubview(cosmosView)
        //add description of spot to view
        view.addSubview(DescripSpot)
        view.addSubview(commentsLabel)
        //view.addSubview(commentButton)
        view.addSubview(saveCommentButton)
        //view.addSubview(cancelRatingButton)
        view.addSubview(saveRatingButton)
        view.addSubview(deleteMarkerButton)
        view.addSubview(userCommentField)
        view.addSubview(saveCommentButton)
        view.addSubview(buttonHolder)
        
        //cosmosView.centerInSuperview()
        cosmosView.didFinishTouchingCosmos = {rating in
            self.userRating = rating
        }
        
        //to implement delegat data source extension
        commentsTableView.dataSource = self
        //delegate protoocol
        commentsTableView.delegate = self
        commentsTableView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        commentsTableView.tableFooterView = UIView()
        
        //add gesture
        setConstraintsRating()
        //view.addGestureRecognizer(swipeRightToMap)
        
        buttonHolder.delegate = self
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //saveRating function
    @objc func saveRating(_ sender: UIButton) {
        performSegue(withIdentifier: "saveToMap", sender: sender)
        sender.reloadInputViews()
    }
    
    //deleteMarker function segue
    @objc func deleteMarker(_ sender: UIButton) {
        
        //display alert
        let userConfirmation = UIAlertController(title: "Warning", message: "Are you sure you want to delete this spot?", preferredStyle: .alert)
        
        //confirm action
        userConfirmation.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            //perform segue to go back to map and delete spot
            self.performSegue(withIdentifier: "deleteToMap", sender: sender)
            sender.reloadInputViews()
        }))
        //cancel action
        userConfirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(userConfirmation, animated: true, completion: nil)
    }
    
    //cancel rating function
   // @objc func cancelRating(_ sender: UISwipeGestureRecognizer) {
     //   performSegue(withIdentifier: "cancelToMap", sender: sender)
        //sender.reloadInputViews()
    //}
    
    //MARK: - Navigation
    //transfer array of marker data to rating view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cancelToMap"{
            // do nothing it is the cancel button
        }
        else if segue.identifier == "saveToMap" {// save button so save the marker on the map and display it
            
            //when pressing save, it saves the marker thanks to firebase
            //print("marker loop: \(passingMarker)")
            
            //MapVC.rateToDisplay = self.userRating
            //print("rating value: \(self.userRating)")
            
            // create a child reference to hammocking spots to store the markerID
            // the name of this reference is iD: then the name of its ID is given by the marker's latitude and its longitude together
            //set ID value to pass to the database
            var latID = passingMarker.position.latitude * Double(1000000)
            latID = latID.rounded()
            let latIntID = Int(latID)
            var longID = passingMarker.position.longitude * Double(1000000)
            longID = longID.rounded()
            let longIntID = Int(longID)
            let passingMarkerID = "\(latIntID)\(longIntID)"
            let referenceToUse = decideReferenceToUse(passedMarker: passingMarker)
            let markerIDsReference = referenceToUse.child("Marker ID: \(passingMarkerID)")
            //markerIDsReference.setValue(passingMarkerID)
            
            //create a child reference to markerIDsRefference to store the chosen marker corresponding to the ID
            let markerLatitudeReference = markerIDsReference.child("GMS Marker latitude")
            let markerLongitudeReference = markerIDsReference.child("GMS Marker longitude")
            //set gms marker corresponding lat and long to its corresponding ID
            
            //markerLatitudeReference.setValue(passingMarker.position.latitude)
            //markerLongitudeReference.setValue(passingMarker.position.longitude)

            // create a child reference to markerIDs to store its rating
            let ratingOfSpotReference = markerIDsReference.child("Place Rating")
            
            //create a child reference to marker ID
            let numberRatingsReference = markerIDsReference.child("Number of reviews")
            
            // gather users rating and increments it to previous
            //var newRate = computeRatingSpot(rate: self.userRating, otherUserRate: , numberVotes: )//to review)
            
            // define other user review variable
            var allUsersReview = 0.0
            // define number of reviews variable
            var numberOfReviews = 0
            
            // Set Review values (new one or average with old ones)
            markerIDsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                // if marker ID has children it means this marker has already been created
                if snapshot.hasChildren() {
                    for child in snapshot.children {
                        let subSnap = child as! DataSnapshot
                        //get child key
                        let key = subSnap.key
    
                    // if key is for review grade and is a double
                    if key == "Place Rating" {
                        if let val = subSnap.value as? Double {
                            allUsersReview = val
                        }
                    }
                        
                    //if key is for number of reviews and is an integer
                    else if key == "Number of reviews"{
                        if let val = subSnap.value as? Int {
                            numberOfReviews = val
                        }
                    }
                 }
                     // if there are no modifications on users review and number of reviews mean spots have not yet been marked so set number of reviews to 1 and the rating as the one given by the user
                     if allUsersReview == 0.0 && numberOfReviews == 0 {
                        markerIDsReference.updateChildValues(["Place Rating": self.userRating, "Number of reviews": 1])
                     }
                     else {
                         // change otherUserRate with rates obtained in mapview controller
                        let newRating = self.computeRatingSpot(rate: self.userRating, otherUserRate: allUsersReview, numberVotes: numberOfReviews)
                        //update place rating and number of reviews without overwriting the coordinates so the whole node
                        markerIDsReference.updateChildValues(["Place Rating": newRating, "Number of reviews": numberOfReviews + 1])
                        //add review activity to user
                        self.updateReviewActivity()
                        }
                    }
                else {
                    //if it does not have children, this is the first time this marker is created so add its coordinates as well as the user rating
                    numberRatingsReference.setValue(1)
                    ratingOfSpotReference.setValue(self.userRating)
                    markerLatitudeReference.setValue(self.passingMarker.position.latitude)
                    markerLongitudeReference.setValue(self.passingMarker.position.longitude)
                    //add review to activity of user
                    self.updateReviewActivity()
                    //and to creation ofuser spot
                    self.updateCreateActivity()
                    
                    //get current user and put him as creator of spot
                    let user = Auth.auth().currentUser
                    //gather username of authentified user
                    Database.database().reference(withPath: "Users").child("UserID: \(user!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                        for child in snapshot.children {
                            let snap = child as! DataSnapshot
                            if snap.key == "Pseudo" {
                                markerIDsReference.child("Creator of Spot").setValue(snap.value)
                            }
                        }
                    })
                }
            })
        }
        // if delete marker button is pressed
        else if segue.identifier == "deleteToMap" {
            
           // let MapVC: MapViewController = segue.destination as! MapViewController
            //when delete button, put whole node value to nil to remove it
            var latID = passingMarker.position.latitude * Double(1000000)
            latID = latID.rounded()
            let latIntID = Int(latID)
            var longID = passingMarker.position.longitude * Double(1000000)
            longID = longID.rounded()
            let longIntID = Int(longID)
            let passingMarkerID = "\(latIntID)\(longIntID)"
            // need to incorporate system to give 2 tokens per day per user to limit unwanted deletes
            let referenceToUse = decideReferenceToUse(passedMarker: passingMarker)
            let markerIDsReference = referenceToUse.child("Marker ID: \(passingMarkerID)")
            markerIDsReference.setValue(nil)
            //update delete activity of user 
            updateDeleteActivity()
        }
    }
    
    //compute new rating of spot
    func computeRatingSpot(rate: Double, otherUserRate: Double, numberVotes: Int) -> Double
    {
        //compute other users review
        var usersRate = otherUserRate * Double(numberVotes)
        //add to it the current user's review
        usersRate = usersRate + rate
        
        //return new rate of hammocking spots
        return usersRate / Double(numberVotes + 1)
    }
    
    //retrieve all comments regarding this place as well as who reviewed it
    func retrieveAllComments() {
        //gather comments
        //set value of user comment in the firebase database
        //set ID value to pass to the database
        var latID = passingMarker.position.latitude * Double(1000000)
        latID = latID.rounded()
        let latIntID = Int(latID)
        var longID = passingMarker.position.longitude * Double(1000000)
        longID = longID.rounded()
        let longIntID = Int(longID)
        let passingMarkerID = "\(latIntID)\(longIntID)"
        let referenceToUse = decideReferenceToUse(passedMarker: passingMarker)
        //reference to comments to get the number of comments for this spot
        referenceToUse.child("Marker ID: \(passingMarkerID)").child("Comments").observeSingleEvent(of: .value, with: {(snapshot) in
            //get number of children to retrieve number of comments
            for child in snapshot.children {
                let node = child as! DataSnapshot
                //append the found comment
                self.comments.append(node.value as! String)
                //get username found from the comment
                self.usernamesReference.child(node.key).observeSingleEvent(of: .value, with: {(snappy) in
                    self.usernames.append(snappy.value as! String)
                    //reload table view
                    DispatchQueue.main.async {
                        self.commentsTableView.reloadData()
                    }
                })
            }
        })
    }
    
    //save comment function
    @objc func saveComment(_ sender: UIButton) {
        
        //save comment if the user typed more than 10 characters
        if userCommentField.text!.count >= 10 {
            //identify which marker this corresponds to
            // the name of this reference is iD: then the name of its ID is given by the marker's latitude and its longitude together
            //set ID value to pass to the database
            var latID = passingMarker.position.latitude * Double(1000000)
            latID = latID.rounded()
            let latIntID = Int(latID)
            var longID = passingMarker.position.longitude * Double(1000000)
            longID = longID.rounded()
            let longIntID = Int(longID)
            let passingMarkerID = "\(latIntID)\(longIntID)"
            let referenceToUse = decideReferenceToUse(passedMarker: passingMarker)
            //set value of user comment in the firebase database
            referenceToUse.child("Marker ID: \(passingMarkerID)").child("Comments").child("\(currentUserUid)").setValue(userCommentField.text)
            userCommentField.text = ""
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
            
            //remove cancel and save comment button from the view
            //cancelCommentButton.removeFromSuperview()
            //saveCommentButton.removeFromSuperview()
            //readd comment button
            //view.addSubview(commentButton)
        }
        else {
            //if comment less than 10 characters tell user that it needs to be 10 characters or more
            let smallCommentAlert = UIAlertController(title: "Comment too short", message: "Please type in a comment longer than 10 characters", preferredStyle: .alert)
            smallCommentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(smallCommentAlert, animated: true)
            
            //remove cancel and save comment button from the view
            //cancelCommentButton.removeFromSuperview()
            //readd comment button
            //view.addSubview(commentButton)
        }
    }
    
    
    //where comments are nested
    @IBOutlet var commentsTableView: UITableView!
    
    
    //update reviewing activity
    func updateReviewActivity() {
        //gather previous total activity
        var reviews = 0.0
        
        usersReference.child("UserID: \(currentUserUid)").child("User Activity").child("Number of Spots reviewed").observeSingleEvent(of: .value, with: {(snapshot) in
            reviews = snapshot.value as! Double
            //save for total activity purposes
            self.usersReference.child("UserID: \(self.currentUserUid)").child("User Activity").updateChildValues(["Number of Spots reviewed": reviews + 1])
        })
    }
    
    //update creating spot activity
    func updateCreateActivity() {
        //gather previous total activity
        var creations = 0
        
        usersReference.child("UserID: \(currentUserUid)").child("User Activity").child("Number of Spots created").observeSingleEvent(of: .value, with: {(snapshot) in
            creations = snapshot.value as! Int
            //save for total activity purposes
            self.usersReference.child("UserID: \(self.currentUserUid)").child("User Activity").updateChildValues(["Number of Spots created": creations + 1])
        })
    }
    
    //update deleting spot activity
    func updateDeleteActivity() {
        //gather previous total activity
        var deletions = 0
        
        usersReference.child("UserID: \(currentUserUid)").child("User Activity").child("Number of Spots deleted").observeSingleEvent(of: .value, with: {(snapshot) in
            deletions = snapshot.value as! Int
            //save for total activity purposes
            self.usersReference.child("UserID: \(self.currentUserUid)").child("User Activity").updateChildValues(["Number of Spots deleted": deletions + 1])
        })
    }
    
    //MARK: - Constraints for view
    func setConstraintsRating() {
        
        //review spot for users
        DescripSpot.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height * 0.088888))
        
        //cosmos view
        cosmosView.anchor(top: DescripSpot.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.04444, left: -12.5 + 0.1875 * view.frame.width, bottom: 0, right:  0.1875 * view.frame.width), size: .init(width: 0, height: 50))
        
        //delete spot button
        deleteMarkerButton.anchor(top: cosmosView.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: view.frame.height * 0.04444, left: view.frame.width/2 - 70, bottom: 0, right: 0), size: .init(width: 40, height: 40))
        
        //save rating button
        saveRatingButton.anchor(top: cosmosView.bottomAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.04444, left: 0, bottom: 0, right: view.frame.width/2 - 70), size: .init(width: 40, height: 40))
        
        //comments label
        commentsLabel.anchor(top: deleteMarkerButton.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height * 0.045, left: 15, bottom: 0, right: 0), size: .init(width: 0, height: 25))
        
        //comments table view
        commentsTableView.anchor(top: commentsLabel.bottomAnchor, leading: view.leadingAnchor, bottom: userCommentField.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        
        //comment field
        userCommentField.anchor(top: nil, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 20, right: 50), size: .init(width: 0, height: 45))
    
        //save comment button
        saveCommentButton.anchor(top: userCommentField.topAnchor, leading: userCommentField.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 45, height: 45))
        
        //button holder
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))
    }
}

//MARK: - Table view delegate
extension RatingViewController: UITableViewDataSource, UITableViewDelegate {

    //number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number of rows given by the number of comments
        if comments.count != 0 {
            return comments.count
        }
        // if there are no comments regarding this place, add one cell that will say that there arr eno comments yet and user can be the firsty one
        else {
            return 1
        }
    }

    //height of a given cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    //display users on table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //initiate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //cell properties
        cell.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)//UIColor.init(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 55/2
        
        //if there are comments regarding this place follow this guideline
        if comments.count != 0 {
            //detail text label is equal to the comment given in specific row
            if comments.isEmpty == false {
                cell.detailTextLabel?.text = comments[indexPath.row]
                cell.detailTextLabel?.textColor = .white
                cell.detailTextLabel?.font = UIFont(name: "Avenir", size: 16.0)
            }
            if usernames.isEmpty == false {
                cell.textLabel?.text = usernames[indexPath.row]
                cell.textLabel?.textColor = .white
                cell.textLabel?.font = UIFont(name: "Avenir-Heavy", size: 16.0)
            }
        }
        else {
            cell.textLabel?.text = "No comments yet, feel free to be the first!"
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.font = UIFont(name: "Avenir", size: 16.0)
            cell.detailTextLabel?.text = ""
            cell.detailTextLabel?.textColor = .white
        }
        return cell
    }

    //when user touches a certain row in the table view --> deselect the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      //  cell.backgroundColor = UIColor.green
    //}
}


//MARK: - text view delegate
extension RatingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.white
        //}
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = "  Enter your comment here"
        textView.textColor = .lightGray
    }
}

//MARK: - Tab bar delegate
extension RatingViewController: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "ratingToConnections", sender: item)
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "ratingToMap", sender: item)
        }
        else {
            //go to profile
            performSegue(withIdentifier: "ratingToProfile", sender: item)
        }
    }
}
