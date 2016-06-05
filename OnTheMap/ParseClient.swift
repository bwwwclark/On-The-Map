//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import UIKit
import Foundation
import MapKit

class ParseClient: AnyObject {
    
    var session: NSURLSession
    var sessionID : String? = nil
    var userID : Int? = nil
    
    init() {
        session = NSURLSession.sharedSession()
    }

    
    func taskForParseGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set the parameters
        
        var mutableParameters = parameters
        
        
        // Build the URL and configure the request
        let urlString = ParseConstants.Constants.ParseBaseURLSecure + method + escapedParameters(mutableParameters)
        
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    print(urlString)
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            //Parse the data and use the data
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        // Start the request
        task.resume()
        return task
    }
    
    func getStudentLocations(Limit: String, completionHandler: (error: NSError?) -> Void) ->NSURLSessionDataTask? {
        
        //Specify parameters
        
        
        let parameters = [ParseConstants.ParameterKeys.limit: Limit, ParseConstants.ParameterKeys.order: "-updatedAt"]
        
        let method : String = ParseConstants.Methods.Location
        
        // Make the request
        let task = taskForParseGETMethod(method, parameters: parameters) { JSONResult, error in
            
            //Send the desired value(s) to completion handler
            
            if let error = error {
                completionHandler(error: error)
            } else {
                
                if let results = JSONResult[ParseConstants.JSONResponseKeys.LocationResults] as? [[String : AnyObject]] {
                    
                    StudentInformationClient.sharedInstance().studentInformationArray.removeAll()
                    
                    // Assign the needed parameters to the StudentInformation objects
                    var locations = [StudentInformation]()
                    
                    for location in results {
                        
                        // Create the StudentInformation object from the values retrieved from the JSON
                        let location = StudentInformation.init(dictionary: location)
                        
                        //Add the  location to the array of locations
                        locations.append(location)
                        StudentInformationClient.sharedInstance().studentInformationArray.append(location)
                    }
                    
                    completionHandler(error: nil)
                } else {
                    completionHandler(error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
            
        }
        return task
    }

    func createAnnotationFromStudentInformation(location: StudentInformation) ->MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        
        let lat = CLLocationDegrees(location.latitude!)
        let long = CLLocationDegrees(location.longitude!)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let first = location.firstName!
        let last = location.lastName!
        let mediaURL = location.mediaURL!
        
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        return annotation
    }
   
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }

    // Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            //Make it a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it to the URL
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    func queryForStudentLocation (completionHandler: ((success: Bool, message: String) -> Void))  {
        let methodParameters = [
           "where":"{\"\(ParseConstants.JSONResponseKeys.uniqueKey)\": \"\(UdacityConstants.User.uniqueKey!)\"}"
        ]
        let urlString = ParseConstants.Constants.ParseBaseURLSecure + ParseClient.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(ParseConstants.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                /* Handle error */
                print("An error occured while querying for Student Data")
                completionHandler(success: false, message: "An error occured while querying for Student Data")
                return
            }
            let parsedResponse = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            
            guard let results = parsedResponse["results"] as? [[String:AnyObject]] else {
                print("Cannot find key 'results' in \(parsedResponse)")
                return
            }
            
            for (_, value) in results.enumerate() {
                guard let objectId = value["objectId"] as? String else {
                    print("Cannot find key 'objectId' in \(value)")
                    return
                }
                if objectId != "" {
                    completionHandler(success: true, message: "")
                    UdacityConstants.User.objectId = objectId
                }
            }
            completionHandler(success: false, message: "")
        }
        task.resume()
    }
    
    func postStudentLocation(mapString: String, mediaURL: String, completionHandler: (success: Bool) -> Void) {

        
        let method : String = ParseConstants.Methods.Location
        // Build the URL and configure the request
        let urlString = ParseConstants.Constants.ParseBaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
              request.HTTPMethod = "POST"
        request.addValue(ParseConstants.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityConstants.User.uniqueKey!)\", \"firstName\": \"\(UdacityConstants.User.firstName!)\", \"lastName\": \"\(UdacityConstants.User.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(UdacityConstants.User.latitude!), \"longitude\": \(UdacityConstants.User.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false)
            } else {
                completionHandler(success: true)
                print("The following data has been sent to Parse:")
                print("First name: \(UdacityConstants.User.firstName!)")
                print("Last name: \(UdacityConstants.User.lastName!)")
                print("Location name: \(mapString)")
                print("Geocoded location: \(UdacityConstants.User.latitude!) \(UdacityConstants.User.longitude!)")
                print("Link: \(mediaURL)")
            }
        }
        task.resume()
    }

    
    
    func updateStudentLocation(objectId: String, mapString: String, mediaURL: String, completionHandler: (success: Bool) -> Void) {
        print("Updating Student Location...")
        let urlString = "\(ParseConstants.Constants.ParseBaseURLSecure)/\(objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(ParseConstants.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityConstants.User.uniqueKey!)\", \"firstName\": \"\(UdacityConstants.User.firstName!)\", \"lastName\": \"\(UdacityConstants.User.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(UdacityConstants.User.latitude!), \"longitude\": \(UdacityConstants.User.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false)
            } else {
                completionHandler(success: true)
            }
        }
        task.resume()
    }
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}