//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-04.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class TableTabViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        logoutSessionRequest()
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        studentLocationsRequest { (studentLocations) in
            if let studentLocations = studentLocations {
                APIHelper.studentLocations = studentLocations
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return APIHelper.studentLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location Cell", for: indexPath)

        let location = APIHelper.studentLocations[indexPath.row]
        
        if let firstName = location.firstName, let lastName = location.lastName {
            if firstName != "" || lastName != "" {
                cell.textLabel?.text = "\(firstName) \(lastName)"
            }
            else {
                cell.textLabel?.text = "<No name provided>"
            }
        }
        else {
            cell.textLabel?.text = "<No name provided>"
        }
        
        cell.detailTextLabel?.text = location.mediaURL
        
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = APIHelper.studentLocations[indexPath.row].mediaURL {
            if let url = URL(string:toOpen){
                app.open(url, options: [:]) { (validURL) in
                    if !validURL {
                        let alertController = UIAlertController(title: "Error", message: "Invalid URL!", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "No link is provided.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Dismiss", style: .default)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
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
}
