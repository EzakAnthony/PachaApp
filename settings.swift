//
//  settings.swift
//  HammockUP
//
//  Created by Anthony Guillard on 07/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Firebase

class settings: UIViewController{

    //MARK: - Global variables
    //Settings text to indicate where we are
    lazy var settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont(name: "Rockwell", size: 24.0)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    //settings image
    lazy var settingsImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width/7 + view.frame.width/3 + 35, y: 20, width: 60, height: 60))
        imageView.image = UIImage(named: "settings")
        
        return imageView
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

    // Add a switch to choose whose pins to display
    var pinDisplaySwitch: UISwitch = {
        let pinSwitch = UISwitch(frame:CGRect(x: 150, y: 150, width: 30, height: 30))
        //Switch properties
        pinSwitch.addTarget(self, action: #selector(displayPins), for: .valueChanged)
        pinSwitch.onTintColor = UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
        pinSwitch.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        return pinSwitch
    }()
    
    //switch to search by name or Pseudo
    var searchSwitch: UISwitch = {
        let searchPseudoSwitch = UISwitch(frame:CGRect(x: 150, y: 150, width: 30, height: 30))
        //Switch properties
        searchPseudoSwitch.addTarget(self, action: #selector(searchSettings), for: .valueChanged)
        searchPseudoSwitch.onTintColor = UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
        searchPseudoSwitch.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        return searchPseudoSwitch
    }()
    
    //switch for map to follow you around or noit
    /*var followMapSwitch: UISwitch = {
        let mapSwitch = UISwitch(frame:CGRect(x: 150, y: 150, width: 30, height: 30))
        mapSwitch.addTarget(self, action: #selector(mapSettings), for: .valueChanged)
        mapSwitch.onTintColor = UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
        mapSwitch.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        return mapSwitch
    }()*/
    
    //MARK: - View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        
        //add settings label to view
        view.addSubview(settingsLabel)
        view.addSubview(settingsImage)
        view.addSubview(buttonHolder)
        //define data source and delegate for table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        //self.view.addSubview(pinDisplaySwitch)
        // Do any additional setup after loading the view.
        //show switches state
        gatherSwitchDisplay()
        gatherSwitchSearch()
        //gatherMapSwitch()
        //add constraints
        setConstraintsSettings()
        
        //delegate for buttons
        buttonHolder.delegate = self
    }
    
    //gather map following user location siwtch
    /*func gatherMapSwitch() {
        //gather mode to display switch based on previous settings
        usersReference.child("UserID: \(user!.uid)").child("Settings").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if snap.key == "Follow user location" {
                    // if the value is to display every pin set switch to on
                    if snap.value as! Int == 1 {
                        self.followMapSwitch.setOn(true, animated: true)
                        print("VALUE OF INT = 1")
                    }
                    //off if only friends is enabled
                    else {
                        self.followMapSwitch.setOn(false, animated: true)
                        print("VALUE OF INT = 0")
                    }
                }
            }
        })
    }*/
    
    //gather pin Display switch
    func gatherSwitchDisplay() {
        //gather mode to display switch based on previous settings
        usersReference.child("UserID: \(user!.uid)").child("Settings").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if snap.key == "Display every pin" {
                    // if the value is to display every pin set switch to on
                    if snap.value as! Int == 1 {
                        self.pinDisplaySwitch.setOn(true, animated: true)
                    }
                    //off if only friends is enabled
                    else {
                        self.pinDisplaySwitch.setOn(false, animated: true)
                    }
                }
            }
        })
    }
    
    //gather search by name switch
    func gatherSwitchSearch() {
        //gather mode to search users via pseudo or username
        usersReference.child("UserID: \(user!.uid)").child("Settings").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if snap.key == "Search by name" {
                    // if the value is to search by their name set switch to on
                    if snap.value as! Int == 1 {
                        self.searchSwitch.setOn(true, animated: true)
                    }
                    //off if pseudo searched
                    else {
                        self.searchSwitch.setOn(false, animated: true)
                    }
                }
            }
        })
    }
    
    //Outlets
    //segues to other VCs
    @IBOutlet var tableView: UITableView!
    
    //function enabling to display whos pins on the map
    @objc func displayPins(_ sender: UISwitch) {
        //if we look at everyone's pins
        if sender.isOn {
            //set value on firebase to say to display all pins
            usersReference.child("UserID: \(user!.uid)").child("Settings").updateChildValues(["Display every pin": 1])
        }
        // or just friends' pins
        else {
            usersReference.child("UserID: \(user!.uid)").child("Settings").updateChildValues(["Display every pin": 0])
        }
    }
    
    //lets user search by name or pseudo
    @objc func searchSettings(_ sender: UISwitch) {
        //search by name
        if sender.isOn {
            usersReference.child("UserID: \(user!.uid)").child("Settings").updateChildValues(["Search by name": 1])
        }
        else {
        //search by pseudo
            usersReference.child("UserID: \(user!.uid)").child("Settings").updateChildValues(["Search by name": 0])
        }
    }
    
    //lets user choose if map follows his location or not
    /*@objc func mapSettings(_ sender: UISwitch) {
        //get followed
        if sender.isOn {
            usersReference.child("UserID: \(user!.uid)").child("Settings").updateChildValues(["Follow user location": 1])
        }
        else {
        //be free
            usersReference.child("UserID: \(user!.uid)").child("Settings").updateChildValues(["Follow user location": 0])
        }
    }*/
    
    //create reference to firebase database
    let usersReference = Database.database().reference(withPath: "Users")
    //retrieve user ID from firebase
    let user = Auth.auth().currentUser
    
// MARK: - Constraints for view

    func setConstraintsSettings() {
        //settings label
        settingsLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 50, left: 3.5*view.frame.width/10 - 24, bottom: 0, right: 0), size: .init(width: 3*view.frame.width/10, height: 30))
        //settings image
        settingsImage.anchor(top: settingsLabel.topAnchor, leading: settingsLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: -15, left: 5, bottom: 0, right: 0), size: .init(width: 48, height: 48))
        
        //button holder
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))
        
        //tableview of settings
        tableView.anchor(top: settingsImage.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 50, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.width/2))
    }

}

//MARK: - Delegate of table view
extension settings: UITableViewDelegate, UITableViewDataSource {
    //say number of cells in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //count number of cells needed
        return 2
    }
    
    //display users on table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //says what must be in a cell
            //cell to choose which pins to display
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinDisplayChoiceCell", for: indexPath)
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            //searching users by names display this in cell
            if pinDisplaySwitch.isOn {
                cell.textLabel?.text = "Displaying everyone's pins"
            }
            //otherwise we are searching users by their usernames and say this in the cell
            else {
                cell.textLabel?.text = "Displaying connections' pins"
            }
            //cell.textLabel?.text = "Display everyone's pins"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            cell.accessoryView = pinDisplaySwitch
            cell.layer.cornerRadius = 2
            //cell.layer.borderWidth = 0.5
            return cell
        }
        //searching cell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchPseudoOrName", for: indexPath)
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            //searching users by names display this in cell
            if searchSwitch.isOn {
                cell.textLabel?.text = "Searching users by their names"
            }
            //otherwise we are searching users by their usernames and say this in the cell
            else {
                cell.textLabel?.text = "Searching users by their usernames"
            }
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            cell.layer.cornerRadius = 2
            cell.accessoryView = searchSwitch
            //cell.layer.borderWidth = 0.5
            return cell
        }
        //map settings
        /*else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "followMapLocation", for: indexPath)
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Map centers around your location"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            cell.layer.cornerRadius = 2
            cell.accessoryView = followMapSwitch
            return cell
        }*/
            //sign out cell
            /*
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "signOutCell", for: indexPath)
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Sign out"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            cell.layer.cornerRadius = 2
            //cell.layer.borderWidth = 0.5
            return cell
        }*/
    }

    //when user touches a certain row in the table view --> display his profile
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        //connection requests row selected
        //if indexPath.row == 0 {
            //go to connection requests view
          //  performSegue(withIdentifier: "settingsToConnectionRequests", sender: self)
        //}
        //row selected is sign out
        /*if indexPath.row == 2 {
            //we try to sign out and go to log in page if sign out is successful
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "settingsToLogIn", sender: self)
            } catch (let error) {
                print("Auth sign out failed: \(error)")
            }
        }*/
    }
}

//MARK: - Tab bar delegate
extension settings: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "settingsToConnections", sender: item)
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "settingsToMap", sender: item)
        }
        else {
            //go to profile
            performSegue(withIdentifier: "settingsToProfile", sender: item)
        }
    }
}
