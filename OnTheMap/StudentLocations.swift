//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation

struct StudentInformation {
    
    //MARK: Properties
    
    var objectid: String? = nil
    //var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    
    //MARK: Initializer
    
    // Construct a StudentInformation object from a dictionary
    init(dictionary: [String: AnyObject]) {
        
        objectid = dictionary[ParseConstants.JSONResponseKeys.objectID] as? String!
        //uniqueKey = dictionary[OTMClient.JSONResponseKeys.uniqueKey] as? String  //Set this to my Udacity login
        firstName = dictionary[ParseConstants.JSONResponseKeys.FirstName] as? String!
        lastName = dictionary[ParseConstants.JSONResponseKeys.LastName] as? String!
        mapString = dictionary[ParseConstants.JSONResponseKeys.mapString] as? String!
        mediaURL = dictionary[ParseConstants.JSONResponseKeys.mediaURL] as? String!
        latitude = dictionary[ParseConstants.JSONResponseKeys.latitude] as? Double!
        longitude = dictionary[ParseConstants.JSONResponseKeys.longitude] as? Double!
        
    }
    
}


