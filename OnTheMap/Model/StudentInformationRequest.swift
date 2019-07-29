//
//  StudentLocationRequest.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-04.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct StudentInformationRequest : Codable {
    
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double

}
