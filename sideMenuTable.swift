//
//  sideMenuTable.swift
//  HammockUP
//
//  Created by Anthony Guillard on 03/04/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import StoreKit
import Firebase

class SideMenuTable: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //remove unsused cells
        //view.backgroundColor = UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //repeat only once
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //settings and information, section, and rate the app
        return 6
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //tell which cell it is
            let cell = tableView.dequeueReusableCell(withIdentifier: "connectionsCell", for: indexPath)
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Connections"
            cell.imageView?.image = UIImage(named: "friendList")
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.textLabel?.textColor = .white
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            //cell.layer.cornerRadius = 2
            //cell.layer.borderWidth = 0.5
            return cell
        }
        else if indexPath.row == 1 {
            //tell which cell it is
            let cell = tableView.dequeueReusableCell(withIdentifier: "connectionRequestsCell", for: indexPath)
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Requests"
            cell.imageView?.image = UIImage(named: "add")
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.textLabel?.textColor = .white
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            //cell.layer.cornerRadius = 2
            //cell.layer.borderWidth = 0.5
            return cell
        }
        else if indexPath.row == 2 {
            //tell which cell it is
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            //set image
            cell.imageView?.image = UIImage(named: "settings")
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Settings"
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.textLabel?.textColor = .white
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            //cell.layer.cornerRadius = 5
            //cell.layer.borderWidth = 0.5
            return cell
        }
        else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath)
            //set image
            cell.imageView?.image = UIImage(named: "info")
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Information"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            //cell.layer.cornerRadius = 5
            //cell.layer.borderWidth = 0.5
            return cell
        }
        else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rateAppCell", for: indexPath)
            //set image
            cell.imageView?.image = UIImage(named: "rate")
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Rate the app"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "signOutCell", for: indexPath)
            //set image
            cell.imageView?.image = UIImage(named: "signout")
            cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            //set text
            cell.textLabel?.text = "Sign Out"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18.0)
            cell.backgroundColor = UIColor(red: 63/255, green: 122/255, blue: 77/255, alpha: 1)
            return cell
        }

        // Configure the cell...
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //deselect select row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //settings row selected
        if indexPath.row == 0 {
            //go to friends list
            performSegue(withIdentifier: "sideMenuToConnectionList", sender: self)
        }
        //information celll selected
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "sideMenuToFriendRequests", sender: self)
        }
        //rate app cell selected
        else if indexPath.row == 2 {
            //go to settings view
            performSegue(withIdentifier: "sideMenuToSettings", sender: self)
        }
        else if indexPath.row == 3 {
            //go to information view
            performSegue(withIdentifier: "sideMenuToInformation", sender: self)
        }
        else if indexPath.row == 4 {
            //ask userto review app
            //guard let writeReviewURL = URL(string: //"https://itunes.apple.com/app/idXXXXXXXXXX?action=write-review")
            //else { fatalError("Expected a valid URL") }
            //UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
        else {
            //we try to sign out and go to log in page if sign out is successful
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "sideMenuToLogIn", sender: self)
            } catch (let error) {
                print("Auth sign out failed: \(error)")
            }

        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
