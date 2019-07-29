//
//  MapViewViewController.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-02.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit


class MapViewViewController: UIViewController, MKMapViewDelegate {

    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateMapWithStudentLocations()
        
    }
    
    //update UI accordingly
    func loadingLocations(_ isLoading: Bool){
        if isLoading {
            mapView.alpha = 0.25
            activityIndicator.startAnimating()
        }
        else{
            mapView.alpha = 1
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        logoutSessionRequest()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        updateMapWithStudentLocations()
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateMapWithStudentLocations() {
        loadingLocations(true)
        studentLocationsRequest { (studentLocations) in
            if let studentLocations = studentLocations {
                APIHelper.studentLocations = studentLocations
                self.annotations.removeAll()
                self.mapView.removeAnnotations(self.mapView.annotations)
                for location in studentLocations {
                    if let lat = location.latitude , let lon = location.longitude , let first = location.firstName, let last = location.lastName, let mediaURL = location.mediaURL {
                        let lat = CLLocationDegrees(lat)
                        let lon = CLLocationDegrees(lon)
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let first = first
                        let last = last
                        var URL = ""
                        if !mediaURL.isEmpty{
                            URL = mediaURL
                        }
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = URL
                        
                        self.annotations.append(annotation)
                    }
                }
                DispatchQueue.main.async {
                    self.loadingLocations(false)
                    self.mapView.addAnnotations(self.annotations)
                }
            }
        }
    }
    
    func logoutSessionRequest() {
        APIHelper.logoutRequest { (isSuccessful) in
            if !isSuccessful {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: "Logout failed. Please try again.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            DispatchQueue.main.async {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func studentLocationsRequest(completion: @escaping ([StudentInformation]?) -> Void) {
        
        APIHelper.getStudentLocations(){ (studentLocations, response, error,isNetworkError) in
            if error != nil {
                if isNetworkError {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Network Error. Please try again.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    completion(nil)
                }
                else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Failed to get student locations. Please try again", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    completion(nil)
                }
            }
            completion(studentLocations)
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
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
