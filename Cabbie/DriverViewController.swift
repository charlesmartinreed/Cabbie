//
//  DriverViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/26/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DriverViewController: UITableViewController {

    //MARK:- Properties
    let cellId = "rideRequestCell"
    
    //MARK:- IBoutlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- IBActions
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        } catch {
            print("Unable to sign out")
        }
    }
    

    //MARK:- Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .red
        cell.textLabel?.text = "Rider #: \(indexPath.row)"
        return cell
    }

}
