//
//  ApiHelper.swift
//  OnTheMap
//
//  Created by Mohamed Metwaly on 2019-05-02.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class APIHelper {
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
    }
    
    static var studentLocations:[StudentInformation] = []

    enum Endpoints {
        
        case postSession
        case studentLocations(limit:Int?,skip:Int?,order:String?)
        case studentLocation
        case signUp
        
        var stringValue:String {
            switch self {
            case .postSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .studentLocations(let limit,let skip,let order):
                var baseURL = "https://parse.udacity.com/parse/classes/StudentLocation?"
                if let limit = limit {
                    baseURL = baseURL + "limit=\(limit)&"
                }
                if let skip = skip {
                    baseURL = baseURL + "skip=\(skip)&"
                }
                if let order = order {
                    baseURL = baseURL + "order=\(order)"
                }
                return baseURL
            case .studentLocation:
                return "https://parse.udacity.com/parse/classes/StudentLocation"
            case .signUp:
                return "https://www.udacity.com/account/auth#!/signup"
            }
        }
        
        var url: URL {
            return URL(string:stringValue)!
        }
    }
    
    // MARK: Requests
     class func taskForGetRequest(request: URLRequest, completion: @escaping (Data?,URLResponse?,Error?)-> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil,response,error)
                return
            }
            completion(data,response,nil)
        }
        task.resume()
    }
    
    class func taskForPostRequest(request:URLRequest,completion: @escaping (Data?,Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            guard let data = data else {return}
            DispatchQueue.main.async {
                completion(data,nil)
            }
        }
        task.resume()
    }
    
    class func taskForDeleteRequest(request: URLRequest, completion: @escaping (Bool,Error?)->Void){
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true,nil)
            }
        }
        task.resume()
    }
    
    //MARK: ViewController Helper Methods
    class func getStudentLocations(completion: @escaping ([StudentInformation]?,URLResponse?,Error?, Bool) -> Void) {
        
        var request = URLRequest(url: Endpoints.studentLocations(limit: 100, skip: nil, order: "-updatedAt").url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        taskForGetRequest(request: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil,response,error,true)
                    return
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,response,nil,false)
                    return
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let JSONresponse = try decoder.decode(StudentInformationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(JSONresponse.results,response,nil,false)

                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil,response,error,false)
                }
            }
        }
    }
    
    //MARK: Session helper methods
    class func loginRequest(httpBody: Data?, completion: @escaping (Bool,Bool,Error?)-> Void){
        var request = URLRequest(url: Endpoints.postSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        taskForGetRequest(request: request) { (data, response, error) in
            if error != nil {
                completion(false,true,error)
                return
            }
            guard let data = data else {return}
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            let decoder = JSONDecoder()
            do {
                let httpResponse = response as! HTTPURLResponse
                //403 means invalid credentials.Treating all status codes other than 200 and 403 as network errors
                if httpResponse.statusCode == 403 {
                    completion(false,false,error)
                    return
                }
                else if httpResponse.statusCode != 200 {
                    completion(false,true,error)
                    return
                }
                //Successful response
                let responseData = try decoder.decode(SessionResponse.self, from: newData)
                APIHelper.Auth.accountKey = responseData.account.key
                APIHelper.Auth.sessionId = responseData.session.id
                completion(true,false,nil)
                return
            }
            catch{
                completion(true,false,error)
            }
        }
    }
    
    class func logoutRequest(completion: @escaping (Bool)->Void){
        var request = URLRequest(url: Endpoints.postSession.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskForDeleteRequest(request: request) { (isSuccessful, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    //MARK: LocationViewController helper methods
    class func postLocationRequest(body:StudentInformationRequest,completion: @escaping (Error?) -> Void) {
        
        var request = URLRequest(url: APIHelper.Endpoints.studentLocation.url)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = body
        let encoder = JSONEncoder()
        let json = try! encoder.encode(body)
        
        request.httpBody = json
        
        taskForPostRequest(request: request) { (data, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

