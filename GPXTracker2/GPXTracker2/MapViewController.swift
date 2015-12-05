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
import Alamofire

class MapViewController: UIViewController, CLLocationManagerDelegate {
  let locationManager = CLLocationManager()
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var startPinButton: UIButton!
  @IBOutlet var endPinButton: UIButton!
  @IBOutlet var zoomToFitButton: UIButton!
  var allPoints: [CLLocationCoordinate2D] = []
  var startPinIndex = 0
  var endPinIndex = 0
  var startPins: [GTPin] = []
  var endPins: [GTPin] = []
  
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
    let userInfo: Dictionary<String, NSURL> = notification.userInfo as! Dictionary<String, NSURL>
    let file: NSURL = userInfo[SelectedFilePath]!
    
    self.startPinButton.hidden = false
    self.endPinButton.hidden = false
    self.zoomToFitButton.hidden = false
    
    allPoints.removeAll()
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
    startPins.removeAll()
    endPins.removeAll()
    startPinIndex = 0
    endPinIndex = 0
    
    let parser: Parser = Parser(path: file)
    title = parser.title()
    
    mapView.showAnnotations(parser.places()!, animated: true)
    
    for line in parser.lines()!{
      mapView.addOverlay(line.polyLine)
      mapView.addAnnotation(line.startPin)
      mapView.addAnnotation(line.endPin)
      allPoints.appendContentsOf(line.coordinates)
      
      startPins.append(line.startPin)
      endPins.append(line.endPin)
    }
    
    for annotation in mapView.annotations{
      if annotation is MKUserLocation{
        continue
      }
      allPoints.append(annotation.coordinate)
    }
    
    zoomToFit()
  }
  
  func zoomToFit() {
    let allLine = MKPolyline(coordinates: &allPoints, count: allPoints.count)
    mapView.setVisibleMapRect(allLine.boundingMapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
  }
  
  // MARK: - User Action
  @IBAction func zoomToFitButtonClicked(sender: AnyObject) {
    zoomToFit()
  }
  
  @IBAction func showStartPins(sender: UIButton) {
    moveTo(startPins[startPinIndex].coordinate)
    
    startPinIndex++
    if startPinIndex >= startPins.count  {
      startPinIndex = 0
    }
  }
  
  @IBAction func showEndPins(sender: UIButton) {
    moveTo(endPins[endPinIndex].coordinate)
    
    endPinIndex++
    if endPinIndex >= endPins.count {
      endPinIndex = 0
    }
  }
  
  func moveTo(location: CLLocationCoordinate2D) {
    if !CLLocationCoordinate2DIsValid(location) {
      return;
    }
    
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegion(center: location, span: span)
    mapView.setRegion(region, animated: true)
  }
  
  // MARK: - MKMapView
  func mapView(mapView: MKMapView!, rendererForOverlay overlay: GTPolyLine!) -> MKOverlayRenderer! {
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    polylineRenderer.strokeColor = overlay.strokeColor
    polylineRenderer.lineWidth = CGFloat(overlay.lineWidth)
    return polylineRenderer
  }
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    if (annotation is MKUserLocation) {
      return nil
    }
    
    if !(annotation is GTPin) {
      return nil
    }
    
    let pin = annotation as? GTPin
    let reuseId = pin!.identifier
    
    let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView.canShowCallout = true
    pinView.animatesDrop = true
    pinView.pinTintColor = pin!.color
    
    let navigationButton = UIButton(type: .DetailDisclosure)
    navigationButton.setImage(UIImage(named: "car"), forState: UIControlState.Normal)
    pinView.leftCalloutAccessoryView = navigationButton
    
    if !(pin!.iconUrl ?? "").isEmpty
    {
      let imagePinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      imagePinView.canShowCallout = true
      imagePinView.leftCalloutAccessoryView = pinView.leftCalloutAccessoryView
      
      Alamofire.request(.GET, pin!.iconUrl!).response() {(_, _, data, _) in
        imagePinView.image = UIImage(data: data!) ?? pinView.image;
      }
      
      return imagePinView;
    }
    
    return pinView;
  }
  
  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    if control == view.leftCalloutAccessoryView {
      let annotation = view.annotation
      let placeMark = MKPlacemark(coordinate: annotation!.coordinate, addressDictionary: nil)
      let mapItem = MKMapItem(placemark: placeMark)
      mapItem.name = annotation!.title!
      
      let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
  }
  
  func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
    UIApplication.sharedApplication().idleTimerDisabled = mode == MKUserTrackingMode.Follow || mode == MKUserTrackingMode.FollowWithHeading
  }
}

