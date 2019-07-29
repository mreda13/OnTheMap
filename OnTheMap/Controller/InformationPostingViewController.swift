//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-04.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {

    let navigationBar = UINavigationBar()

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
        
    @IBAction func findLocation(_ sender: Any) {
        
        if linkTextField.text == "" || locationTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Location and link fields are both required.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Dismiss", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            guard let linkText = linkTextField.text, let locationText = locationTextField.text else {return}
            
            if UIApplication.shared.canOpenURL(URL(string: linkText)!) {
                let geocode = CLGeocoder()
                activityIndicator.startAnimating()
                geocode.geocodeAddressString(locationText) { (placemark, error) in
                    self.activityIndicator.stopAnimating()
                    if error != nil {
                        let alertController = UIAlertController(title: "Error", message: "Geocoding location failed. Please try again.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    guard let placemark = placemark else {return}
                    let first = placemark[0]
                    let location = first.location
                    let lat = location?.coordinate.latitude
                    let lon = location?.coordinate.longitude
                    let city = first.locality
                    let state = first.administrativeArea
                    let country = first.country
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
                    vc.latitude = lat
                    vc.city = city ?? ""
                    vc.country = country ?? ""
                    vc.state = state ?? ""
                    vc.longitude = lon
                    vc.link = self.linkTextField.text ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "Link provided is an invalid URL!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
