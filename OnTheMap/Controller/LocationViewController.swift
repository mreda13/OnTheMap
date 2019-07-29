//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-04.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, MKMapViewDelegate {

    var latitude:CLLocationDegrees!
    var longitude:CLLocationDegrees!
    var city:String = ""
    var state:String = ""
    var country:String = ""
    var link:String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(city), \(state), \(country)"
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(coordinate, animated: true)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000);
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
    
    @IBAction func submitLocation(_ sender: Any) {
                
        let body = StudentInformationRequest(uniqueKey: APIHelper.Auth.accountKey, firstName: "Mido", lastName: "Mando", mapString: "\(city), \(state)", mediaURL: link , latitude: latitude as Double, longitude: longitude as Double)
        
        APIHelper.postLocationRequest(body: body) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: "Posting location failed. Please try again.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
