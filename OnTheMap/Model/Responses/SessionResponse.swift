//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-02.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct SessionResponse: Codable {
    let account: Account
    let session: Session
    
    enum CodingKeys: String , CodingKey {
        case account
        case session
    }
}
