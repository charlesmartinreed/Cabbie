//
//  AcceptRequestViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/26/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import MapKit

class AcceptRequestViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- Properties, passed from the segue
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
        
    }
}
