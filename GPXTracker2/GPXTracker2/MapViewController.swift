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
    navigationItem.setRightBarButton(currentLocationItem, animated: true)
    currentLocationItem.perform(currentLocationItem.action)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(MapViewController.didSelectFile(_:)),
      name: NSNotification.Name(rawValue: SelectFile),
      object: nil)
    
    if let mapType = MKMapType(rawValue: UInt(UserDefaults.standard.integer(forKey: MAP_TYPE))) {
      mapView.mapType = mapType
      updateMapTypeButtonImage()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func didSelectFile(_ notification: Notification)
  {
    PKHUD.sharedHUD.contentView = PKHUDProgressView()
    PKHUD.sharedHUD.show()
    
    let userInfo: Dictionary<String, URL> = (notification as NSNotification).userInfo as! Dictionary<String, URL>
    let file: URL = userInfo[SelectedFilePath]!
    selectedFilePath = file.path
    
    startPinButton.isHidden = false
    endPinButton.isHidden = false
    zoomToFitButton.isHidden = false
    shareButton.isEnabled = true
    
    allPoints.removeAll()
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
    startPins.removeAll()
    endPins.removeAll()
    startPinIndex = 0
    endPinIndex = 0
    
    let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      self.drawWithDelay(file)
    }
  }
  
  func drawWithDelay(_ url: URL) {
    let parser: Parser = Parser(path: url)
    title = parser.title()

    for place in parser.places()! {
      mapView.addAnnotation(place)
      allPoints.append(place.coordinate)
    }
    
    for line in parser.lines()! {
      mapView.add(line.polyLine)
      mapView.addAnnotation(line.startPin)
      mapView.addAnnotation(line.endPin)
      allPoints.append(contentsOf: line.coordinates)
      
      startPins.append(line.startPin)
      endPins.append(line.endPin)
    }
    
    zoomToFit()
    
    PKHUD.sharedHUD.hide()
  }
  
  func zoomToFit() {
    let allLine = MKPolyline(coordinates: &allPoints, count: allPoints.count)
    mapView.setVisibleMapRect(allLine.boundingMapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
  }
  
  // MARK: - User Action
  @IBAction func zoomToFitButtonClicked(_ sender: AnyObject) {
    zoomToFit()
  }
  
  @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
    let url: URL = URL(fileURLWithPath: selectedFilePath)
    let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    present(activityVC, animated: true, completion: nil)
    let presentationController = activityVC.popoverPresentationController
    presentationController?.sourceView = view
  }
  
  @IBAction func showStartPins(_ sender: UIButton) {
    moveTo(startPins[startPinIndex].coordinate)
    
    startPinIndex += 1
    if startPinIndex >= startPins.count  {
      startPinIndex = 0
    }
  }
  
  @IBAction func showEndPins(_ sender: UIButton) {
    moveTo(endPins[endPinIndex].coordinate)
    
    endPinIndex += 1
    if endPinIndex >= endPins.count {
      endPinIndex = 0
    }
  }
  
  @IBAction func toggleMapType(_ sender: UIButton) {
    let mapType = mapView.mapType == MKMapType.hybrid ? MKMapType.standard : MKMapType.hybrid
    mapView.mapType = mapType
    UserDefaults.standard.set(Int(mapType.rawValue), forKey: MAP_TYPE)
    updateMapTypeButtonImage()
  }
  
  func updateMapTypeButtonImage(){
    toggleMapTypeButton.isSelected = mapView.mapType == MKMapType.hybrid
  }

  func moveTo(_ location: CLLocationCoordinate2D) {
    if !CLLocationCoordinate2DIsValid(location) {
      return;
    }
    
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegion(center: location, span: span)
    mapView.setRegion(region, animated: true)
  }
  
  // MARK: - MKMapView
  func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  func mapView(_ mapView: MKMapView!, rendererForOverlay overlay: GTPolyLine!) -> MKOverlayRenderer! {
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    polylineRenderer.strokeColor = overlay.strokeColor
    polylineRenderer.lineWidth = CGFloat(overlay.lineWidth)
    return polylineRenderer
  }
  
  func mapView(_ mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
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
    
    let navigationButton = UIButton(type: .custom)
    navigationButton.setImage(UIImage(named: "car"), for: UIControlState())
    navigationButton.imageEdgeInsets = UIEdgeInsetsMake(16, 12, 29, 12)
    navigationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 64)
    navigationButton.backgroundColor = UIColor(red: 0, green: (122/255.0), blue: (255/255.0), alpha: 1.0)
    pinView.leftCalloutAccessoryView = navigationButton
    
    if !(pin!.iconUrl ?? "").isEmpty
    {
      let imagePinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      imagePinView.canShowCallout = true
      imagePinView.leftCalloutAccessoryView = pinView.leftCalloutAccessoryView
      
      let imgURL: URL = URL(string: pin!.iconUrl!)!
      let request: URLRequest = URLRequest(url: imgURL)
      
      let session = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        if error == nil {
          DispatchQueue.main.async {
            let image = UIImage(data: data!)
            imagePinView.image = image
          }
        }
      }) 
      session.resume()
      
      return imagePinView;
    }
    
    return pinView;
  }
  
  func mapView(_ mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    if control == view.leftCalloutAccessoryView {
      let annotation = view.annotation
      let placeMark = MKPlacemark(coordinate: annotation!.coordinate, addressDictionary: nil)
      let mapItem = MKMapItem(placemark: placeMark)
      mapItem.name = annotation!.title!
      
      let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
  }
  
  func mapView(_ mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
    UIApplication.shared.isIdleTimerDisabled = mode == MKUserTrackingMode.follow || mode == MKUserTrackingMode.followWithHeading
  }
}

