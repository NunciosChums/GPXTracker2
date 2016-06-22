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
import PKHUD

class MapViewController: UIViewController, CLLocationManagerDelegate {
  let locationManager = CLLocationManager()
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var startPinButton: UIButton!
  @IBOutlet var endPinButton: UIButton!
  @IBOutlet var zoomToFitButton: UIButton!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var toggleMapTypeButton: UIButton!
  var allPoints: [CLLocationCoordinate2D] = []
  var startPinIndex = 0
  var endPinIndex = 0
  var startPins: [GTPin] = []
  var endPins: [GTPin] = []
  var selectedFilePath: String = ""
  
  
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
      selector: #selector(MapViewController.didSelectFile(_:)),
      name: SelectFile,
      object: nil)
    
    if let mapType = MKMapType(rawValue: UInt(NSUserDefaults.standardUserDefaults().integerForKey(MAP_TYPE))) {
      mapView.mapType = mapType
      updateMapTypeButtonImage()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func didSelectFile(notification: NSNotification)
  {
    PKHUD.sharedHUD.contentView = PKHUDProgressView()
    PKHUD.sharedHUD.show()
    
    let userInfo: Dictionary<String, NSURL> = notification.userInfo as! Dictionary<String, NSURL>
    let file: NSURL = userInfo[SelectedFilePath]!
    selectedFilePath = file.path!
    
    startPinButton.hidden = false
    endPinButton.hidden = false
    zoomToFitButton.hidden = false
    shareButton.enabled = true
    
    allPoints.removeAll()
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
    startPins.removeAll()
    endPins.removeAll()
    startPinIndex = 0
    endPinIndex = 0
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.drawWithDelay(file)
    }
  }
  
  func drawWithDelay(url: NSURL) {
    let parser: Parser = Parser(path: url)
    title = parser.title()

    for place in parser.places()! {
      mapView.addAnnotation(place)
      allPoints.append(place.coordinate)
    }
    
    for line in parser.lines()! {
      mapView.addOverlay(line.polyLine)
      mapView.addAnnotation(line.startPin)
      mapView.addAnnotation(line.endPin)
      allPoints.appendContentsOf(line.coordinates)
      
      startPins.append(line.startPin)
      endPins.append(line.endPin)
    }
    
    zoomToFit()
    
    PKHUD.sharedHUD.hide(afterDelay: 0.5)
  }
  
  func zoomToFit() {
    let allLine = MKPolyline(coordinates: &allPoints, count: allPoints.count)
    mapView.setVisibleMapRect(allLine.boundingMapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
  }
  
  // MARK: - User Action
  @IBAction func zoomToFitButtonClicked(sender: AnyObject) {
    zoomToFit()
  }
  
  @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
    let url: NSURL = NSURL(fileURLWithPath: selectedFilePath)
    let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    presentViewController(activityVC, animated: true, completion: nil)
    let presentationController = activityVC.popoverPresentationController
    presentationController?.sourceView = view
  }
  
  @IBAction func showStartPins(sender: UIButton) {
    moveTo(startPins[startPinIndex].coordinate)
    
    startPinIndex += 1
    if startPinIndex >= startPins.count  {
      startPinIndex = 0
    }
  }
  
  @IBAction func showEndPins(sender: UIButton) {
    moveTo(endPins[endPinIndex].coordinate)
    
    endPinIndex += 1
    if endPinIndex >= endPins.count {
      endPinIndex = 0
    }
  }
  
  @IBAction func toggleMapType(sender: UIButton) {
    let mapType = mapView.mapType == MKMapType.Hybrid ? MKMapType.Standard : MKMapType.Hybrid
    mapView.mapType = mapType
    NSUserDefaults.standardUserDefaults().setInteger(Int(mapType.rawValue), forKey: MAP_TYPE)
    updateMapTypeButtonImage()
  }
  
  func updateMapTypeButtonImage(){
    toggleMapTypeButton.selected = mapView.mapType == MKMapType.Hybrid
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
  func mapViewWillStartLoadingMap(mapView: MKMapView) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
  }
  
  func mapViewDidFinishLoadingMap(mapView: MKMapView) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  
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
    
    let navigationButton = UIButton(type: .Custom)
    navigationButton.setImage(UIImage(named: "car"), forState: UIControlState.Normal)
    navigationButton.imageEdgeInsets = UIEdgeInsetsMake(16, 12, 29, 12)
    navigationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 64)
    navigationButton.backgroundColor = UIColor(red: 0, green: (122/255.0), blue: (255/255.0), alpha: 1.0)
    pinView.leftCalloutAccessoryView = navigationButton
    
    if !(pin!.iconUrl ?? "").isEmpty
    {
      let imagePinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      imagePinView.canShowCallout = true
      imagePinView.leftCalloutAccessoryView = pinView.leftCalloutAccessoryView
      
      let imgURL: NSURL = NSURL(string: pin!.iconUrl!)!
      let request: NSURLRequest = NSURLRequest(URL: imgURL)
      
      let session = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
        if error == nil {
          dispatch_async(dispatch_get_main_queue()) {
            let image = UIImage(data: data!)
            imagePinView.image = image
          }
        }
      }
      session.resume()
      
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

