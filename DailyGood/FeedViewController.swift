//
//  FeedViewController.swift
//  DailyGood
//
//  Created by Kelly Xu on 2/15/15.
//  Copyright (c) 2015 kelly. All rights reserved.
//

import UIKit
import CoreLocation

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationManager = CLLocationManager()
    var myLocation: String! = ""
    var didFindLoc: Bool = false
    var opportunities: [NSDictionary]! = []
    var isNearby: Bool = true
    var refreshControl: UIRefreshControl!
    var categoryTag: String! = "Environment"
    
    @IBOutlet weak var btn_nearby: UIButton!
    @IBOutlet weak var btn_recent: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // needed for table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 400
        
        // location stuff 
        // NB: the call to the API is made from setLocationInfo() when location is updated
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        triggerLocationServices()
        
        // NB: should make sure data is loaded from API again when refreshing....
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            getVolOpps()
        }
    }
    
    // for location stuff -- we only need access to location when app is in use
    // note we also needed to add the NSLocationWhenInUseUsageDescription key-value in info.plist
    func triggerLocationServices() {
        didFindLoc = false
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.startUpdatingLocation()
            }
        } else {
            var alert = UIAlertView(title: "Location Error", message: "Location services desabled", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
       if status == .AuthorizedWhenInUse || status == .Authorized {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var alert = UIAlertView(title: "Location Error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                var alert = UIAlertView(title: "Location Error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                alert.show()
            } else if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.useLocationInfo(pm)
            } else {
                var alert = UIAlertView(title: "Location Error", message: "No data received from geocoder", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        })
    }
    func useLocationInfo(placemark: CLPlacemark!) {
        if didFindLoc {
            return
        }
        if placemark != nil && placemark.locality != nil {
            //stop updating location to save battery life
            didFindLoc = true
            locationManager.stopUpdatingLocation()
            myLocation = placemark.postalCode
            // get data from API
            getVolOpps()
        } else {
            var alert = UIAlertView(title: "Location Error", message: "Could not get your city", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    // for table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return opportunities.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("VolCell") as VolCell
        var thisOpp: NSMutableDictionary = opportunities[indexPath.row].mutableCopy() as NSMutableDictionary
        cell.volOppCharity.text = thisOpp["sponsoringOrganizationName"] as? String
        cell.volOppLocation.text = thisOpp["location_name"] as? String
        var tag: [String] = thisOpp["categoryTags"] as [String]!
        if tag.count > 0 {
            cell.volOppTag.text = tag[0] as String
        } else {
            //cell.volOppTag.hidden = true
            cell.volOppTag.text = "no tag"
        }
        cell.volOppTitle.text = thisOpp["title"] as? String
        cell.volOppDescription.text = thisOpp["description"] as? String
        let startDate = thisOpp["startDate"] as String
        let when = startDate.componentsSeparatedByString(" ")
        cell.volOppTime.text = when[0] + " at " + when[1]
        
        // for image we use flickr API...
        var query: String
        if let charity = cell.volOppCharity.text {
            let words = charity.componentsSeparatedByString(" ")
            query = "&text=" + "%20".join(words)
        } else if tag.count > 0 {
            let tags = tag[0].componentsSeparatedByString(" ")
            query = "&tags=" + "%2C".join(tags) + "&tag_mode=any"
        } else {
            return cell
        }
        var flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=fc0877fa484b0b38e2d299a5c491c764&safe_search=1&content_type=1&media=photos&format=json&nojsoncallback=1&sort=interestingness-desc&per_page=1"
        // flickrUrl += "&license=7" // SHOULD ONLY CONSIDER PUBLIC DOMAIN IMAGES!!! BUT NOT MANY RESULTS... DEAL W/THIS LATER...
        flickrUrl += query
        let request = NSURLRequest(URL: NSURL(string: flickrUrl)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error == nil && data != nil {
                var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                var results = dictionary["photos"] as NSDictionary
                var picList = results["photo"] as [NSDictionary]
                if picList.count > 0 {
                    var pic = picList[0] as NSDictionary
                    var picUrl: String = "https://farm" + toString(pic["farm"]!)
                    picUrl += ".staticflickr.com/" + toString(pic["server"]!)
                    picUrl += "/" + toString(pic["id"]!)
                    picUrl += "_" + toString(pic["secret"]!)
                    picUrl += "_n.jpg"
                    cell.volOppImage.setImageWithURL(NSURL(string: picUrl))
                    thisOpp["imageURL"] = picUrl
                }
            }
        }
        
        // would be nice to get/set these too...
        // cell.volOppSponsor = ..... FROM YAHOO?
        // cell.volOppWhoJoined = .....
        cell.volOpp = thisOpp as NSDictionary
        return cell
    }
    
    // for getting data from API
    func getVolOpps() {
        
        // figure out API URL for desired result sorting
        var  url = "http://api2.allforgood.org/api/volopps?key=YahooGood&output=json-hoc&merge=3"
        if isNearby {
            url += "&sort=geo_distance%20asc"
        } else {
            url += "&sort=eventrangestart%20asc"
        }
        
        // make sure we have location (ZIP code)
        if myLocation.isEmpty {
            let alert = UIAlertView(title: "Error", message: "Did not get location", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "Retry")
            alert.show()
            self.refreshControl.endRefreshing()
            return
        } else {
            // add location to query
            url += "&vol_loc=" + myLocation
        }
        
        // tag query with proper escaping
        if !categoryTag.isEmpty {
            url += "&q=categorytags:" + categoryTag.stringByAddingPercentEncodingForURLQueryValue()!
        }
        // println("url: \(url)")
        
        // call API
        let request = NSURLRequest(URL: NSURL(string: url)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error != nil || data == nil {
                var alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                alert.show()
            } else {
                var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                self.opportunities = dictionary["items"] as [NSDictionary]
            }
            
            // be sure to load the table
            if self.opportunities.count > 0 {
                self.tableView.reloadData()
            } else {
                var alert = UIAlertView(title: "Sorry", message: "No opportunities matching location and parameters", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func onProfile(sender: AnyObject) {
        performSegueWithIdentifier("ProfileSegue", sender: nil)
    }
    
    @IBAction func onTapNearbyBtn(sender: AnyObject) {
        isNearby = true
        btn_nearby.enabled = false
        btn_recent.enabled = true
        getVolOpps()
    }
    
    @IBAction func onTapRecentBtn(sender: AnyObject) {
        isNearby = false
        btn_nearby.enabled = true
        btn_recent.enabled = false
        getVolOpps()
    }
    
    func onRefresh() {
        getVolOpps()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let detailVC = segue.destinationViewController as FeedDetailViewController
            let cell = sender as VolCell
            detailVC.selection = cell.volOpp
        } else if segue.identifier == "ProfileSegue" {
            let profileVC = segue.destinationViewController as ProfileViewController
            profileVC.profileTag = categoryTag
        }
    }
    
    @IBAction func profileUnwind(segue: UIStoryboardSegue) {
            let profileVC = segue.sourceViewController as ProfileViewController
            categoryTag = profileVC.profileTag
            getVolOpps()
    }

}
