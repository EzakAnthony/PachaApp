//
//  MapViewController.swift
//  HammockUP
//
//  Created by Anthony Guillard on 08/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import Firebase

class MapViewController: UIViewController {

    
    // MARK: - View did load
     
    override func viewDidLoad() {
        super.viewDidLoad()
        //views color (artichoke)
        //view.backgroundColor = UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        // Duplicate location Manager for user
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        //delegate mapview
        mapView.delegate = self
        view.addSubview(mapView)
        //button for autocomplete
        view.addSubview(hammockFinderButton)
        //view.addSubview(fillView)
        //tab bar for buttons
        view.addSubview(buttonHolder)
        //view.addSubview(btnARLaunch)
        buttonHolder.delegate = self
        
        view.addSubview(filterLocationButton)
        view.addSubview(kayakButton)
        //kayakButton.center = filterLocationButton.center
        view.addSubview(hammockButton)
        //hammockButton.center = filterLocationButton.center
        view.addSubview(hikeButton)
        //hikeButton.center = filterLocationButton.center
        //view.addSubview(allSpotsButton)
        //allSpotsButton.center = filterLocationButton.center
        view.addSubview(povButton)
        //povButton.center = filterLocationButton.center
        view.addSubview(fitnessTrailButton)
        //fitnessTrailButton.center = filterLocationButton.center

        
        //add constraints
        setConstraintMapView()
        //Accurately place their origins and widths for correct animations (may be a cleaner way to do but this will do for now)
        kayakButton.frame.size.width = 50
        kayakButton.frame.size.height = 50
        kayakButton.frame.origin.x = view.frame.width - 60
        kayakButton.center.y = view.frame.height - 220
        hikeButton.frame.size.width = 50
        hikeButton.frame.size.height = 50
        hikeButton.frame.origin.x = view.frame.width - 60
        hikeButton.center.y = view.frame.height - 220
        hammockButton.frame.size.width = 50
        hammockButton.frame.size.height = 50
        hammockButton.frame.origin.x = view.frame.width - 60
        hammockButton.center.y = view.frame.height - 220
        fitnessTrailButton.frame.size.width = 50
        fitnessTrailButton.frame.size.height = 50
        fitnessTrailButton.frame.origin.x = view.frame.width - 60
        fitnessTrailButton.center.y = view.frame.height - 220
        povButton.frame.size.width = 50
        povButton.frame.size.height = 50
        povButton.frame.origin.x = view.frame.width - 60
        povButton.center.y = view.frame.height - 220
        //allSpotsButton.frame.size.width = 50
        //allSpotsButton.frame.size.height = 50
        //allSpotsButton.frame.origin.x = view.frame.width - 60
        //allSpotsButton.center.y = view.frame.height - 220
      
        //center around position
        //let coordinate = locationManager.location
        //let origin = coordinate?.coordinate
        //mapView.camera = GMSCameraPosition.camera(withLatitude: origin!.latitude, longitude: origin!.longitude, zoom: 14, bearing: 0, viewingAngle: 0)
        //mapView.camera = GMSCameraPosition.camera(withTarget: origin, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // Set the map style by passing the URL of the local file.
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        //load custom view when marker touched
        self.tappedMarker = GMSMarker()
        self.customInfoWindow = CustomInfoWindow().loadView()
        
        //based on user's preference display either all pins or only connections'
        /*userReference.child("UserID: \(currUserID!)").child("Settings").child("Display every pin").observeSingleEvent(of: .value, with: {(snapshot) in
            //if user enabled all pins then we display all pins
            if let val = snapshot.value as? Int {
                if val == 1 {
                    self.retrieveAllPins()
                }
                //otherwise we display only his connections' pins
                else {
                    self.retrieveConnectionsPins()
                }
            }
        })*/
        
        //check for email verification of user
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                //add a bit of delay so everything loads
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // add delay of half of a second so that everything loads
                    //UNCOMMENT TO VERIFY USER EMAIL PLEASE but less frequently
                    user?.reload { (error) in
                        switch user!.isEmailVerified {
                        case true:
                            print("email verified")
                        case false:
                            guard error != nil else {
                                //self.checkAndSendVerificationEmails(user: user!)
                                return
                            }
                        }
                    }
                }
            }
        }
        retrieveAllPins()
    }
    
    //MARK: - Global variable definition
    
    //DEFINITION OF ALL "GLOBAL" VARIABLES HERE THAT ARE USED IN FUNCTIONS/DELEGATES
    //Create Marker for when a POI is touched
    let POIMarker = GMSMarker()
    // dropping marker on long press
    let droppableMarker = GMSMarker()
    // variables for custom view when touching a marker
    var tappedMarker = GMSMarker()
    //custom info window
    var customInfoWindow : CustomInfoWindow?
    //declare variables to put back the saved markers to display them again
    var savedSpots = [GMSMarker]()
    //declare polyline aka path from location to selected pin
    let polyline = GMSPolyline()
    //Define Location variable
    private let locationManager = CLLocationManager()
    
    var didUpdateLoc = 0
    
    //Button creation for review and directions
    //create button which will ask for directions
    let btnDir : UIButton = {
        let button = UIButton(frame: CGRect(x: 200, y: 200, width: 48, height: 48))
        //give direction button properties
        button.backgroundColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        button.setImage(UIImage(named: "directionsButton"), for: .normal)
        //button.setTitle("Get there", for: .normal)
        button.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(giveDirections), for: .touchUpInside)
        return button
    }()
    
    // create button which will allow reviews
    let btnRev: UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 48, height: 48))
        // give review button properties
        button.backgroundColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        button.setImage(UIImage(named: "reviewButton"), for: .normal)
        //button.setTitle("Review", for: .normal)

        button.layer.cornerRadius = 5.0
        button.titleLabel!.font = UIFont(name: "Avenir", size: 16.0)
        button.addTarget(self, action: #selector(ReviewLocation), for: .touchUpInside)
        return button
    }()

    
    //fill view
    lazy var fillView: UIView = {
        let fillV = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        fillV.backgroundColor = UIColor.init(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        return fillV
    }()
    
    //map View
    lazy var mapView: GMSMapView = {
        let map = GMSMapView()
        map.layer.cornerRadius = 2
        map.settings.myLocationButton = true
        map.settings.allowScrollGesturesDuringRotateOrZoom = true
        map.settings.compassButton = true
        map.setMinZoom(5, maxZoom: map.maxZoom)
        return map
    }()
    
    // Add a button to the map to find hammocking spots
    lazy var hammockFinderButton: UIButton = {
        let btnLaunchAc = UIButton()
        btnLaunchAc.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        btnLaunchAc.setTitle("   Search for spots", for: .normal)
        btnLaunchAc.titleLabel!.font = UIFont(name: "Avenir", size: 17.0)
        btnLaunchAc.titleLabel?.adjustsFontSizeToFitWidth = true
        btnLaunchAc.titleLabel?.adjustsFontForContentSizeCategory = true
        btnLaunchAc.setImage(UIImage(named: "magnifyingglass"), for: .normal)
        btnLaunchAc.tintColor = .white
        btnLaunchAc.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btnLaunchAc.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btnLaunchAc.contentHorizontalAlignment = .left
        btnLaunchAc.titleLabel?.textAlignment = .left
        //btnLaunchAc.titleLabel?.textAlignment = .natural
        btnLaunchAc.layer.cornerRadius = view.frame.height * 0.023
        btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
        return btnLaunchAc
    }()
    
    //tab bar that holds the buttons
    lazy var buttonHolder: UITabBar = {
        let tabBar = UITabBar()
        tabBar.backgroundColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)
        tabBar.barTintColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)
        tabBar.itemPositioning = .fill
        //selected item color
        tabBar.tintColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        tabBar.unselectedItemTintColor = UIColor(red: 185/255, green: 187/255, blue: 182/255, alpha: 1)
        

        //create button items
        let communityButton = UITabBarItem(title: "", image: UIImage(named: "group"), selectedImage: UIImage(named: "group"))
        let hammockButton = UITabBarItem(title: "", image: UIImage(named: "map"), selectedImage: UIImage(named: "map"))
        let profileButton = UITabBarItem(title: "", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))
        
        //tags
        communityButton.tag = 1 //first button
        hammockButton.tag = 2 // second button
        profileButton.tag = 3 //third button
        //properties
        tabBar.items = [communityButton, hammockButton, profileButton]
        //make current VC highlighted button
        tabBar.selectedItem = hammockButton
        tabBar.isTranslucent = true
        return tabBar
    }()

    //button to show all filters for locations
    lazy var filterLocationButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = .black
        //button.layer.cornerRadius = 15.0
        button.setImage(UIImage(named: "stack"), for: .normal)
        //button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(displayButtonPlaces), for: .touchUpInside)
        return button
    }()
    
    //display kayaking spots button
    lazy var kayakButton: UIButton = {
        let button = UIButton()// UIButton(frame: CGRect(x: 0 , y: 0, width: 50, height: 50))
        button.alpha = 0
        //choose which button to choose based on user preference
        userReference.child("UserID: \(currUserID!)").child("Settings").child("Kayak Display").observeSingleEvent(of: .value, with: { (snapshot) in
            DispatchQueue.main.async {
                //if he didnt specify to show kayak places we will show it unlocked
                if snapshot.value as! Int == 0 {
                    button.setImage(UIImage(named: "kayak"), for: .normal)
                }
                //if user wants to see them we put it in white
                else {
                    button.setImage(UIImage(named: "kayakWhite"), for: .normal)
                }
            }
        })
        //button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(displayKayakLoc), for: .touchUpInside)
        return button
    }()
    
    //display hammocking spots button
    lazy var hammockButton: UIButton = {
        let button = UIButton()// UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.alpha = 0
        //decide which button to show
        userReference.child("UserID: \(currUserID!)").child("Settings").child("Hammock Display").observeSingleEvent(of: .value, with: { (snapshot) in
            DispatchQueue.main.async {
                //if he didnt specify to show hammock places we will show it unlocked
                if snapshot.value as! Int == 0 {
                    button.setImage(UIImage(named: "hammock"), for: .normal)
                }
                //if user wants to see them we put it in white
                else {
                    button.setImage(UIImage(named: "hammockWhite"), for: .normal)
                }
            }
        })
        //button.backgroundColor = .blue
        //button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(displayHammockLoc), for: .touchUpInside)
        return button
    }()
    
    //display point of view spots button
    lazy var povButton: UIButton = {
        let button = UIButton()// UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.alpha = 0
        //button.backgroundColor = .green
        //decide which button to show
        userReference.child("UserID: \(currUserID!)").child("Settings").child("Pov Display").observeSingleEvent(of: .value, with: { (snapshot) in
            DispatchQueue.main.async {
                //if he didnt specify to show POV places we will show it unlocked
                if snapshot.value as! Int == 0 {
                    button.setImage(UIImage(named: "binoculars"), for: .normal)
                }
                //if user wants to see them we put it in white
                else {
                    button.setImage(UIImage(named: "binocularsWhite"), for: .normal)
                }
            }
        })
        //button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(displayPovLoc), for: .touchUpInside)
        return button
    }()
    
    //display hammocking spots button
    lazy var hikeButton: UIButton = {
        let button = UIButton()// UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.alpha = 0
        //decide which button to show
        userReference.child("UserID: \(currUserID!)").child("Settings").child("Hike Display").observeSingleEvent(of: .value, with: { (snapshot) in
            DispatchQueue.main.async {
                //if he didnt specify to show hike places we will show it unlocked
                if snapshot.value as! Int == 0 {
                    button.setImage(UIImage(named: "hiking"), for: .normal)
                }
                //if user wants to see them we put it in white
                else {
                    button.setImage(UIImage(named: "hikingWhite"), for: .normal)
                }
            }
        })
        //button.backgroundColor = .brown
        //button.setImage(UIImage(named: "hiking"), for: .normal)
        //button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(displayHikeLoc), for: .touchUpInside)
        return button
    }()
    
    //display fitness trail spots button
    lazy var fitnessTrailButton: UIButton = {
        let button = UIButton()// UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.alpha = 0
        //button.backgroundColor = .orange
        //decide which button to show
        userReference.child("UserID: \(currUserID!)").child("Settings").child("Fitness Display").observeSingleEvent(of: .value, with: { (snapshot) in
            DispatchQueue.main.async {
                //if he didnt specify to show running places we will show it unlocked
                if snapshot.value as! Int == 0 {
                    button.setImage(UIImage(named: "running"), for: .normal)
                }
                //if user wants to see them we put it in white
                else {
                    button.setImage(UIImage(named: "runningWhite"), for: .normal)
                }
            }
        })
        //button.setImage(UIImage(named: "running"), for: .normal)
        //button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(displayFitnessTrailLoc), for: .touchUpInside)
        return button
    }()
    
    /*let allSpotsButton: UIButton = {
        let button = UIButton()// UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.alpha = 0
        button.layer.cornerRadius = 15.0
        button.setImage(UIImage(named: "nofilter"), for: .normal)
        //button.backgroundColor = .purple
        button.addTarget(self, action: #selector(displayAllLoc), for: .touchUpInside)
        return button
    }()*/
    
    //review variable
    var rateToDisplay = 0.0
    //create reference to firebase database
    let hammockingSpotsReference = Database.database().reference(withPath: "Hammocking Spots")
    let kayakingSpotsReference = Database.database().reference(withPath: "Kayaking Spots")
    let hikingSpotsReference = Database.database().reference(withPath: "Hiking Spots")
    let pointOfViewSpotsReference = Database.database().reference(withPath: "Point of View Spots")
    let fitnessSpotsReference = Database.database().reference(withPath: "Fitness Spots")

    //array of hammock marker
    lazy var hammockMarkers: [GMSMarker] = []
    //array of kayak markers
    lazy var kayakMarkers: [GMSMarker] = []
    //array of fitness trail markers
    lazy var fitnessMarkers: [GMSMarker] = []
    //array of point of view markers
    lazy var binocularsMarkers: [GMSMarker] = []
    //array of hike markers
    lazy var hikeMarkers: [GMSMarker] = []
    
    //variables to know which pin to drop on long press
    var pinToPlace = 0
    //create reference to firebase database of users
    let userReference = Database.database().reference(withPath: "Users")
    //current connected user UID
    let currUserID = Auth.auth().currentUser?.uid
    // END OF VARIABLE DEFINITION
    
    //chang button image based on its status clicked or not
    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == onImage {
            button.setImage(offImage, for: .normal)
        }
        else {
            button.setImage(onImage, for: .normal)
        }
    }
    //make button to filter friend/self or all users pins
    /*func filterButt() {
        //filter button to display only wanted pins
        let btnFilterPins = UIButton(frame: CGRect(x: .max - 20, y: .max - 40, width: 15, height: 30))
        btnFilterPins.backgroundColor = .orange
        btnFilterPins.setTitle("Filter Pins", for: .normal)
        btnFilterPins.addTarget(self, action: #selector(filterPins), for: .touchUpInside)
        self.view.addSubview(btnFilterPins)
    }*/
    
    //MARK: - Navigation
    //transfer tappedMarker data to rating view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToReview"{
            let RatingVC: RatingViewController = segue.destination as! RatingViewController
            RatingVC.passingMarker = tappedMarker
        }
    }
    
    //display all existing pins
    func retrieveAllPins() {
        var typeOfPlaces = 0
        var referenceToUse = DatabaseReference()
        //get which markers the user wants shown
        userReference.child("UserID: \(currUserID!)").child("Settings").child("Location Display").observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.value as! Int != nil
            else {
                print("SOMETHING WENT WRONG")
                return
            }
            typeOfPlaces = snapshot.value as! Int
            //typeOfPlaces = snapshot.value as! Int
            referenceToUse = self.decideReferenceToUseInt(integer: typeOfPlaces)
            //display saved markers
            referenceToUse.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                   // if let value = child as? Double{
                    let snap = child as! DataSnapshot
                    //get child key
                    let key = snap.key
                    //print("key = \(key)")
                    // create child ref (marker ID: corresponding ID
                   // let markerIDReference = self.hammockingSpotsReference.child(key)
                    //variables to log in the data from FIREBASE
                    var markerLatitude = 0.0
                    var markerLongitude = 0.0
                    
                    // observe child node (inside the marker id node)
                    referenceToUse.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                        for grandChild in snapshot2.children {
                            let subsnap = grandChild as! DataSnapshot
                            //get grandchild key
                            let subKey = subsnap.key
                            //print("key is : \(subKey) value: \(subsnap.value)")
                            if let val = subsnap.value as? Double{
                                 // if it is the marker latitude then add it
                                if subKey == "GMS Marker latitude" {
                                    markerLatitude = val
                                }
                                // if it is the marker longitude then add it
                                else if subKey == "GMS Marker longitude" {
                                    markerLongitude = val
                                }
                            }
                        }
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        let imageName = self.decideImageToUse(integer: typeOfPlaces, marker: savedMarker)
                        savedMarker.icon = UIImage(named: imageName)
                        savedMarker.title = key
                        savedMarker.map = self.mapView
                    })
                }
            })
        })
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
            if numEmailsSent + 1 == 10 {
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
                let emailsSentAlert = UIAlertController(title: "Confirm Email", message: "\(10 - numEmailsSent - 1) confirmation emails left before your account is deleted", preferredStyle: .alert)
                //ok action
                emailsSentAlert.addAction(UIAlertAction(title: "OK", style: .cancel))

                self.present(emailsSentAlert, animated: true, completion: nil)
            }
        })
    }
    
    //display only friends' pins
    func retrieveConnectionsPins() {
        //display saved markers
        hammockingSpotsReference.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
               // if let value = child as? Double{
                let snap = child as! DataSnapshot
                //get child key
                let key = snap.key
                //print("key = \(key)")
                // create child ref (marker ID: corresponding ID
               // let markerIDReference = self.hammockingSpotsReference.child(key)
                //variables to log in the data from FIREBASE
                var markerLatitude = 0.0
                var markerLongitude = 0.0
                var displayMarker = 0
                
                // observe child node (inside the marker id node)
                self.hammockingSpotsReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                    for grandChild in snapshot2.children {
                        let subsnap = grandChild as! DataSnapshot
                        //get grandchild key
                        let subKey = subsnap.key
                        //print("key is : \(subKey) value: \(subsnap.value)")
                        if let val = subsnap.value as? Double{
                             // if it is the marker latitude then add it
                            if subKey == "GMS Marker latitude" {
                                markerLatitude = val
                            }
                            // if it is the marker longitude then add it
                            else if subKey == "GMS Marker longitude" {
                                markerLongitude = val
                            }
                        }
                        //if they are friends then we choose to display
                        if let val = subsnap.value as? String {
                            if subKey == "Creator of Spot" {
                                //checks if user 1 (creator of spot) is friends with current user
                                displayMarker = self.areFriends(user1: val)
                            }
                        }
                    }
                    if displayMarker == 1 {
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        savedMarker.title = key
                        savedMarker.icon = UIImage(named: "pinHammock")
                        savedMarker.map = self.mapView
                    }
                })
            }
        })
    }
    
    //function that checks if user 1 is freidns with current user
    func areFriends(user1: String) -> Int {
        //1 if freinds 0 otherwise
        var friends = 0
        userReference.child("UserID: \(currUserID!)").child("Friends with").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let val = snap.value as? String {
                    if val == user1 {
                        friends = 1
                        //exit out of loop to gain time
                        break
                    }
                }
            }
        })
        return friends
    }
    
    //MARK: - OBJC Functions
    //show all button types for places
    @objc func displayButtonPlaces(_ sender: UIButton) {
        //animation for button expansion
        if filterLocationButton.currentImage == UIImage(named: "stack")
        {
            UIView.animate(withDuration: 0.4, animations: {
                self.kayakButton.alpha = 1
                self.hammockButton.alpha = 1
                self.hikeButton.alpha = 1
                self.fitnessTrailButton.alpha = 1
                self.povButton.alpha = 1
                //self.allSpotsButton.alpha = 1
                self.kayakButton.center = CGPoint(x: self.filterLocationButton.center.x, y: self.filterLocationButton.center.y - 60)
                    //self.kayakButtonCenter
                self.hammockButton.center = CGPoint(x: self.filterLocationButton.center.x, y: self.kayakButton.center.y - 60)//self.hammockButtonCenter
                self.hikeButton.center = CGPoint(x: self.filterLocationButton.center.x, y: self.hammockButton.center.y - 60)//self.hikeButtonCenter
                self.fitnessTrailButton.center = CGPoint(x: self.filterLocationButton.center.x, y: self.hikeButton.center.y - 60)//self.fitnessTrailButtonCenter
                self.povButton.center = CGPoint(x: self.filterLocationButton.center.x, y: self.fitnessTrailButton.center.y - 60)//self.povButtonCenter
                //self.allSpotsButton.center = CGPoint(x: self.filterLocationButton.center.x, y: self.povButton.center.y - 60)//self.allSpotButtonCenter
                self.toggleButton(button: sender, onImage: UIImage(named: "stackWhite")!, offImage: UIImage(named: "stack")!)
            })
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                self.kayakButton.alpha = 0
                self.hammockButton.alpha = 0
                self.hikeButton.alpha = 0
                self.fitnessTrailButton.alpha = 0
                self.povButton.alpha = 0
                //self.allSpotsButton.alpha = 0
                self.kayakButton.center = self.filterLocationButton.center
                self.hammockButton.center = self.filterLocationButton.center
                self.hikeButton.center = self.filterLocationButton.center
                self.fitnessTrailButton.center = self.filterLocationButton.center
                self.povButton.center = self.filterLocationButton.center
                //self.allSpotsButton.center = self.filterLocationButton.center
                self.toggleButton(button: sender, onImage: UIImage(named: "stack")!, offImage: UIImage(named: "stackWhite")!)
            })
        }
        
    }
    
    //show all kayaking locations
    @objc func displayKayakLoc(_ sender: UIButton) {
        var displayKayakLocs = 0
        // if we press on grey kayak. display places and change color of button
        if kayakButton.currentImage == UIImage(named: "kayak") {
            toggleButton(button: sender, onImage: UIImage(named: "kayakWhite")!, offImage: UIImage(named: "kayak")!)
            //display saved markers
            kayakingSpotsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                   // if let value = child as? Double{
                    let snap = child as! DataSnapshot
                    //get child key
                    let key = snap.key
                    //print("key = \(key)")
                    // create child ref (marker ID: corresponding ID
                    //variables to log in the data from FIREBASE
                    var markerLatitude = 0.0
                    var markerLongitude = 0.0
                    
                    // observe child node (inside the marker id node)
                    self.kayakingSpotsReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                        for grandChild in snapshot2.children {
                            let subsnap = grandChild as! DataSnapshot
                            //get grandchild key
                            let subKey = subsnap.key
                            //print("key is : \(subKey) value: \(subsnap.value)")
                            if let val = subsnap.value as? Double{
                                 // if it is the marker latitude then add it
                                if subKey == "GMS Marker latitude" {
                                    markerLatitude = val
                                }
                                // if it is the marker longitude then add it
                                else if subKey == "GMS Marker longitude" {
                                    markerLongitude = val
                                }
                            }
                        }
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        savedMarker.icon = UIImage(named: "pinKayak")
                        savedMarker.title = key
                        savedMarker.map = self.mapView
                        self.kayakMarkers.append(savedMarker)
                    })
                }
            })
            pinToPlace = 1
            displayKayakLocs = 1
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Kayak Display": displayKayakLocs])
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Location Display": pinToPlace])
        }
        else {
            toggleButton(button: sender, onImage: UIImage(named: "kayak")!, offImage: UIImage(named: "kayakWhite")!)
            //remove corresponding marker
            if !(kayakMarkers.isEmpty) {
                for i in 0...kayakMarkers.count-1 {
                    kayakMarkers[i].map = nil
                }
            }
            pinToPlace = 0
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Kayak Display": pinToPlace])
        }
    }
    
    //show all hammocking locations
    @objc func displayHammockLoc(_ sender: UIButton) {
        var displayHammockLocs = 0
        // if we press on grey kayak. display places and change color of button
        if hammockButton.currentImage == UIImage(named: "hammock") {
            toggleButton(button: sender, onImage: UIImage(named: "hammockWhite")!, offImage: UIImage(named: "hammock")!)
            //display saved markers
            hammockingSpotsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                   // if let value = child as? Double{
                    let snap = child as! DataSnapshot
                    //get child key
                    let key = snap.key
                    //print("key = \(key)")
                    // create child ref (marker ID: corresponding ID
                    //variables to log in the data from FIREBASE
                    var markerLatitude = 0.0
                    var markerLongitude = 0.0
                    
                    // observe child node (inside the marker id node)
                    self.hammockingSpotsReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                        for grandChild in snapshot2.children {
                            let subsnap = grandChild as! DataSnapshot
                            //get grandchild key
                            let subKey = subsnap.key
                            //print("key is : \(subKey) value: \(subsnap.value)")
                            if let val = subsnap.value as? Double{
                                 // if it is the marker latitude then add it
                                if subKey == "GMS Marker latitude" {
                                    markerLatitude = val
                                }
                                // if it is the marker longitude then add it
                                else if subKey == "GMS Marker longitude" {
                                    markerLongitude = val
                                }
                            }
                        }
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        savedMarker.icon = UIImage(named: "pinHammock")
                        savedMarker.title = key
                        savedMarker.map = self.mapView
                        self.hammockMarkers.append(savedMarker)
                    })
                }
            })
            pinToPlace = 2
            displayHammockLocs = 1
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Hammock Display": displayHammockLocs])
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Location Display": pinToPlace])
        }
        else {
            toggleButton(button: sender, onImage: UIImage(named: "hammock")!, offImage: UIImage(named: "hammockWhite")!)
            //remove corresponding marker
            if !(hammockMarkers.isEmpty) {
                for i in 0...hammockMarkers.count-1 {
                    hammockMarkers[i].map = nil
                }
            }
            pinToPlace = 0
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Hammock Display": pinToPlace])
        }
    }
    
    //show all point of views locations
    @objc func displayPovLoc(_ sender: UIButton) {
        var displayPovLocs = 0
        // if we press on grey kayak. display places and change color of button
        if povButton.currentImage == UIImage(named: "binoculars") {
            toggleButton(button: sender, onImage: UIImage(named: "binocularsWhite")!, offImage: UIImage(named: "binoculars")!)
            //display saved markers
            pointOfViewSpotsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                   // if let value = child as? Double{
                    let snap = child as! DataSnapshot
                    //get child key
                    let key = snap.key
                    //print("key = \(key)")
                    // create child ref (marker ID: corresponding ID
                    //variables to log in the data from FIREBASE
                    var markerLatitude = 0.0
                    var markerLongitude = 0.0
                    
                    // observe child node (inside the marker id node)
                    self.pointOfViewSpotsReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                        for grandChild in snapshot2.children {
                            let subsnap = grandChild as! DataSnapshot
                            //get grandchild key
                            let subKey = subsnap.key
                            //print("key is : \(subKey) value: \(subsnap.value)")
                            if let val = subsnap.value as? Double{
                                 // if it is the marker latitude then add it
                                if subKey == "GMS Marker latitude" {
                                    markerLatitude = val
                                }
                                // if it is the marker longitude then add it
                                else if subKey == "GMS Marker longitude" {
                                    markerLongitude = val
                                }
                            }
                        }
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        savedMarker.icon = UIImage(named: "pinBinoculars")
                        savedMarker.title = key
                        savedMarker.map = self.mapView
                        self.binocularsMarkers.append(savedMarker)
                    })
                }
            })
            pinToPlace = 3
            displayPovLocs = 1
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Pov Display": displayPovLocs])
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Location Display": pinToPlace])
        }
        else {
            toggleButton(button: sender, onImage: UIImage(named: "binoculars")!, offImage: UIImage(named: "binocularsWhite")!)
            //remove corresponding marker
            if !(binocularsMarkers.isEmpty) {
                for i in 0...binocularsMarkers.count-1 {
                    binocularsMarkers[i].map = nil
                }
            }
            pinToPlace = 0
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Pov Display": pinToPlace])
        }
    }
    
    //show all hike locations
    @objc func displayHikeLoc(_ sender: UIButton) {
        var displayHikeLocs = 0
        // if we press on grey kayak. display places and change color of button
        if hikeButton.currentImage == UIImage(named: "hiking") {
            toggleButton(button: sender, onImage: UIImage(named: "hikingWhite")!, offImage: UIImage(named: "hiking")!)
            //display saved markers
            hikingSpotsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                   // if let value = child as? Double{
                    let snap = child as! DataSnapshot
                    //get child key
                    let key = snap.key
                    //print("key = \(key)")
                    // create child ref (marker ID: corresponding ID
                    //variables to log in the data from FIREBASE
                    var markerLatitude = 0.0
                    var markerLongitude = 0.0
                    
                    // observe child node (inside the marker id node)
                    self.hikingSpotsReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                        for grandChild in snapshot2.children {
                            let subsnap = grandChild as! DataSnapshot
                            //get grandchild key
                            let subKey = subsnap.key
                            //print("key is : \(subKey) value: \(subsnap.value)")
                            if let val = subsnap.value as? Double{
                                 // if it is the marker latitude then add it
                                if subKey == "GMS Marker latitude" {
                                    markerLatitude = val
                                }
                                // if it is the marker longitude then add it
                                else if subKey == "GMS Marker longitude" {
                                    markerLongitude = val
                                }
                            }
                        }
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        savedMarker.icon = UIImage(named: "pinHike")
                        savedMarker.title = key
                        savedMarker.map = self.mapView
                        self.hikeMarkers.append(savedMarker)
                    })
                }
            })
            pinToPlace = 4
            displayHikeLocs = 1
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Hike Display": displayHikeLocs])
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Location Display": pinToPlace])
        }
        else {
            toggleButton(button: sender, onImage: UIImage(named: "hiking")!, offImage: UIImage(named: "hikingWhite")!)
            //remove corresponding marker
            if !(hikeMarkers.isEmpty) {
                for i in 0...hikeMarkers.count-1 {
                    hikeMarkers[i].map = nil
                }
            }
            pinToPlace = 0
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Hike Display": pinToPlace])
        }
    }
    
    //show all hammocking locations
    @objc func displayFitnessTrailLoc(_ sender: UIButton) {
        var displayFitnessTrailLocs = 0
        // if we press on grey kayak. display places and change color of button
        if fitnessTrailButton.currentImage == UIImage(named: "running") {
            toggleButton(button: sender, onImage: UIImage(named: "runningWhite")!, offImage: UIImage(named: "running")!)
            //display saved markers
            fitnessSpotsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                   // if let value = child as? Double{
                    let snap = child as! DataSnapshot
                    //get child key
                    let key = snap.key
                    //print("key = \(key)")
                    // create child ref (marker ID: corresponding ID
                    //variables to log in the data from FIREBASE
                    var markerLatitude = 0.0
                    var markerLongitude = 0.0
                    
                    // observe child node (inside the marker id node)
                    self.fitnessSpotsReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                        for grandChild in snapshot2.children {
                            let subsnap = grandChild as! DataSnapshot
                            //get grandchild key
                            let subKey = subsnap.key
                            //print("key is : \(subKey) value: \(subsnap.value)")
                            if let val = subsnap.value as? Double{
                                 // if it is the marker latitude then add it
                                if subKey == "GMS Marker latitude" {
                                    markerLatitude = val
                                }
                                // if it is the marker longitude then add it
                                else if subKey == "GMS Marker longitude" {
                                    markerLongitude = val
                                }
                            }
                        }
                        // put in position the marker's lat and long
                        let markerPosition = CLLocationCoordinate2D(latitude: markerLatitude, longitude: markerLongitude)
                        //display it on the map
                        let savedMarker = GMSMarker(position: markerPosition)
                        savedMarker.icon = UIImage(named: "pinFitness")
                        savedMarker.title = key
                        savedMarker.map = self.mapView
                        self.fitnessMarkers.append(savedMarker)
                    })
                }
            })
            pinToPlace = 5
            displayFitnessTrailLocs = 1
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Fitness Display": displayFitnessTrailLocs])
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Location Display": pinToPlace])
        }
        else {
            toggleButton(button: sender, onImage: UIImage(named: "running")!, offImage: UIImage(named: "runningWhite")!)
            //remove corresponding marker
            if !(fitnessMarkers.isEmpty) {
                for i in 0...fitnessMarkers.count-1 {
                    fitnessMarkers[i].map = nil
                }
            }
            displayFitnessTrailLocs = 0
            pinToPlace = 0
            userReference.child("UserID: \(currUserID!)").child("Settings").updateChildValues(["Fitness Display": pinToPlace])
        }
    }
    
    //display all types of lcoations
    /*@objc func displayAllLoc(_ sender: UIButton) {
        toggleButton(button: sender, onImage: UIImage(named: "nofilterWhite")!, offImage: UIImage(named: "nofilter")!)
    }*/
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        //change controller appearance
        UINavigationBar.appearance().backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)//
        UINavigationBar.appearance().tintColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)//UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)//UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
        // Sets the text color of the text in search field
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISearchBar.appearance().backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "New places to hammock at", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        //navigationController?.view.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        //its color when touched upon which activates it
        //navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        autocompleteController.tintColor = UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
        // UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        autocompleteController.primaryTextHighlightColor = .white
        autocompleteController.primaryTextColor = .lightGray
        autocompleteController.secondaryTextColor = .lightGray
        autocompleteController.tableCellBackgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        autocompleteController.tableCellSeparatorColor = .white
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
        UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //filter pins based on user choice ->Friends, self pins or everyone's
    @objc func filterPins(_ sender: UIButton) {
        //TODO: Filter pin on map based on user's choice
    }
    
    //take this control viewer to another screen (the review screen)
    @objc func ReviewLocation(_ sender: UIButton) {
        performSegue(withIdentifier: "mapToReview", sender: sender)
    }
    
    // give directions to user when pressing the get there button after having clicked on a marker
    @objc func giveDirections(_ sender: UIButton)
    {
        //retrieve user location
        let coordinate = locationManager.location
        //translate it into a 2D Coordinate
        let origin = coordinate?.coordinate
        //get lat and long of tapped marker
        let destination = tappedMarker.position
        //print(destination.latitude)
        //print(origin!.latitude)
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\( origin!.latitude),\(origin!.longitude)&destination=\(destination.latitude),\( destination.longitude)&walking&key=AIzaSyDyVdgLAcqOEXBgJlatReggIVuEqDnm7k4"
        let url = URL(string: directionURL)
        // ask server to return JSON array
        Alamofire.request(url!, method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
        switch response.result {
        case.success(let value):
            let json = JSON(value)
            //print(json)
            // get first directions to give to the user
            let overViewPolyLine = json["routes"][0]["overview_polyline"]["points"].string
            if overViewPolyLine != nil {
                //print(overViewPolyLine as Any)
                // drawpath on screen
                self.drawPath(polylineString: overViewPolyLine!)
                // remove get there button and custom info window
                sender.removeFromSuperview()
                self.btnRev.removeFromSuperview()
                self.customInfoWindow?.removeFromSuperview()
            }
        case.failure(let error):
            print("\(error.localizedDescription)")
            }
        }
    }
    
    // create path
    func drawPath(polylineString: String)
    {
        // define path variable
        let pathMut = GMSMutablePath(fromEncodedPath: polylineString)
        polyline.path = pathMut
        polyline.strokeColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 0.9)
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        polyline.isTappable = true
    }
    
    //decide which reference to show comments
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
    
    //reference to use for integers
    func decideReferenceToUseInt(integer: Int) -> DatabaseReference {
        //for the refereence to use
        var referenceToUse = DatabaseReference()
        switch integer {
        case 1:
            referenceToUse = kayakingSpotsReference
            break
        case 2:
            referenceToUse = hammockingSpotsReference
            break
        case 3:
            referenceToUse = hikingSpotsReference
            break
        case 4:
            referenceToUse = fitnessSpotsReference
            break
        case 5:
            referenceToUse = pointOfViewSpotsReference
            break
        default:
            referenceToUse = hammockingSpotsReference
            print("belongs to no reference")
            break
        }
        return referenceToUse
    }
    
    //reference to use for integers
    func decideImageToUse(integer: Int, marker: GMSMarker) -> String {
        //for the refereence to use
        var nameImageToUse = ""
        switch integer {
        case 1:
            nameImageToUse = "pinKayak"
            kayakMarkers.append(marker)
            break
        case 2:
            nameImageToUse = "pinHammock"
            hammockMarkers.append(marker)
            break
        case 3:
            nameImageToUse = "pinBinoculars"
            binocularsMarkers.append(marker)
            break
        case 4:
            nameImageToUse = "pinHike"
            hikeMarkers.append(marker)
            break
        case 5:
            nameImageToUse = "pinFitness"
            fitnessMarkers.append(marker)
            break
        default:
            nameImageToUse = "pinHammock"
            hammockMarkers.append(marker)
            print("belongs to no image")
            break
        }
        return nameImageToUse
    }
    //Geocoding request for Places when selecting a place
    func geoCodingPlaces(address: String) {
        //retrieve place on map GEOCODING
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false&key=AIzaSyDyVdgLAcqOEXBgJlatReggIVuEqDnm7k4"
        let url = URL(string: urlString)
        Alamofire.request(url!, method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
                case.success(let value):
                    let json = JSON(value)
                    print(json)
                    
                    //get latitude from json table
                    let lat = json["results"][0]["geometry"]["location"]["lat"].rawString()
                    let lng = json["results"][0]["geometry"]["location"]["lng"].rawString()
                    //let formattedAddress = json["results"][0]["formatted_address"].rawString()
                    
                    //If latitudes and longitudes are null then exit, otherwise keep going if they are string
                    guard let gLat = lat else{return}
                    guard let gLong = lng else{return}
                    //let gAddress = formattedAddress
                   
                    let g_Lat = Double(gLat)
                    let g_Long = Double(gLong)

                    //print(gLat,gLong,gAddress as Any)
                    self.dismiss(animated: true, completion: nil)
                    // put camera to desired location and place a marker
                    self.mapView.camera = GMSCameraPosition.camera(withLatitude: g_Lat!, longitude: g_Long!, zoom: 15)
                    //let position = CLLocationCoordinate2D(latitude: g_Lat!, longitude: g_Long!)
                    //let marker = GMSMarker(position: position)
                    //marker.icon = UIImage(named: "mappin")
                    //marker.map = self.mapView
                    
                case.failure(let error):
                    print("\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Constraints
    //constraint functions to hold everything together
    func setConstraintMapView() {
        //fillView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: hammockFinderButton.topAnchor, trailing: view.trailingAnchor)
        //hammock up button
        hammockFinderButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 5, left: 20, bottom: 0, right: 20), size: .init(width: 0, height: view.frame.height/20))
        
        //for the buttons
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))

        //for the map
        mapView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor)
        
        //for filtern
        filterLocationButton.anchor(top: nil, leading: nil, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 100, right: 10), size: .init(width: 50, height: 50))
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
  }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
      
        DispatchQueue.main.async {
            if self.didUpdateLoc == 0 {
                self.mapView.animate(to: GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
                //update position if we have moved of 5 meters
                self.locationManager.distanceFilter = kCLDistanceFilterNone
                self.didUpdateLoc = 1
            }
        }

        //based on user's preference display either all pins or only connections'
        /*userReference.child("UserID: \(currUserID!)").child("Settings").child("Follow user location").observeSingleEvent(of: .value, with: {(snapshot) in
            //if user wants to be followed by map
            if let val = snapshot.value as? Int {
                if val == 1 {
                }
                //free map and always update pos
                else {
                    self.locationManager.distanceFilter = kCLDistanceFilterNone
                }
            }
        })*/

        //mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        //DispatchQueue.main.async {
            //self.mapView.moveCamera(GMSCameraUpdate.setTarget(location.coordinate, zoom: 15))
            //self.mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)))
                //GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
            //self.mapView.animate(to: GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
            //self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            //self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        //}

        //locationManager.stopUpdatingLocation()
        //get best accuracy for location
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //locationManager.allowsBackgroundLocationUpdates =
        //start tracking heading
        locationManager.startUpdatingHeading()
        locationManager.headingFilter = kCLHeadingFilterNone //update whenever
    }
        
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    //creation of marker upon long touch
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D){
        // where user can create a marker
        droppableMarker.position = coordinate
        switch pinToPlace {
        case 1:
            droppableMarker.icon = UIImage(named: "pinKayak")
            break
        case 2:
            droppableMarker.icon = UIImage(named: "pinHammock")
            break
        case 3:
            droppableMarker.icon = UIImage(named: "pinBinoculars")
            break
        case 4:
            droppableMarker.icon = UIImage(named: "pinHike")
            break
        case 5:
            droppableMarker.icon = UIImage(named: "pinFitness")
            break
        default:
            droppableMarker.icon = UIImage(named: "pinHammock")
            break
        }
        
       // let marker = GMSMarker(position: coordinate)
        droppableMarker.isDraggable = true
        droppableMarker.map = mapView
        mapView.animate(toLocation: coordinate)
    }
    
    //when camera is about to move (depends on program or user gesture)
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //if moving due to a user gesture
        if (gesture) {
            
        }
    }
    
    //map does not move
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    }
    
    //when blue dot is tapped
    func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        //center around position
        self.mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: 15, bearing: 0, viewingAngle: 0))
    }
    
    //when camera position is changing
    func mapView(_ mapView: GMSMapView, didChange didChangeCameraPosition: GMSCameraPosition) {
    }
    
    // open custom window when tapping on marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        tappedMarker = marker
        //get position of marker
        let position = marker.position
        mapView.animate(toLocation: position)
        let point = mapView.projection.point(for: position)
        let newPoint = mapView.projection.coordinate(for: point)
        let camera = GMSCameraUpdate.setTarget(newPoint)
        mapView.animate(with: camera)
        //define custom window parameters
        let opaqueWhite = UIColor(white: 1, alpha: 0.85)
        customInfoWindow?.layer.backgroundColor = opaqueWhite.cgColor
        customInfoWindow?.labelInfoWindow.font = UIFont(name: "Avenir", size: 20)
        customInfoWindow?.labelInfoWindow.textColor = .white
        customInfoWindow?.layer.cornerRadius = 20.0
        customInfoWindow?.backgroundColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        customInfoWindow?.labelInfoWindow.textAlignment = .center
        customInfoWindow?.labelInfoWindow.adjustsFontSizeToFitWidth = true
        //constraint
        customInfoWindow?.frame = CGRect(x: 0, y: 0, width: view.frame.width / 1.6, height: view.frame.height / 5)
        customInfoWindow?.labelInfoWindow.frame = CGRect(x: 0, y: 0, width: view.frame.width / 1.6, height: view.frame.height / 5)
        customInfoWindow?.frame.origin.x = view.frame.width/2 - (customInfoWindow?.frame.width)!/2
        
        //create image view containing the mappin so we can place the custom window rihgt on top of the pin
        let mapPinImage = UIImageView(image: UIImage(named: "pinHammock"))
        let heightMapPin = mapPinImage.frame.height/2
        customInfoWindow?.frame.origin.y = mapView.frame.height/2 - (customInfoWindow?.frame.height)! - heightMapPin
        customInfoWindow?.labelInfoWindow.numberOfLines = 0
        
        //customInfoWindow?.labelInfoWindow.frame.origin.x = view.frame.width/2 - (customInfoWindow?.frame.width)!/2
        //customInfoWindow?.labelInfoWindow.frame.origin.y = view.frame.height/2 - (customInfoWindow?.frame.height)!/2 - hammockFinderButton.frame.maxY - heightMapPin
        
        //change positions of direction and review buttons
        btnRev.frame.origin = CGPoint(x: (customInfoWindow?.frame.origin.x)!, y: (customInfoWindow?.frame.maxY)! + 20)
        btnDir.frame.origin = CGPoint(x: (customInfoWindow?.frame.origin.x)! + (customInfoWindow?.frame.width)! - btnDir.frame.width, y: (customInfoWindow?.frame.maxY)! + 20)
        
        //variables to log in the data from FIREBASE
        var placeRating = 0.0
        var numReviews = 0
        var latID = position.latitude * Double(1000000)
        var longID = position.longitude * Double(1000000)
        latID = latID.rounded()
        longID = longID.rounded()
        let longIntID = Int(longID)
        let latIntID = Int(latID)
        let tappedMarkerID = "\(latIntID)\(longIntID)"
        
        //display rating of place on custom info window
        //link to datafirebase
        // observe child node (inside the hammock id node)
        let referenceToUse = decideReferenceToUse(passedMarker: tappedMarker)
        
        referenceToUse.child("Marker ID: \(tappedMarkerID)").observeSingleEvent(of: .value, with: { (snapshot2) in
            for grandChild in snapshot2.children {
                let subsnap = grandChild as! DataSnapshot
                //get grandchild key
                let subKey = subsnap.key
                //if value of this child node is a double and is place rating then log it
                if let val = subsnap.value as? Double{
                    if subKey == "Place Rating" {
                        placeRating = round(100 * val) / 100 //to have 2 digits precision
                    }
                }
                //number of reviews is an integer then log it
                if let val = subsnap.value as? Int{
                    if subKey == "Number of reviews" {
                        numReviews = val
                    }
                }
                //if we already gathered the values for place Rating and number of reviews exit out of loop to save time
                if placeRating != 0.0 && numReviews != 0 {
                    break
                }
            }
            // display rating on custom info window if has already been rated
            if placeRating == 0.0 {
                DispatchQueue.main.async {
                    self.customInfoWindow?.labelInfoWindow.text = "Want to share a spot? 🤩"
                }
            }
            //if already been rated then we display its rating and number of reviews
            else {
                DispatchQueue.main.async {
                    if numReviews == 1 {
                        self.customInfoWindow?.labelInfoWindow.text = "This spot has a rating of \(placeRating) according to \(numReviews) review"
                    }
                    else {
                        self.customInfoWindow?.labelInfoWindow.text = "This spot has a rating of \(placeRating) according to \(numReviews) reviews"
                    }
                }
            }
        })
        //add custom view to mapview
        self.mapView.addSubview(customInfoWindow!)
        
        self.view.addSubview(btnRev)
        self.view.addSubview(btnDir)

        return true
    }
    
    //go to my location
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return false
    }
       
    // remove custom view when pressing elsewhere on the screen
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //remove custom info window
        customInfoWindow?.removeFromSuperview()
        //remove constraints
        //also marker created when dropping one on long press
        //droppableMarker.map = nil
        self.btnRev.removeFromSuperview()
        self.btnDir.removeFromSuperview()
        // remove polyline
        polyline.map = nil
        
        //remove marker if it is not in the database of firebase (not an exisiting spot)
        //also remove get there and review button
        //tappedMarker?.map = nil
        var latID = (tappedMarker.position.latitude) * Double(1000000) //initialized to 300 as it cannot be a true lat
        latID = latID.rounded()
        let latIntID = Int(latID)
        var longID = (tappedMarker.position.longitude) * Double(1000000) //initialized to 300 as it cannot be a true long
        longID = longID.rounded()
        let longIntID = Int(longID)
        let tappedMarkerID = "\(latIntID)\(longIntID)"
        var markerExist = false
        //check if this marker exists in the database
        let referenceToUse = decideReferenceToUse(passedMarker: tappedMarker)
        referenceToUse.observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let subSnap = child as! DataSnapshot
                let key = subSnap.key
                //if it exists set boolean to true
                if key == "Marker ID: \(tappedMarkerID)" {
                    markerExist = true
                    return
                }
            }
            //if the tapped marker does not exist in the database, we can delete the tapped marker off the map when clicking elsewhere but if it does leave it 
            if markerExist == false {
                self.tappedMarker.map = nil
            }
        })
    }
    
    //when tapping on my location button
    //func didTapMyLocationButton(for mapView: GMSMapView, location: CLLocationCoordinate2D) -> Bool {
    //    mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: 15, bearing: 0, viewingAngle: 0)
    //    return true
    //}
       
    //disable the custom view given by googlemaps as it appears as solely an image and not clickable
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    //respond to tap on POI
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        POIMarker.snippet = placeID
        POIMarker.position = location
        POIMarker.title = name
        POIMarker.opacity = 0
        POIMarker.infoWindowAnchor.y = 1
        POIMarker.map = mapView
        mapView.selectedMarker = POIMarker
    }
    
}

//MARK: - Autocomplete
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
  // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // go put a marker and geocode this city
        geoCodingPlaces(address: place.name!)
        //dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        mapView.camera = GMSCameraPosition.camera(withTarget: locationManager.location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

//MARK: - Button tab bar delegate

extension MapViewController: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "mapToConnections", sender: item)
        }
        else if item.tag == 2 {
            //do nothing as this is the hammock button so we leave it untouched and stay on the same VC
        }
        else {
            //go to profile
            performSegue(withIdentifier: "mapToProfile", sender: item)
        }
    }
}
