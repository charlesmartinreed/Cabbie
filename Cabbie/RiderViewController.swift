//
//  RiderViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/25/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callCabbieButton: UIButton!
    
    //MARK:- Properties
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var cabHasBeenCalled = false
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLocationManager()
        checkForPendingCabbieRide()
        
    }
    
    //MARK:- Init methods
    private func initializeLocationManager() {
        //map setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    private func checkForPendingCabbieRide() {
        if let email = Auth.auth().currentUser?.email {
            //search DB for particular ride request
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                //stop listening and reflect that the user is currently awaiting Cabbie
                self.cabHasBeenCalled = true
                self.callCabbieButton.setTitle("Cancel Cabbie", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
            })
        }
    }
    
    //MARK:- Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinates = manager.location?.coordinate {
            
            //find the center of where the user is located and update the map accordingly
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: center, span: span)
            
            //set the user location
            currentLocation = center
            
            mapView.setRegion(region, animated: true)
            
            //create a mapAnnotation
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Current Location"
            mapView.addAnnotation(annotation)
        }
    }
    
    private func cancelCabbieRide(riderInfo: [String: Any]) {
        cabHasBeenCalled = false
        callCabbieButton.setTitle("Call a Cabbie", for: .normal)
        
        //remove the data from the database, searching for email
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: riderInfo["email"]).observe(.childAdded) { (snapshot) in
            //remove the thing
            snapshot.ref.removeValue()
            
            //stop the add-delete entry loop
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
    }
    
    //MARK:- IBActions
    @IBAction private func handleLogoutTapped(_ sender: UIBarButtonItem) {
        //because we've got our mapView embedded in a Nav Controller
        navigationController?.dismiss(animated: true, completion: nil)
        
        do {
            try Auth.auth().signOut()
            //print("Successfully logged out user.")
        } catch {
            print("Unable to log out user.")
        }
    }
    
    @IBAction private func handleCallCabbieButtonTapped(_ sender: UIButton) {
        //grab the user's email address to form our database submission
        if let email = Auth.auth().currentUser?.email {
            let rideRequestDictionary: [String : Any] = [
                "email": email,
                "lat": currentLocation.latitude,
                "long": currentLocation.longitude]
            
            
            
            //check to see whether or not cab has been summoned
            if cabHasBeenCalled {
                //cancel
                cancelCabbieRide(riderInfo: rideRequestDictionary)
            } else {
                //cab has not been hailed
                //define the Firebase reference
                ref = Database.database().reference().child("RideRequests").childByAutoId()
                ref.setValue(rideRequestDictionary)
                
                cabHasBeenCalled = true
                callCabbieButton.setTitle("Cancel Cabbie", for: .normal)
            }
        }
    }
    
}
