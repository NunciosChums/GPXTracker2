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
    
    mapView.removeOverlays(mapView.overlays)
    
    var points1: [CLLocationCoordinate2D] = [
      //      CLLocationCoordinate2DMake(37.4961927, 126.86879750000001),
      CLLocationCoordinate2DMake(37.4956309, 126.86897990000001),
      CLLocationCoordinate2DMake(37.4954266, 126.86845420000002),
      CLLocationCoordinate2DMake(37.4948477, 126.86879750000001),
      CLLocationCoordinate2DMake(37.4945668, 126.86763880000001),
      CLLocationCoordinate2DMake(37.4938944, 126.8677998),
      CLLocationCoordinate2DMake(37.4937241, 126.86705950000001),
      CLLocationCoordinate2DMake(37.4930346, 126.8664908),
      CLLocationCoordinate2DMake(37.4914087, 126.86464550000001),
      CLLocationCoordinate2DMake(37.49058720000001, 126.8618954),
      CLLocationCoordinate2DMake(37.485971, 126.8574627),
      CLLocationCoordinate2DMake(37.4856294, 126.85548249999998),
      CLLocationCoordinate2DMake(37.4850324, 126.8548327),
      CLLocationCoordinate2DMake(37.482656, 126.8534211),
      CLLocationCoordinate2DMake(37.4818169, 126.8522003),
      CLLocationCoordinate2DMake(37.4816418, 126.8505933),
      CLLocationCoordinate2DMake(37.4821431, 126.84823770000001),
      CLLocationCoordinate2DMake(37.481895, 126.8467833),
      CLLocationCoordinate2DMake(37.4805624, 126.8458152),
      CLLocationCoordinate2DMake(37.4734785, 126.84495210000001),
      CLLocationCoordinate2DMake(37.4734361, 126.8453979),
      CLLocationCoordinate2DMake(37.4696255, 126.8447004),
      CLLocationCoordinate2DMake(37.4668707, 126.8420719),
      CLLocationCoordinate2DMake(37.4630259, 126.8429088),
      CLLocationCoordinate2DMake(37.461012, 126.8426085),
      CLLocationCoordinate2DMake(37.4583719, 126.8413746),
      CLLocationCoordinate2DMake(37.4569241, 126.8396258),
      CLLocationCoordinate2DMake(37.454717, 126.83881210000001),
      CLLocationCoordinate2DMake(37.4525098, 126.8382558),
      CLLocationCoordinate2DMake(37.4474652, 126.83892430000002),
      CLLocationCoordinate2DMake(37.4437153, 126.83826240000002),
      CLLocationCoordinate2DMake(37.4380573, 126.83794380000002),
      CLLocationCoordinate2DMake(37.4374425, 126.83819380000001),
      CLLocationCoordinate2DMake(37.4357372, 126.84119019999999),
      CLLocationCoordinate2DMake(37.434961200000004, 126.8414868),
      CLLocationCoordinate2DMake(37.4316295, 126.84041000000002),
      CLLocationCoordinate2DMake(37.4299335, 126.84184380000002),
      CLLocationCoordinate2DMake(37.4271089, 126.84200269999998),
      CLLocationCoordinate2DMake(37.4261908, 126.8422967),
      CLLocationCoordinate2DMake(37.4247614, 126.84422150000002),
      CLLocationCoordinate2DMake(37.4232249, 126.84522090000002),
      CLLocationCoordinate2DMake(37.4206333, 126.8448623),
      CLLocationCoordinate2DMake(37.420394, 126.844168),
      CLLocationCoordinate2DMake(37.4145649, 126.84528690000002),
      CLLocationCoordinate2DMake(37.4147485, 126.8458739),
      CLLocationCoordinate2DMake(37.413469, 126.8468455),
      CLLocationCoordinate2DMake(37.4048522, 126.85300890000002),
      CLLocationCoordinate2DMake(37.4036647, 126.85030240000002),
      CLLocationCoordinate2DMake(37.4030822, 126.84773540000002),
      CLLocationCoordinate2DMake(37.4035162, 126.8467377),
      CLLocationCoordinate2DMake(37.4025568, 126.8460135),
      CLLocationCoordinate2DMake(37.4008084, 126.84628190000001),
      CLLocationCoordinate2DMake(37.3986069, 126.84458709999998),
      CLLocationCoordinate2DMake(37.3975518, 126.8440453),
      CLLocationCoordinate2DMake(37.3962581, 126.84427599999998),
      //      CLLocationCoordinate2DMake(37.3951707, 126.8437504),
      
    ]
    
    var points2: [CLLocationCoordinate2D] = [
      CLLocationCoordinate2DMake(37.3939166, 126.83926609999999),
      CLLocationCoordinate2DMake(37.3930107, 126.83939560000002),
      CLLocationCoordinate2DMake(37.39245600000001, 126.83926969999999),
      CLLocationCoordinate2DMake(37.3917821, 126.83944430000001),
      CLLocationCoordinate2DMake(37.3915172, 126.8400909),
      CLLocationCoordinate2DMake(37.3916275, 126.84086620000001),
      CLLocationCoordinate2DMake(37.3893578, 126.8406631),
      CLLocationCoordinate2DMake(37.386697000000005, 126.839478),
      CLLocationCoordinate2DMake(37.3866278, 126.8386791),
      CLLocationCoordinate2DMake(37.3851775, 126.83796609999999),
      CLLocationCoordinate2DMake(37.3841705, 126.83678099999999),
      CLLocationCoordinate2DMake(37.3853296, 126.8320899),
      CLLocationCoordinate2DMake(37.3848688, 126.8252959),
      CLLocationCoordinate2DMake(37.3861469, 126.8263982),
      CLLocationCoordinate2DMake(37.3886866, 126.8217498),
      CLLocationCoordinate2DMake(37.4025954, 126.81499860000001),
      CLLocationCoordinate2DMake(37.40473910000001, 126.79627260000001),
      CLLocationCoordinate2DMake(37.4034071, 126.7942814),
      CLLocationCoordinate2DMake(37.4024841, 126.7905308),
      CLLocationCoordinate2DMake(37.4025812, 126.7889089),
      CLLocationCoordinate2DMake(37.3994908, 126.78885360000001),
      CLLocationCoordinate2DMake(37.39854230000001, 126.79009200000002),
      CLLocationCoordinate2DMake(37.3971304, 126.7888873),
      CLLocationCoordinate2DMake(37.3961006, 126.7902161),
      CLLocationCoordinate2DMake(37.3956504, 126.7896137),
      CLLocationCoordinate2DMake(37.3916853, 126.78473990000002),
      CLLocationCoordinate2DMake(37.3920749, 126.7829207),
      CLLocationCoordinate2DMake(37.3934873, 126.78135890000001),
      CLLocationCoordinate2DMake(37.3931753, 126.7800379)
    ]
    
    
    let line1 = MKGeodesicPolyline(coordinates: &points1, count: points1.count)
    mapView.addOverlay(line1)
    
    let line2 = MKGeodesicPolyline(coordinates: &points2, count: points2.count)
    mapView.addOverlay(line2)
    
    var allPoints: [CLLocationCoordinate2D] = []
    allPoints.appendContentsOf(points1)
    allPoints.appendContentsOf(points2)
    let allLine = MKGeodesicPolyline(coordinates: &allPoints, count: allPoints.count)
    
    mapView.setVisibleMapRect(allLine.boundingMapRect, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10), animated: true)
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
    mapView.removeAnnotations(mapView.annotations)
    
    var pins: [MKAnnotation] = []
    
    let location1 = CLLocationCoordinate2DMake(40.730872, -74.003066)
    let pin1 = MKPointAnnotation()
    pin1.coordinate = location1
    pin1.title = "New York City"
    pin1.subtitle = "subtitle"
    pins.append(pin1)
    

    let location2 = CLLocationCoordinate2DMake(37.3939166, 126.83926609999999)
    let pin2 = MKPointAnnotation()
    pin2.coordinate = location2
    pin2.title = "test"
    pin2.subtitle = "subtitle2"
    pins.append(pin2)
    
    mapView.showAnnotations(pins, animated: true);
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

