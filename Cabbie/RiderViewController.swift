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
    @IBOutlet weak var callUberButton: UIButton!
    
    //MARK:- Properties
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLocationManager()
        
    }
    
    //MARK:- Init methods
    private func initializeLocationManager() {
        //map setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
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
    
    //MARK:- IBActions
    @IBAction private func handleLogoutTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction private func handleCallUberButtonTapped(_ sender: UIButton) {
        //grab the user's email address to form our database submission
        if let email = Auth.auth().currentUser?.email {
           
            let rideRequestDictionary: [String : Any] = [
                "email": email,
                "lat": currentLocation.latitude,
                "long": currentLocation.longitude
                ]
            
            //define the Firebase reference
            ref = Database.database().reference().child("RideRequests").childByAutoId()
            ref.setValue(rideRequestDictionary)
        }
    }
    
}
