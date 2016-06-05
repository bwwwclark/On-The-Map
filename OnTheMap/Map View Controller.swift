//
//  Map View Controller.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/14/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation
import UIKit
import MapKit

//ADD The app displays an alert if the download fails. I think this is done//


class MapViewController: UIViewController, MKMapViewDelegate{
    

    @IBOutlet weak var MapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Load the data
        loadData()
    }
    
    
    //delegate method to create pins and add annotations
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: self.annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            //THIS IS THROWING NILLLL FIXXX ITTTTT
            
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // delegate method to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    func loadData(){
        ParseClient.sharedInstance().getStudentLocations("100", completionHandler: { error in
            if let error = error {
                print("Error retrieving annotations from Parse: \(error)")
                self.showAlert("Data failed to load")
            } else if !StudentInformationClient.sharedInstance().studentInformationArray.isEmpty {
                
                var annotations = [MKPointAnnotation]()
                
                // First remove all of the pre-existing annotations so they don't continually stack on top of one another
                dispatch_async(dispatch_get_main_queue(), {self.MapView.removeAnnotations(self.MapView.annotations)})
                
                for location in StudentInformationClient.sharedInstance().studentInformationArray {
                    let annotation = ParseClient.sharedInstance().createAnnotationFromStudentInformation(location)
                    annotations.append(annotation)
                }
                
                dispatch_async(dispatch_get_main_queue(), {self.MapView.addAnnotations(annotations)})
                
            } else {
                print("Error - no annotations downloaded from Parse")
                self.showAlert("Data failed to load")
            }
        })
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        //Logout
        UdacityClient.sharedInstance().logoutWithUdacity(UdacityClient.sharedInstance().sessionID!) { success, error in
            if let error = error {
                print("Logout failed due to error: \(error)")
            } else {
                if success {
                    // Segue back to login screen
                    self.performSegueWithIdentifier("MapViewControllerLogout", sender: self)
                }
            }
        }
    }
    
    func showAlert(error: String) {
        //Show an alert
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func addLocationButton(sender: AnyObject) {
        self.performSegueWithIdentifier("mapPostLocationSegue", sender: self)
        
    }
    
}