//
//  AddEntryViewController.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 3/2/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//

import Foundation
import UIKit
import MapKit

//The app displays an alert if the geocoding fails. I think it does this


class AddEntryViewController: UIViewController, MKMapViewDelegate,UITextFieldDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var enterLocationLabel: UILabel!
    @IBOutlet weak var enterURLlabel: UILabel!
    @IBOutlet weak var AddEntryButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var enterLocationTextField: UITextField!
    @IBOutlet weak var enterURLtextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstView()
        //  enterURLtextField.hidden = true
        spinner.hidesWhenStopped = true
    }
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        if enterLocationTextField.text == "" {
            showAlert("Please Enter Your Location")
        } else {
            geocode(closureForGeocoding)
        }
    }
    
    @IBAction func addEntryButton(sender: AnyObject) {
        let mapString = enterLocationTextField.text!
        let mediaURL = enterURLtextField.text!
        let objectId = UdacityConstants.User.objectId
        
        if enterURLtextField.text == "" {
            showAlert("Please Enter a Link to Share")
        } else {
            if objectId != nil {
                ParseClient.sharedInstance().updateStudentLocation(objectId!, mapString: mapString, mediaURL: mediaURL, completionHandler: closureForPost)
            } else {
                ParseClient.sharedInstance().postStudentLocation(mapString, mediaURL: mediaURL, completionHandler: closureForPost)
            }
        }
        
    }
    
    func geocode (completionHandler: ((success: Bool, message: String, error: NSError?) -> Void)) {
        
        spinner.startAnimating()
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = enterLocationTextField.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                completionHandler(success: false, message: "Geocoding Failed", error: nil)
                self.spinner.stopAnimating()
                return
            } else {
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.title = self.enterLocationTextField.text
                
                UdacityConstants.User.latitude = localSearchResponse!.boundingRegion.center.latitude
                UdacityConstants.User.longitude = localSearchResponse!.boundingRegion.center.longitude
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: UdacityConstants.User.latitude!, longitude: UdacityConstants.User.longitude!)
                
                let span = MKCoordinateSpanMake(1, 1)
                let region = MKCoordinateRegionMake(self.pointAnnotation.coordinate, span)
                self.spinner.stopAnimating()
                
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                completionHandler(success: true, message: "Successful Forward-Geocoding", error: nil)
            }
        }
    }
    
    func closureForGeocoding(success: Bool, message: String, error: NSError?) -> Void {
        if success {
            secondView()
            print(message)
        } else {
            spinner.stopAnimating()
            showAlert("Can't find your location")
        }
    }
    
    
    // MARK: Configure UI
    
    func firstView() {
        enterLocationTextField.delegate = self
        enterURLtextField.delegate = self
        AddEntryButton.hidden = true
        mapView.hidden = false
        enterURLlabel.hidden = true
        enterURLtextField.hidden = true
        enterLocationTextField.hidden = false
        
        
    }
    
    func secondView() {
        searchButton.hidden = true
        enterLocationLabel.hidden = true
        mapView.hidden = false
        enterLocationTextField.hidden = true
        enterURLlabel.hidden = false
        enterLocationLabel.hidden = true
        enterURLtextField.hidden = false
        AddEntryButton.hidden = false
        
        
    }
    func URLtextFieldShouldReturn(textField: UITextField) -> Bool {
        dismissAnyVisibleKeyboards()
        return true
    }
    
    func URLtextViewDidBeginEditing(textView: UITextField) {
        if enterURLtextField.text == "" {
            enterURLtextField.text = "http://"
        }
    }
    func URLtextViewDidEndEditing(textView: UITextField) {
        if enterURLtextField.text == "" {
            enterURLtextField.text = "Enter a Link to Share Here"
        }
    }
    func LocationTextField(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            enterLocationTextField.resignFirstResponder()
            return false
        }
        return true
    }
    func dismissAnyVisibleKeyboards() {
        if enterLocationTextField.isFirstResponder() || enterURLtextField.isFirstResponder() {
            view.endEditing(true)
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissAnyVisibleKeyboards()
    }
    func showAlert(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.spinner.stopAnimating()
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    func closureForPost(success: Bool)-> Void {
        if success {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            showAlert("Post failed")
        }
    }
    
}