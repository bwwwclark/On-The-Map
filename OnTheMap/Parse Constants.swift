//
//  Parse Constants.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation


class ParseConstants : AnyObject{
    
    struct Constants {
    //  Parse API Key
    static let ParseApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    // Parse Application ID
    static let ParseApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    // Parse URL
    static let ParseBaseURLSecure :  String = "https://api.parse.com/1/classes/"
    
         }
    
    

struct JSONBodyKeys {

static let LastName = "lastName"
static let MapString = "mapString"
static let MediaURL = "mediaURL"
static let Latitude = "latitude"
static let Longitude = "longitude"
static let CreatedAt = "createdAt"
static let UpdatedAt = "updatedAt"
static let ACL = "ACL"
static let firstName = "firstName"
    
}


struct ParameterKeys {
    
    static let ApiKey = "X-Parse-REST-API-Key"
    static let ApplicationID = "X-Parse-Application-Id"
    static let limit = "limit"
    static let skip = "skip"
    static let order = "order"
    
}

  struct JSONResponseKeys {

// Parse Student Locations
static let LocationResults = "results"
static let CreatedAt = "createdAt"
static let FirstName = "firstName"
static let LastName = "lastName"
static let latitude = "latitude"
static let longitude = "longitude"
static let mapString = "mapString"
static let mediaURL = "mediaURL"
static let objectID = "objectId"
static let uniqueKey = "uniqueKey"
static let updatedAt = "updatedAt"


}
    
    struct Methods {
    // General
    static let StatusMessage = "status_message"
    static let StatusCode = "status_code"
    static let Location = "StudentLocation"     //Used for Getting or Posting a location

    }


}
