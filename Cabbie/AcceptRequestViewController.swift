//
//  AcceptRequestViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/26/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- Properties, passed from the segue
    var driverLocation = CLLocationCoordinate2D()
    var requestLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
        
    }
    
    private func initializeMap() {
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: requestLocation, span: span)
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        
        mapView.addAnnotation(annotation)
    }

    //MARK:- IBActions
    @IBAction func acceptRequestButtonTapped(_ sender: UIButton) {
        //1. update the ride Request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude, "driverLong": self.driverLocation.longitude])
            
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        //2. Give directions, using Apple Maps
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        //2a. Using a geocoder
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let err = error {
                print("Error:", err.localizedDescription)
                return
            }
            //placemark, then map item
            if let placemarks = placemarks {
                if !placemarks.isEmpty {
                    let placemark = MKPlacemark(placemark: placemarks.first!)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.requestEmail
                    
                    //launch options for Apple Maps
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
}
