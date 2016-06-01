//
//  Udacity Client.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation

class UdacityClient: AnyObject {
    
    
    
    var session: NSURLSession
    
    // Authentication state
    var sessionID : String? = nil
    var userID : Int? = nil
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    func taskForUdacityGetMethod(method: String, completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Build GET request
        
        let urlString = UdacityConstants.Constants.UdacityBaseURLSecure + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        //make request
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            
            //GUARD was there an error?
            
            guard error == nil else {
                
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your Udacity request : \(error)"]
                completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            //GUARD was there a 2XX response?
                
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    if let response = response as? NSHTTPURLResponse {
                        let userInfo = [NSLocalizedDescriptionKey: "Invalid response. Status code: \(response.statusCode)!"]
                        completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                    } else if let response = response{
                        let userInfo = [NSLocalizedDescriptionKey: "Invalid response. Response: \(response)!"]
                        completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                        
                    }else {
                        let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                        completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                    }
                    return
                }
            
            //GUARD: Was there any data returned?
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            // Parse and use data
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        //start the request
        task.resume()
        return task
    }

    func taskForUdacityDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Build the URL and configure the request
        let urlString = UdacityConstants.Constants.UdacityBaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                print("There was an error with your Udacity DELETE request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your Udacity DELETE request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your Udacity DELETE request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your Udacity DELETE request returned an invalid response!")
                }
                
                completionHandler(result: response, error: error)
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            //First skip the first 5 characters of the response (Security characters used by Udacity)
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            
        }
        
        // Start the request
        task.resume()
        
        return task
    }
    
    func logoutWithUdacity(sessionID: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
    
            // Make the Udacity DELETE request
            taskForUdacityDELETEMethod(UdacityConstants.Methods.Session) {result, error in
    
                if let error = error {
                    completionHandler(success: false, error: error)
                } else {
                    if let session = result[UdacityConstants.JSONResponseKeys.Session]??[UdacityConstants.JSONResponseKeys.sessionID] as? String {
    
                        //DELETE method returned a session so set the shared instance sessionID back to nil
                        UdacityClient.sharedInstance().sessionID = nil
                        completionHandler(success: true, error: nil)
                        
                    } else {
                        completionHandler(success: false, error: nil)
                    }
                    
                }
            }
        }


    func taskForUdacityPOSTMethod (method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Build the request
        let urlString = UdacityConstants.Constants.UdacityBaseURLSecure + UdacityConstants.Methods.Session
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody =  try!NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            guard (error == nil) else {
                print("there was an error with your request:\(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request")
                return
            }
            
            
            //Parse data
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        task.resume()
        return task
        
    }
    
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    // MARK: Shared Instance
    
     class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    


    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    func postSession(username: String, password: String, completionHandler: (result: String?, error: NSError?) -> Void){
        let method = UdacityConstants.Methods.Session
        let jsonBody = [
                UdacityConstants.JSONBodyKeys.udacity : [
                UdacityConstants.JSONBodyKeys.username : username,
                UdacityConstants.JSONBodyKeys.password : password
            ],
        ]
        
        taskForUdacityPOSTMethod(method, jsonBody: jsonBody) { (JSONResult, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            if let dictionary = JSONResult! [UdacityConstants.JSONResponseKeys.account] as? [String : AnyObject] {
                if let result = dictionary[UdacityConstants.JSONResponseKeys.key] as? String {
                    completionHandler(result: result, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "postSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse session"]))
                }
            } else {
                completionHandler(result: nil, error: NSError(domain: "postSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse session"]))
                
            }
        }
    }
    func loginWithUdacity(email: String, password: String, completionHandler: ((success: Bool, message: String, error: NSError?) -> Void)) {
        let urlString = UdacityConstants.Constants.UdacityBaseURLSecure + UdacityConstants.Methods.Session
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else  {
                completionHandler(success: false, message: "Connection Error", error: error)
                print("error!")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completionHandler(success: false, message:"Incorrect Email or Password", error: error)
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            UdacityClient.sharedInstance().parseJSONDataForLogin(data, completionHandler: completionHandler)
        }
        task.resume()
    }
    func parseJSONDataForLogin(data: NSData, completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        var parsedResponse = try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
        
        guard let accountDictionary = parsedResponse["account"] as? NSDictionary else {
            print("Cannot find keys 'account' in \(parsedResponse)")
            return
        }
        
        let registered = accountDictionary ["registered"] as? Int
        let user = accountDictionary ["key"] as? String
        
        if registered != 1 {
            print("Account not registered")
        }
        if registered == 1 {
            completionHandler(success: true, message:"Successful login", error: nil)
            UdacityConstants.User.uniqueKey = user
            UdacityClient.sharedInstance().getUserData(user!)
        }
    }
    
    func getUserData(key: String) {
        
        let urlString = UdacityConstants.Constants.UdacityBaseURLSecure + UdacityConstants.Methods.UserData + key
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else {
                print("Connection Error")
                return
            }
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            var parsedResponse = try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
            
            guard let accountDictionary = parsedResponse["user"] as? NSDictionary else {
                print("Cannot find keys 'account' in \(parsedResponse)")
                return
            }
            let firstName = accountDictionary ["first_name"] as? String
            UdacityConstants.User.firstName = firstName
            let lastName = accountDictionary ["last_name"] as? String
            UdacityConstants.User.lastName = lastName
        }
        task.resume()
    }



}

