//
//  ItemsTableViewController.swift
//  ToDo App
//
//  Created by echessa on 8/11/16.
//  Copyright © 2016 Echessa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ItemsTableViewController: UITableViewController {

    var user: User!
    var items = [Item]()
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        startObservingDatabase()
        
        
        ref.observeSingleEvent(of: .childAdded, with: { snapshot in
            
            if !snapshot.exists() { return }
            
            print(snapshot)
            
            let key = snapshot.key
            print(key)
            
            let dict = snapshot.value as! [String: AnyObject]
            let seat = dict["seat"]
            
            print(seat)
           

        })
        
        //This brings all users uid's fields and prints them
        //This code will be used to show the users profile at the top of the page
        databaseHandle = ref.child("users/\(self.user.uid)").observe(.childAdded, with: { (data) in
            
            print(data.key)
            print(data.value!)
            print("_break_")
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items)
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(items)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.seat
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            item.ref?.removeValue()
        }
    }
    
    @IBAction func didTapSignOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "SignOut", sender: nil)
        } catch let error {
            assertionFailure("Error signing out: \(error)")
        }
    }
    
    @IBAction func didTapAddItem(_ sender: UIBarButtonItem) {
        let prompt = UIAlertController(title: "To Do App", message: "To Do Item", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            self.ref.child("users").child(self.user.uid).child("seat").setValue(userInput)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
        
    }
    
    func startObservingDatabase () {
        databaseHandle = ref.child("users/\(self.user.uid)/seat").observe(.value, with: { (snapshot) in
            var newItems = [Item]()
            
            for itemSnapShot in snapshot.children {
                let item = Item(snapshot: itemSnapShot as! DataSnapshot)
                newItems.append(item)
            }
            
            print("updated data")
            self.items = newItems
            self.tableView.reloadData()
            
        })
    }
    
    deinit {
        ref.child("users/\(self.user.uid)/seat").removeObserver(withHandle: databaseHandle)
    }
}
