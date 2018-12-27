//
//  DriverViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/26/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class DriverViewController: UITableViewController, CLLocationManagerDelegate {

    //MARK:- Properties
    let cellId = "rideRequestCell"
    var rideRequests: [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    
    //MARK:- IBoutlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the location manager
        initializeLocationManager()
        
        //make a request for pending ride requests
        searchForPendingRideRequests()
        
        //update the table view to reflect updated distance between driver and rider
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
    }
    
    //MARK:- Location delegate methods
    private func initializeLocationManager() {
        //map setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //driver's location?
        if let coordinates = manager.location?.coordinate {
            driverLocation = coordinates
        }
    }
    
    private func searchForPendingRideRequests() {
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            //each snapshot is a ride request
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
        }
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
        return rideRequests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        //provide the user info and distance
        let snapshot = rideRequests[indexPath.row]
        if let rideRequestDictionary = snapshot.value as? [String: Any] {
            if let email = rideRequestDictionary["email"] as? String {
                
                if let lat = rideRequestDictionary["lat"] as? Double, let long = rideRequestDictionary["long"] as? Double {
                    
                    //convert driver location as a CLLocation,
                    let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    let riderCLLocation = CLLocation(latitude: lat, longitude: long)
                    
                    let distance = distanceBetweenDriverAndRider(driver: driverCLLocation, rider: riderCLLocation)
                    
                    cell.textLabel?.text = "\(email) - \(distance)km away"
                }
            }
        }
    
        return cell
    }
    
    private func distanceBetweenDriverAndRider(driver: CLLocation, rider: CLLocation) -> Double {
        
        let distanceInKM = driver.distance(from: rider) / 1000
        let roundedDistance = round(distanceInKM * 100) / 100
        
        return roundedDistance
    }
    
    //MARK:- Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AcceptRequestViewController {
            
            //check that the sender is a snapshot object
            if let snapshot = sender as? DataSnapshot {
                //grab email, lat and long
                if let rideRequestDictionary = snapshot.value as? [String: Any] {
                    if let email = rideRequestDictionary["email"] as? String {
                        if let lat = rideRequestDictionary["lat"] as? Double, let long = rideRequestDictionary["long"] as? Double {
                                destinationVC.requestEmail = email
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                destinationVC.requestLocation = location
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segue to the accept request view - sender should reflect the user info
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptRequestSegue", sender: snapshot)
    }
    


}
