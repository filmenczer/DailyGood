//
//  FeedDetailViewController.swift
//  DailyGood
//
//  Created by Kelly Xu on 2/15/15.
//  Copyright (c) 2015 kelly. All rights reserved.
//

import UIKit
import MapKit

class FeedDetailViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkBtn1: UIButton!
    @IBOutlet weak var charityImage: UIImageView!
    @IBOutlet weak var charityName: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var oppTitle: UILabel!
    @IBOutlet weak var oppDescription: UILabel!
    @IBOutlet weak var fromWhen: UILabel!
    @IBOutlet weak var untilWhen: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sponsorship: UILabel!
    @IBOutlet weak var timeView: UIView!

    var selection = NSDictionary() // all data from API here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FILL DATA
        charityImage.setImageWithURL(NSURL(string: selection["imageURL"] as String))
        charityName.text = selection["sponsoringOrganizationName"] as? String
        
        // resize title so that the text fits and position stuff below by its height
        oppTitle.text = selection["title"] as? String
        oppTitle.sizeToFit()
        var position = oppTitle.frame.maxY
        
        // add tags (TO-DO: make them prettier...)
        if let tags = selection["categoryTags"] as? [String] {
            var offset: CGFloat = 0
            for t in tags {
                let label: UILabel = UILabel(frame: CGRectMake(0, 0, 10, 10))
                label.font = UIFont(name: "Helvetica", size: 14.0)
                label.backgroundColor = UIColor(white: 0.2, alpha: 1)
                label.textColor = UIColor(white: 0.8, alpha: 1)
                label.text = t
                label.sizeToFit()
                if offset + label.frame.width < tagView.frame.width {
                    tagView.addSubview(label)
                    label.frame.origin.x = offset
                    label.center.y = tagView.frame.height/2
                    offset += label.frame.width + 10
                } else {
                    break
                }
            }
        }
        
        // resize description so that the text fits and position stuff below by its height
        oppDescription.text = selection["description"] as? String
        oppDescription.sizeToFit()
        oppDescription.frame.origin.y = position + 5
        position = oppDescription.frame.maxY
        
        // TO-DO: Should so something else with sponsorhip...
        sponsorship.frame.origin.y = position + 5
        position = sponsorship.frame.maxY
        
        // date and time, formatted
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = selection["startDate"] as? String
        let dateFrom = dateFormatter.dateFromString(dateString!)
        dateString = selection["endDate"] as? String
        let dateTo = dateFormatter.dateFromString(dateString!)
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        fromWhen.text = "From " + dateFormatter.stringFromDate(dateFrom!)
        untilWhen.text = "Until " + dateFormatter.stringFromDate(dateTo!)
        timeView.frame.origin.y = position + 5
        position = timeView.frame.maxY
        
        // address above map
        address.text = selection["location_name"] as? String
        address.frame.origin.y = position + 5
        position = address.frame.maxY
        
        // map (TO-DO: directions from current location?)
        mapView.frame.origin.y = position + 4
        position = mapView.frame.maxY
        mapView.showsUserLocation = true
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        var annotation = MKPointAnnotation()
        annotation.title = oppTitle.text
        annotation.subtitle = charityName.text
        let latlong = selection["latlong"] as? NSString
        if latlong!.length > 0  {
            // use lat,long
            let ll = latlong!.componentsSeparatedByString(",")
            let pos = (ll[0].doubleValue as CLLocationDegrees, ll[1].doubleValue as CLLocationDegrees)
            annotation.coordinate = CLLocationCoordinate2D(latitude: pos.0, longitude: pos.1)
            mapView.addAnnotation(annotation)
            mapOpp(mapView, dist: selection["Distance"], opp: annotation)
        } else {
            // use address
            let geocode = CLGeocoder()
            geocode.geocodeAddressString(address.text) {
                (placemarks, error) -> Void in
                if (error == nil && placemarks.count > 0) {
                    let pm = placemarks[0] as CLPlacemark
                    annotation.coordinate = pm.location.coordinate
                    self.mapView.addAnnotation(annotation)
                    self.mapOpp(self.mapView, dist: self.selection["Distance"], opp: annotation)
                }
            }
        }

        // finally we can size the scrollview
        scrollView.contentSize = CGSize(width: 320, height: position)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func mapOpp(mapView: MKMapView, dist: AnyObject?, opp: MKPointAnnotation) {
        if let miles = dist as? CLLocationDistance {
            let distance = miles * 1609 * 2.2 // meters
            let region = MKCoordinateRegionMakeWithDistance(opp.coordinate, distance, distance)
            mapView.setRegion(region, animated: false)
        } else {
            mapView.showAnnotations([opp], animated: false)
        }
    }
    
    @IBAction func onTapBackBtn(sender: AnyObject) {
        navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func onCheckBtn(sender: AnyObject) {
            checkBtn1.selected = true
            var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "CONFIRMED")
            actionSheet.showInView(view)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        if (buttonIndex == 0){
            checkBtn1.selected = true
        } else {
            checkBtn1.selected = false
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var webVC = segue.destinationViewController as WebViewController
        webVC.url = selection["detailUrl"] as String
    }
}