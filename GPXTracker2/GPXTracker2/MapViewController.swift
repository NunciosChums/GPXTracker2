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
    if(file == "111"){
      createPolyline()
    }
    else{
      addPin()
    }
  }
  
  func createPolyline(){
    let point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
    let point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348);
    let point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267);
    let point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375);
    let point5 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
    
    var points: [CLLocationCoordinate2D]
    points = [point1, point2, point3, point4, point5]
    
    let geodesic = MKGeodesicPolyline(coordinates: &points, count: points.count)
    mapView.addOverlay(geodesic)
    
    UIView.animateWithDuration(1.5, animations: { () -> Void in
      let span = MKCoordinateSpanMake(0.01, 0.01)
      let region1 = MKCoordinateRegion(center: point1, span: span)
      self.mapView.setRegion(region1, animated: true)
    })
  }
  
  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blueColor()
      polylineRenderer.lineWidth = 3
      return polylineRenderer
    }
    return nil
  }
  
  func addPin(){
    let newYorkLocation = CLLocationCoordinate2DMake(40.730872, -74.003066)
    let dropPin = MKPointAnnotation()
    dropPin.coordinate = newYorkLocation
    dropPin.title = "New York City"
    dropPin.subtitle = "subtitle"
    mapView.addAnnotation(dropPin)
    let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
    let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(newYorkLocation, theSpan)
    mapView.setRegion(theRegion, animated: true)
  }
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    if (annotation is MKUserLocation) {
      return nil
    }
    
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.animatesDrop = true
      pinView!.pinTintColor = UIColor.greenColor()
    }
    else {
      pinView!.annotation = annotation
    }
    
    return pinView
  }
}

