//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Benjamin Clark  on 2/15/16.
//  Copyright © 2016 Benjamin Clark . All rights reserved.
//



import UIKit




class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var otmTableView: UITableView!
    
    var session: NSURLSession!
    var appDelegate: AppDelegate!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        otmTableView.delegate = self
        otmTableView.dataSource = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Load data
        getStudentsLocations()
        otmTableView.reloadData()
    }
    
    //Setup table with with rows for all student information
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = StudentInformationClient.sharedInstance().studentInformationArray.count
        return count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("otmTableViewCell", forIndexPath: indexPath) as UITableViewCell
        let student = StudentInformationClient.sharedInstance().studentInformationArray[indexPath.row]

        //set the cell properties
        cell.textLabel!.text = (student.firstName)! + " " + (student.lastName)!
        cell.detailTextLabel!.text = student.mediaURL!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        if let urlToOpen = tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text {
            let isValidURL = app.openURL(NSURL(string: urlToOpen)!)
            
            //Display an alertView if the URL can't be opened
            if !isValidURL {
                let alert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                dispatch_async(dispatch_get_main_queue(), {self.presentViewController(alert, animated: true, completion: nil)})
            }
        }
    }
    
    func getStudentsLocations() {
        
        ParseClient.sharedInstance().getStudentLocations("100", completionHandler: { error in
            if let error = error {
                print("Error retrieving annotations from Parse: \(error)")
                self.showAlert("Data failed to load")
            } else if !StudentInformationClient.sharedInstance().studentInformationArray.isEmpty {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.otmTableView.reloadData()
                })
            } else {
                print("Error- no student information downloaded")
                self.showAlert("Data failed to load")
            }
        })
    }
    
    func showAlert(error: String) {
        //Show an alert
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    
    @IBAction func logout(sender: AnyObject) {
            //Log out
        UdacityClient.sharedInstance().logoutWithUdacity(UdacityClient.sharedInstance().sessionID!) { success, error in
            
            if let error = error {
                print("Logout failed due to error: \(error)")
            } else {
                
                if success {
                    // Segue back to login screen
                    self.performSegueWithIdentifier("TableViewControllerLogout", sender: self)
                }
            }
        }
    }
}


