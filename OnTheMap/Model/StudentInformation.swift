//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-03.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct StudentInformation: Codable {
    
    let objectId: String
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String = ""
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let updatedAt: String
}
