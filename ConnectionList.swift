//
//  ConnectionList.swift
//  HammockUP
//
//  Created by Anthony Guillard on 28/04/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class ConnectionList: UIViewController {

    //MARK: - VARIABLE DEFINITION
    //table view for connection list
    lazy var myConnectionsTable: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 130, width: view.frame.width, height: 460))
        tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "ConnectionCell")
        tableView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    //freind connection label
    lazy var ConnectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Connections"
        label.font = UIFont(name: "Rockwell", size: 24.0)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    //friend request image
    lazy var ConnectionImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: view.frame.width/2 + 35, y: 20, width: 60, height: 60))
        imageView.image = UIImage(named: "friendList")
        return imageView
    }()
    
    //text saying add some friends in connections!
    lazy var noFriendsText: UITextView = {
        let textView = UITextView(frame: CGRect(x: 10, y: view.frame.height/2 - 40, width: view.frame.width - 20, height: 80))
        textView.text = "Add some connections in the Community tab 😉!"
        textView.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        textView.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        textView.textAlignment = .center
        textView.textColor = .white
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

    //get current user UID
    //currently connected user
    let currUserUID = Auth.auth().currentUser!.uid
    //username reference
    let usersReference = Database.database().reference(withPath: "Users")
    let databaseReference = Database.database().reference(withPath: "Users")
    //hold desired connections
    var connections: [String] = []
    
    
    //MARK: - VIEWDID load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        view.addSubview(myConnectionsTable)
        view.addSubview(ConnectionLabel)
        view.addSubview(ConnectionImage)
        view.addSubview(buttonHolder)
        
        myConnectionsTable.delegate = self
        myConnectionsTable.dataSource = self
        // Do any additional setup after loading the view.
        //constraints
        setConstraintsList()
        
        //delegate for buttons
        buttonHolder.delegate = self
    }
    
    //retrieve currently connected user connections
    func retrieveUserConnections() {
        usersReference.child("UserID: \(currUserUID)").child("Friends with").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let snappy = child as! DataSnapshot
                self.connections.append(snappy.value as! String)
                DispatchQueue.main.async {
                    self.myConnectionsTable.reloadData()
                }
            }
        })
    }
    
    //MARK: - Constraints for view
    func setConstraintsList() {
        
        //connection label
        ConnectionLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 50, left: 8.5*view.frame.width/30 - 24, bottom: 0, right: 0), size: .init(width: 4.5*view.frame.width/10, height: 30))
        
        //connection picture
        ConnectionImage.anchor(top: ConnectionLabel.topAnchor, leading: ConnectionLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: -15, left: 5, bottom: 0, right: 0), size: .init(width: 48, height: 48))
        
        //button holder
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))
        
        //tableview of connection list
        myConnectionsTable.anchor(top: ConnectionImage.bottomAnchor, leading: view.leadingAnchor, bottom: buttonHolder.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 50, left: 0, bottom: 50, right: 0))
    }
}

//MARK:- table delegate and data source
extension ConnectionList: UITableViewDataSource, UITableViewDelegate {
    //number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //check if he has any friends
        if connections.count == 0 {
            view.addSubview(noFriendsText)
            //noFriendsLabel.anchor(top: ConnectionLabel.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height/4, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: view.frame.height / 8))
        }
        return connections.count
    }
    
    //decide what is inside of a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //says what must be in a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell", for: indexPath) as! MGSwipeTableCell
        //inside of a cell is the pseudo or name of a user
        cell.textLabel?.text = connections[indexPath.row]
        cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        cell.layer.cornerRadius = 2
        cell.textLabel?.textColor = .white
        //delegate to handle button
        cell.delegate = self as MGSwipeTableCellDelegate
        cell.textLabel?.font = UIFont(name: "Avenir", size: 16.0)
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red)]
        cell.rightSwipeSettings.transition = .clipCenter
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - swipe delegate cell
extension ConnectionList: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        var currUserPseudo = ""
        var retrievedPseudo = ""
        
        //delete connection for connected user
        databaseReference.child("UserID: \(currUserUID)").child("Friends with").childByAutoId().child(cell.textLabel!.text!).setValue(nil)
        DispatchQueue.main.async {
            self.myConnectionsTable.reloadData()
        }
        
        //delete connection for deleted user
        usersReference.observeSingleEvent(of: .value, with: { (snapshotUser) in
            //gather currently connected user username
            self.usersReference.child(self.currUserUID).observeSingleEvent(of: .value, with: { (snapshotCurrUser) in
                currUserPseudo = snapshotCurrUser.value as! String
                for child in snapshotUser.children {
                    let subSnapUser = child as! DataSnapshot
                    //get child key
                    let key = subSnapUser.key
                    retrievedPseudo = subSnapUser.value as! String
                    if cell.textLabel?.text == retrievedPseudo {
                        //remove sent connection to since usr has denied it and gather the auto ID so we gotta look for it
                        self.databaseReference.child("UserID: \(key)").child("Friends with").observeSingleEvent(of: .value, with: { (snappy) in
                            for grandChild in snappy.children {
                                let grandSnappy = grandChild as! DataSnapshot
                                //check if the suer pseudo connected is equal to the one in the database link of the viewed profile user
                                if grandSnappy.value as! String == currUserPseudo {
                                    //remove us as friends since we deleted him
                                    self.databaseReference.child("UserID: \(key)").child("Friends with").child(grandSnappy.key).setValue(nil)
                                }
                            }
                        })
                    }
                }
            })
        })
        
        print("DELETE TAPPED BUTTON")
        return true
    }
}


//MARK: - Tab bar delegate
extension ConnectionList: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //perform segue to community
            performSegue(withIdentifier: "listToConnections", sender: item)
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "listToMap", sender: item)
        }
        else {
            //go to profile
            performSegue(withIdentifier: "listToProfile", sender: item)
        }
    }
}

