//
//  Udacity Constants.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation

class UdacityConstants : AnyObject{
    
    struct Constants {
        //Udacity URL
        static let UdacityBaseURLSecure: String = "https://www.udacity.com/"
        

    }
    
      struct Methods {
    //Udacity Authentication
    static let Session = "api/session"
    
    //Public User Data
    static let AuthenticationTokenNew = "authentication/token/new"
    static let UserData = "api/users/"
    static let SignIn = "account/auth#!/signin"

    
    }
    
    struct JSONBodyKeys {
        
        //Udacity Keys
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let account = "account"
        
        
    }
    
    struct JSONResponseKeys {
        
        // General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // Udacity Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let sessionID = "id"
        static let account = "account"
        static let key = "key"
        
        // Udacity Account
        static let UserID = "id"
    }

    struct User {
        //ADDED this for geocoding call from add entry view controller
        static var email : String?
        static var password : String?
        static var uniqueKey : String?
        
        static var lastName : String?
        static var firstName : String?
        
        static var mediaURL : String?
        static var mapString : String?
        static var latitude : Double?
        static var longitude : Double?
        static var updatedAt : String?
        static var objectId : String?
        static var createdAt : String?
    }
    struct ParameterKeys {
        static let uniqueKey = "uniqueKey"
    }



}
