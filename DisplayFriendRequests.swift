//
//  DisplayFriendRequests.swift
//  HammockUP
//
//  Created by Anthony Guillard on 30/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class DisplayFriendRequests: UIViewController {

    //Outlets
    
    @IBOutlet var connectionRequestsTableView: UITableView!
    
    //MARK: - global structure variables
    let databaseReference = Database.database().reference(withPath: "Users")
    let usernameReference = Database.database().reference(withPath: "Usernames")
    var connectionRequests: [String] = []
    let currentUser = Auth.auth().currentUser
    
    //freind requests label
    lazy var friendRequestLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: view.frame.width/9, y: 50, width: view.frame.width/2 + 50, height: 35))
        label.text = "Connection Requests"
        label.font = UIFont(name: "Rockwell", size: 24.0)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //friend request image
    lazy var friendRequestImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width/2 + 95, y: 20, width: 60, height: 60))
        imageView.image = UIImage(named: "add")
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
    
    //text saying add some friends in connections!
    lazy var noFriendRequestText: UITextView = {
        let textView = UITextView(frame: CGRect(x: 10, y: view.frame.height/2 - 40, width: view.frame.width - 20, height: 80))
        textView.text = "No pending requests 🧐"
        textView.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        textView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        textView.textAlignment = .center
        textView.textColor = .white
        return textView
    }()

    //MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        retrieveConnectionRequest()
        connectionRequestsTableView.tableFooterView = UIView()
        connectionRequestsTableView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        connectionRequestsTableView.dataSource = self
        connectionRequestsTableView.delegate = self
        // Do any additional setup after loading the view.
        
        view.addSubview(friendRequestImage)
        view.addSubview(friendRequestLabel)
        view.addSubview(buttonHolder) 
        
        //delegate for buttons
        buttonHolder.delegate = self
        
        //add constraints
        setConstraintRequests()
    }

    //get connections requests from server
    func retrieveConnectionRequest() {
        //get connected user identity
        let currentUser = Auth.auth().currentUser
        //retrieve incoming friends requests
        databaseReference.child("UserID: \(currentUser!.uid)").child("Received Connection Requests From").observeSingleEvent(of: .value, with: { (snapshot) in
            for val in snapshot.children {
                let subSnap = val as! DataSnapshot
                self.connectionRequests.append(subSnap.value as! String)
            }
            DispatchQueue.main.async {
                self.connectionRequestsTableView.reloadData()
            }
        })
    }
    
    // MARK: - Constraint
    
    func setConstraintRequests() {
        
        //connection label
        friendRequestLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 50, left: view.frame.width/9, bottom: 0, right: 0), size: .init(width: 2*view.frame.width/3, height: 30))
        
        //connection picture
        friendRequestImage.anchor(top: friendRequestLabel.topAnchor, leading: friendRequestLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: -15, left: 5, bottom: 0, right: 0), size: .init(width: 48, height: 48))
        
        //button holder
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))
        
        //tableview of connection list
        connectionRequestsTableView.anchor(top: friendRequestImage.bottomAnchor, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 50, left: 0, bottom: 50, right: 0))
    }
}

//MARK: - table data and delegate
extension DisplayFriendRequests: UITableViewDataSource, UITableViewDelegate {
    
    //number of cells to be displayed --> number of requests
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if connectionRequests.count == 0 {
            view.addSubview(noFriendRequestText)
        }
        return connectionRequests.count
    }
    
    //display users on table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MGSwipeTableCell
        cell.rightButtons = [MGSwipeButton(title: "Accept", backgroundColor: UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)), MGSwipeButton(title: "Deny", backgroundColor: .red)]
        cell.rightSwipeSettings.transition = .clipCenter
        let connectionRequestName = connectionRequests[indexPath.row]
        //display in cell his name of the incoming friend request
        cell.textLabel?.text = connectionRequestName
        cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        cell.layer.cornerRadius = 2
        //delegate to handle button
        cell.delegate = self as MGSwipeTableCellDelegate
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "Avenir", size: 16.0)
        //acceptConnection.tag = indexPath.row
        //denyConnection.tag = -indexPath.row
        return cell
    }
    
    //when user touches a certain row in the table view --> display his profile
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let OtherUserVC = OtherUserProfiles()
        //pass username of friend request to otheruserprofiles to display his profile
        //pass pseudo onto other user VC
        OtherUserVC.searchedUserPseudo = connectionRequests[indexPath.row]
        performSegue(withIdentifier: "FriendRequestToOtherUser", sender: nil)
    }
}

//MARK: - handle tapped buttons delegate
extension DisplayFriendRequests: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        //action perform when tapping accept button
        if index == 0 {
            print("Accept TAPPED BUTTON")
            var currUserPseudo = ""
            var retrievedPseudo = ""
            //accept friend request
            //add name of demanding user to current user's friend list
            databaseReference.child("UserID: \(currentUser!.uid)").child("Friends with").childByAutoId().setValue(cell.textLabel?.text)
            // and also remove the name of the demanding person from request list
            databaseReference.child("UserID: \(currentUser!.uid)").child("Received Connection Requests From").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    let subSnap = child as! DataSnapshot
                    //if searched pseudo of demanding person is equal to the one in the table then delete this request
                    if (subSnap.value as! String) == cell.textLabel?.text {
                        //delete value by setting it to nil
                        self.databaseReference.child("UserID: \(self.currentUser!.uid)").child("Received Connection Requests From").child(subSnap.key).setValue(nil)
                        DispatchQueue.main.async {
                            //reload table view when accepting a request
                            //and reload the connection requests
                            self.retrieveConnectionRequest()
                            self.connectionRequestsTableView.reloadData()
                        }
                    }
                }
            })
            //log us as afriend for other demanding user and delete sent connection request to node for us
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
                        if cell.textLabel?.text == retrievedPseudo{
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
        }
        
        //action perform when tapping deny button
        if index == 1 {
            print("DENY TAPPED BUTTON")

            var currUserPseudo = ""
            var retrievedPseudo = ""
            
            // deny friend request by simply removing it from the database
            databaseReference.child("UserID: \(currentUser!.uid)").child("Received Connection Requests From").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    let subSnap = child as! DataSnapshot
                    //if searched pseudo of demanding person is equal to the one in the table then delete this request
                    if (subSnap.value as! String) == cell.textLabel?.text {
                        //delete value by setting it to nil
                        self.databaseReference.child("UserID: \(self.currentUser!.uid)").child("Received Connection Requests From").child(subSnap.key).setValue(nil)
                        DispatchQueue.main.async {
                            //reload table view when denying a request // and reload the connection requests
                            self.retrieveConnectionRequest()
                            self.connectionRequestsTableView.reloadData()
                        }
                    }
                }
            })
            
            //remove it from the other user as well
            usernameReference.observeSingleEvent(of: .value, with: { (snapshotUser) in
                //gather currently connected user username
                self.usernameReference.child(self.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshotCurrUser) in
                    currUserPseudo = snapshotCurrUser.value as! String
                    for child in snapshotUser.children {
                        let subSnapUser = child as! DataSnapshot
                        //get child key
                        let key = subSnapUser.key
                        retrievedPseudo = subSnapUser.value as! String
                        if cell.textLabel?.text == retrievedPseudo {
                            //remove sent connection to since usr has denied it
                            self.databaseReference.child("UserID: \(key)").child("Sent Connection Requests To").observeSingleEvent(of: .value, with: { (snappy) in
                                for grandChild in snappy.children {
                                    let grandSnappy = grandChild as! DataSnapshot
                                    //check if the suer pseudo connected is equal to the one in the database link of the viewed profile user
                                    if grandSnappy.value as! String == currUserPseudo {
                                        self.databaseReference.child("UserID: \(key)").child("Sent Connection Requests To").child(grandSnappy.key).setValue(nil)
                                    }//end of if grandsnappy value is equal to current user pseudo
                                }//for grandchild in snappychildren
                            })//end of observation on sent connection request node
                        }//end of if retrieved pseudo is equal to the one of the cell
                    }//end of child in snapshotuserc hildren
                })//end of osbervation on its pseudo to gather the current user pseudo
            })//end of observation of usernamereference
        }
        return true
    }
}

//MARK: - Tab bar delegate
extension DisplayFriendRequests: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "requestToConnections", sender: item)
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "requestToMap", sender: item)
        }
        else {
            //go to profile
            performSegue(withIdentifier: "requestToProfile", sender: item)
        }
    }
}
