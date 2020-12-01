//
//  connectUP.swift
//  HammockUP
//
//  Created by Anthony Guillard on 07/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Firebase

class connectUP: UIViewController {
    
    //Outlets
    @IBOutlet var tableView: UITableView!
    
    //MARK: - Global strucuture variables
    //create reference to users
    let usersReference = Database.database().reference(withPath: "Users")
    //currently connected user
    let currUserUID = Auth.auth().currentUser!.uid
    //username reference
    let usernameReference = Database.database().reference(withPath: "Usernames")
    //hold desired users
    var filteredUsers: [String] = []
    var filteredPseudos: [String] = []
    var offset: Int = 0;
    var users: [String] = []
    var pseudos: [String] = []
    var pseudo: String = ""
    var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = false
        
        //make cancel button kelly green
        search.searchBar.tintColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)//UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
        search.searchBar.barTintColor = UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)

        //font and placehodler
        search.searchBar.searchTextField.font = UIFont(name: "Avenir", size: 18.0)
        search.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for other users", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        //search text field color
        let textFieldInsideSearchBar = search.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        return search
        
    }()
    
    
    //bar button for side menu
    var sideMenuButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(named: "menuicon")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(SWRevealViewController.revealToggle(_:)))
        return barButton
    }()
    
    //message saying hello to currently connected user (with his username)
    lazy var messageToUser: UITextView = {
        let helloToUser = UITextView()
        //helloToUser.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        helloToUser.textAlignment = .center
        var connectedUsername = ""
        //get currently connected user username
        usernameReference.child(currUserUID).observeSingleEvent(of: .value, with: {(snapshot) in
            connectedUsername = snapshot.value as! String
            DispatchQueue.main.async {
                helloToUser.text = "🌳 Feel like going outside \(connectedUsername)? 🌳"
            }
        })
        helloToUser.isUserInteractionEnabled = false
        helloToUser.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        helloToUser.layer.cornerRadius = 10.0
        helloToUser.backgroundColor = UIColor.clear
        //helloToUser.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        //helloToUser.layer.backgroundColor = CGColor(srgbRed: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        helloToUser.textColor = .white
        return helloToUser
    }()
    
    //background image
    lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        imageView.image = UIImage(named: "backgroundImage")
        return imageView
    }()
    
    //tab bar that holds the buttons
    lazy var buttonHolder: UITabBar = {
        let tabBar = UITabBar()
        tabBar.backgroundColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)
        tabBar.barTintColor = UIColor(red: 50/255, green: 70/255, blue: 56/255, alpha: 1)
        tabBar.itemPositioning = .fill
        tabBar.isTranslucent = true
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
        tabBar.selectedItem = communityButton 
        tabBar.isTranslucent = true
        return tabBar
    }()


    //variables for search bar filtering
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    //all users' names and first names
    func retrieveAllUsers() {
        //hold all users
        var userFullName = ""
        self.usersReference.observeSingleEvent(of: .value, with: {(snapshot) in
        // if marker ID has children it means this marker has already been created
            //go in User ID uid
            if snapshot.hasChildren() {
                // go through all user ids
                for child in snapshot.children {
                    //initialize a user name and first name
                    var userFirstName = ""
                    var userLastName = ""
                    var pseudo = ""
                    let subSnap = child as! DataSnapshot
                    //get child key with format UserID: uid
                    let key = subSnap.key
                    // go inside User ID to retrieve name and first name of every user
                    //DispatchQueue.main.sync {
                        self.usersReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                            // go through user parammters to only retrieve his name and first name
                            for grandChild in snapshot2.children {
                                let nameGatherer = grandChild as! DataSnapshot
                                if nameGatherer.key == "First Name"{
                                    userFirstName = nameGatherer.value as! String
                                }
                                if nameGatherer.key == "Last Name"{
                                    userLastName = nameGatherer.value as! String
                                }
                                if nameGatherer.key == "Pseudo"{
                                    pseudo = nameGatherer.value as! String
                                }
                            }//end of loop inside user parameters
                            //add his full name to the list of users which we will then filter later on
                            userFullName = userFirstName + " " + userLastName
                            self.users.append(userFullName)
                            self.pseudos.append(pseudo)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        })// end of observation of one user parameters
                    //}//end of dispatch async
                }//end of looking inside the user ID node
            }//end of if there are users children
        })//end of observation of users reference
    }
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImage)
        //display all users in table
        tableView.removeFromSuperview()
        retrieveAllUsers()
        //loadMoreUsers()
        //display hello to user
        view.addSubview(messageToUser)
        view.addSubview(buttonHolder)
        
        //search results are the search bar itself input
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        //change navigation controller color before called upon
        navigationController?.view.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        //its color when touched upon which activates it
        navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)

        //xxc
        definesPresentationContext = true
        
        view.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        //delegate protocol for search controller and button tab bar
        searchController.delegate = self as UISearchControllerDelegate
        buttonHolder.delegate = self
        
        //menu appearance
        //self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = sideMenuButton
        sideMenu()
        
        //make constraints appear
        setConstraintsConnect()
    }
    
    //only display users that correspond to input text
    func filterContentForSearchText(_ searchText: String) {
        //to return users if person searches for users
        filteredUsers = users.filter { (users: String) -> Bool in
            return users.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    //only display users that correspond to input text
    func filterPseudosForSearchText(_ searchText: String) {
        //to return users if person searches for users
        filteredPseudos = users.filter { (pseudos: String) -> Bool in
            return pseudos.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    //find matching username for typed in name
    func findMatchingUsername (typedName: String, nameNumber: Int = 0) -> (String) {
        var pseudo = ""
        var indicesList : [Int] = []
        //get all occurences of the typed name
        for (index, element) in users.enumerated()
        {
            if typedName == element {
                indicesList.append(index)
            }
        }
        //based on the occurences, get the occurence corresponding to the number of the same name desired
        pseudo = pseudos[indicesList[nameNumber]]
        //return pseudo corresponding to names, the next number name to be used, and the total number of similar names
        return (pseudo)
    }
    
    //retrieve search settings
    func getSearchSettings() -> Int {
        //retrieve user setting defined by him
        var searchSetting = 1
        let settingsRef = Database.database().reference(withPath: "Users").child("UserID: \(currUserUID)").child("Settings").child("Search by name")
        settingsRef.observeSingleEvent(of: .value, with: {(snapshot) in
            DispatchQueue.main.async {
                searchSetting = snapshot.value as! Int
            }
        })
        return searchSetting
    }
    
    //side menu appearance
    func sideMenu() {
        if revealViewController() != nil {
            sideMenuButton.target = revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = view.frame.width/2
            self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
    //find number of similar typed names and return the number of matching names and true if there are more than one similar names
    func findNumberOfPreviousMatchingNames (typedName: String, filteredUsers: [String]) -> (Int, Bool){
        var indicesList : [Int] = []
        for (index, element) in filteredUsers.enumerated()
        {
            if typedName == element {
                indicesList.append(index)
            }
        }
        let numberMatchingNames = indicesList.count
        return (numberMatchingNames, indicesList.count > 1)
    }
    
    //find matching name for typed in username
    func findMatchingName (typedUsername: String) -> String {
        var name = ""
        //find index of username to apply it to user as well
        if let index = pseudos.firstIndex(of: typedUsername) {
            name = users[index]
        }
        return name
    }
    
    //load more users on table view
    /*func loadMoreUsers() {
        //hold all users
        var userFullName = ""
        var numberUsersRetrieved = 0
        self.usersReference.observeSingleEvent(of: .value, with: {(snapshot) in
        // if marker ID has children it means this marker has already been created
            //go in User ID uid
            if snapshot.hasChildren() {
                // go through all user ids
                for child in snapshot.children {
                    if numberUsersRetrieved < 10 {
                        //initialize a user name and first name
                        var userFirstName = ""
                        var userLastName = ""
                        var pseudo = ""
                        let subSnap = child as! DataSnapshot
                        //get child key with format UserID: uid
                        let key = subSnap.key
                        // go inside User ID to retrieve name and first name of every user
                        //DispatchQueue.main.sync {
                            self.usersReference.child(key).observeSingleEvent(of: .value, with: { (snapshot2) in
                                // go through user parammters to only retrieve his name and first name
                                for grandChild in snapshot2.children {
                                    let nameGatherer = grandChild as! DataSnapshot
                                    if nameGatherer.key == "First Name"{
                                        userFirstName = nameGatherer.value as! String
                                    }
                                    if nameGatherer.key == "Last Name"{
                                        userLastName = nameGatherer.value as! String
                                    }
                                    if nameGatherer.key == "Pseudo"{
                                        pseudo = nameGatherer.value as! String
                                    }
                                }//end of loop inside user parameters
                                //add his full name to the list of users which we will then filter later on
                                userFullName = userFirstName + " " + userLastName
                                self.users.append(userFullName)
                                self.pseudos.append(pseudo)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            })// end of observation of one user parameters
                        //}//end of dispatch async
                    } //end of looking inside the user ID node
                    numberUsersRetrieved = numberUsersRetrieved + 1
                }
            }//end of if there are users children
        })//end of observation of users reference
    }
 */
    
    //MARK: - Constraints for view
    func setConstraintsConnect() {
        
        //for the buttons
        buttonHolder.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 70))
        
        //for the text holding the username
        messageToUser.anchor(top: view.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 3, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 75))
        
    }
    
    
    // MARK: - Navigation
    //prepare for segue to send over username
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToOtherUser" {
            let OtherUserVC = segue.destination as! OtherUserProfiles
            OtherUserVC.searchedUserPseudo = pseudo
        }
    }

}

//MARK: - Table View delegate and data
extension connectUP: UITableViewDataSource, UITableViewDelegate {
    
    //say number of cells in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //count number of cells needed
        if isFiltering {
            return filteredUsers.count
        }
        return users.count
    }
    
    //if we are about to display a certain cell
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //check if row thats about to be displayed is the last row
        if indexPath.row == users.count - 1 {
            //add an activity loader
            let activitySpin = UIActivityIndicatorView(style: .medium)
            activitySpin.startAnimating();
            activitySpin.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
            tableView.tableFooterView = activitySpin
            tableView.tableFooterView?.isHidden = false
            //load more users
            //loadMoreUsers()
        }
    }*/
    
    //display users on table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //says what must be in a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user: String
        let pseudo: String
        let numberMatchingNames: Int
        let oneOrMoreName: Bool
        let searchSetting: Int
        //get how the user wants to search
        searchSetting = getSearchSettings()
        //if we are fitlering the results
        if isFiltering {
            //searching by name
            if searchSetting == 1 {
                //get filtered user name
                user = filteredUsers[indexPath.row]
                //find out how many similar names of user there are
                (numberMatchingNames, oneOrMoreName) = findNumberOfPreviousMatchingNames(typedName: user, filteredUsers: filteredUsers)
                //retrieve username
                //if the name of user corresponds to several users
                if oneOrMoreName == true {
                    pseudo = findMatchingUsername(typedName: user, nameNumber: numberMatchingNames - 1)
                }
                //if it is unique
                else {
                    pseudo = findMatchingUsername(typedName: user)
                }
            }
            //searching by pseudo
            else {
                //get filtered pseudo
                pseudo = filteredPseudos[indexPath.row]
                user = findMatchingName(typedUsername: pseudo)
            }
        //if not filtering
        } else {
            user = users[indexPath.row]
            pseudo = pseudos[indexPath.row]
        }
        cell.textLabel?.text = user
        cell.detailTextLabel?.text = pseudo
        
        //cell textlabel properties
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name:"Avenir-Heavy", size: 16.0)
        
        //cell detail text label
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.font = UIFont(name: "Avenir", size: 14.0)
        
        //cell properties
        cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 2

        return cell
    }

    //when user touches a certain row in the table view --> display his profile
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        //let user: String
        let searchSetting: Int
        let user: String
        let numberMatchingNames: Int
        let oneOrMoreName: Bool
        //get how the user wants to search
        searchSetting = getSearchSettings()
        //if filtering results
        if isFiltering {
            //searching by name
            if searchSetting == 1 {
                //get filtered user name
                user = filteredUsers[indexPath.row]
                //find out how many similar names of user there are
                (numberMatchingNames, oneOrMoreName) = findNumberOfPreviousMatchingNames(typedName: user, filteredUsers: filteredUsers)
                //retrieve username
                //if the name of user corresponds to several users
                if oneOrMoreName == true {
                    pseudo = findMatchingUsername(typedName: user, nameNumber: numberMatchingNames - 1)
                }
                //if it is unique
                else {
                    pseudo = findMatchingUsername(typedName: user)
                }
            }
            //searching by pseudo
            else {
                //get filtered pseudo
                pseudo = filteredPseudos[indexPath.row]
            }
        //if not filtering
        } else {
            //name can be identicial, not pseudos
            pseudo = pseudos[indexPath.row]
        }
        //let OtherUserVC = OtherUserProfiles()
        //pass username to otheruserprofiles to display his profile
        //pass pseudo onto other user VC
        //OtherUserVC.searchedUserPseudo = pseudo
        //connectUp.pushViewController(OtherUserProfiles, animated: true)
        //DispatchQueue.main.async {
        performSegue(withIdentifier: "searchToOtherUser", sender: self)
        //}
    }
}

//MARK: - search results update
//to update results in search bar
extension connectUP: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchSetting: Int
        //get how the user wants to search
        searchSetting = getSearchSettings()
        //searching by name
        if searchSetting == 1 {
            filterContentForSearchText(searchBar.text!)
        }
        //searching by pseudo
        else {
            filterPseudosForSearchText(searchBar.text!)
        }
    }
}

//MARK: - search results delegate
extension connectUP: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        //show all users
        view.addSubview(tableView)
        tableView.anchor(top: navigationController?.navigationBar.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2 * view.frame.height / 3))
        messageToUser.removeFromSuperview()
        //remove constant
        //for the text holding the username
        messageToUser.deActiveAnchor(top: view.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 3, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 75))
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        //redismiss all users
        tableView.removeFromSuperview()
        tableView.deActiveAnchor(top: navigationController?.navigationBar.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 2 * view.frame.height / 3))
        view.addSubview(messageToUser)
        //for the text holding the username
        messageToUser.anchor(top: view.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: view.frame.height / 3, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 75))
    }
}

//MARK: - UITabBar Delegate
extension connectUP: UITabBarDelegate {
    
    //perform segues when certain buttons are performed
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //perform segues
        if item.tag == 1 {
            //do nothin gas we are in community
        }
        else if item.tag == 2 {
            performSegue(withIdentifier: "connectionsToMap", sender: item)
            //go to map
        }
        else {
            //go to profile
            performSegue(withIdentifier: "connectionsToProfile", sender: item)
        }
    }
}
