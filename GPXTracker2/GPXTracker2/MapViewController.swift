//
//  ViewController.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 9. 12..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
  let locationManager = CLLocationManager()
  @IBOutlet var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    let currentLocationItem = MKUserTrackingBarButtonItem.init(mapView: mapView)
    navigationItem.setRightBarButtonItem(currentLocationItem, animated: true)
    currentLocationItem.performSelector(currentLocationItem.action)
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "didSelectFile:",
      name: SelectFile,
      object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func didSelectFile(notification: NSNotification)
  {
    let userInfo: Dictionary<String, String> = notification.userInfo as! Dictionary<String, String>
    let file: String = userInfo[SelectedFilePath]!
    print(file)
  }
}

