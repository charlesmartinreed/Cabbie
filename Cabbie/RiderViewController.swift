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

class RiderViewController: UIViewController, CLLocationManagerDelegate, DriverViewDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callCabbieButton: UIButton!
    
    //MARK:- Properties
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    
    var cabHasBeenCalled = false
    var driverIsOnTheWay = false
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create the driver instance
        let driver = DriverViewController()
        driver.delegate = self

        initializeLocationManager()
        checkForPendingCabbieRide()
        print("\(driverLocation.latitude)", "\(driverLocation.longitude)")
        
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
                //self.checkForDriverLocationChange()
                
                //reflect how far away the driver is on the rider's UI
                if let rideRequestDictionary = snapshot.value as? [String:Any] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLong = rideRequestDictionary["driverLong"] as? Double {
                            //we know the driver is coming, update the driver location
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLong)
                            self.driverIsOnTheWay = true
                            self.displayDriverAndRiderOnMap()
                            
                            //reflect changes to the driver's location on the mapView, in realtime
                            self.checkForDriverLocationChange()
                        }
                    }
                }
            })
        }
    }
    
    private func checkForDriverLocationChange() {
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                if let rideRequestDictionary = snapshot.value as? [String:Any] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLong = rideRequestDictionary["driverLong"] as? Double {
                            //we know the driver is coming, update the driver location
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLong)
                            self.driverIsOnTheWay = true
                            self.displayDriverAndRiderOnMap()
                            //we don't end the observance here because we always want to know if this location is changin
                        }
                    }
                }

            }
        }
    }
    
    private func displayDriverAndRiderOnMap() {
        //show both driver and rider on the map to illustrate distance between them
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = distanceBetweenDriverAndRider(driver: driverCLLocation, rider: riderCLLocation)
        
        //setup the map
        mapView.removeAnnotations(mapView.annotations)
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        
        mapView.setRegion(region, animated: true)
        
        //set up map annotations
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your Location"
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Your Driver"
        
        mapView.addAnnotation(riderAnno)
        mapView.addAnnotation(driverAnno)
    }
    
    //MARK:- DriverViewController protocol method
    func distanceBetweenDriverAndRider(driver: CLLocation, rider: CLLocation) -> Double {
        
        let distanceInKM = driver.distance(from: rider) / 1000
        let roundedDistance = round(distanceInKM * 100) / 100
        
        callCabbieButton.setTitle("Your driver is \(roundedDistance)km away!", for: .normal)
        
        return roundedDistance
    }
    
    
    //MARK:- Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinates = manager.location?.coordinate {
            
            //find the center of where the user is located and update the map accordingly
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            //set the user location
            userLocation = center
            
            //check whether or not cabbie is on the way
            if cabHasBeenCalled {
                displayDriverAndRiderOnMap()
                //if driver location changes, update distance values on map accordingly
            } else {
                //display only the rider
                let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                let region = MKCoordinateRegion(center: center, span: span)
                mapView.setRegion(region, animated: true)
                
                //create a mapAnnotation
                mapView.removeAnnotations(mapView.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Current Location"
                mapView.addAnnotation(annotation)
            }
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
        if !driverIsOnTheWay {
            if let email = Auth.auth().currentUser?.email {
                let rideRequestDictionary: [String : Any] = [
                    "email": email,
                    "lat": userLocation.latitude,
                    "long": userLocation.longitude]
                
                
                
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
        } //on the way
        
    }
    
}
