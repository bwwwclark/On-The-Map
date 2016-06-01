///Users/bclark/Desktop/ projects/OnTheMap/StudentLocationsClient.swift
//  StudentLocationsClient.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/24/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation

class StudentInformationClient: NSObject {
    var studentInformationArray = [StudentInformation]()
    
    class func sharedInstance() -> StudentInformationClient {
        struct Singleton {
            static var sharedInstance = StudentInformationClient()
        }
        return Singleton.sharedInstance
    }
}