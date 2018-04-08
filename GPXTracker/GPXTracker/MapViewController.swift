import UIKit
import MapKit
import CoreLocation
import PKHUD

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var toggleMapTypeButton: UIButton!
  @IBOutlet weak var zoomToFitButton: UIButton!
  @IBOutlet weak var endPinButton: UIButton!
  @IBOutlet weak var startPinButton: UIButton!
  @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint!
  
  let locationManager = CLLocationManager()
  var allPoints: [CLLocationCoordinate2D] = []
  var startPinIndex = 0
  var endPinIndex = 0
  var startPins: [GTPin] = []
  var endPins: [GTPin] = []
  var filePathForShare: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    calcBottomMargin()
    registerObserver()
    addGoToCurrentLocationBarButtonItem()
    
    if let mapType = MKMapType(rawValue: UInt(UserDefaults.standard.integer(forKey: MAP_TYPE))) {
      mapView.mapType = mapType
      updateMapTypeButtonImage()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Initial
  func addGoToCurrentLocationBarButtonItem(){
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    let currentLocationItem = MKUserTrackingBarButtonItem.init(mapView: mapView)
    navigationItem.setRightBarButton(currentLocationItem, animated: true)
    currentLocationItem.perform(currentLocationItem.action)
  }
  
  func calcBottomMargin() {
    if #available(iOS 11.0, *) {
      let window = UIWindow(frame: UIScreen.main.bounds)
      let isiPhoneX = (window.safeAreaInsets.top) > CGFloat(0.0) || window.safeAreaInsets != .zero
      bottomMarginConstraint.constant = isiPhoneX ? -34 : 0
    }
  }
  
  func registerObserver() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fileSelected(notification:)),
                                           name: Notification.Name(rawValue: SELECTED_FILE),
                                           object: nil)
  }
  
  // MARK: - User Action
  @IBAction func toggleMapTypeButtonClicked(_ sender: Any) {
    let mapType = mapView.mapType == MKMapType.hybrid ? MKMapType.standard : MKMapType.hybrid
    mapView.mapType = mapType
    UserDefaults.standard.set(Int(mapType.rawValue), forKey: MAP_TYPE)
    updateMapTypeButtonImage()
  }
  
  @IBAction func zoomToFitButtonClicked(_ sender: Any) {
    zoomToFit()
  }
  
  func updateMapTypeButtonImage(){
    toggleMapTypeButton.isSelected = mapView.mapType == MKMapType.hybrid
  }
  
  func zoomToFit() {
    mapView.annotations.forEach { (annotation) in
      if annotation is GTPin {
        allPoints.append(annotation.coordinate)
      }
    }

    let all = MKPolyline(coordinates: &allPoints, count: allPoints.count)
    mapView.setVisibleMapRect(all.boundingMapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
  }
  
  @objc func fileSelected(notification: Notification) {
    HUD.show(.progress)
    
    let userInfo: Dictionary<String, GTFile> = (notification as NSNotification).userInfo as! Dictionary<String, GTFile>
    let file: GTFile = userInfo[SELECTED_FILE_PATH]!
    filePathForShare = file.path.path
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.draw(file: file)
    }
  }
  
  @IBAction func goToStartPin(_ sender: Any) {
    moveTo(location: startPins[startPinIndex].coordinate)
    
    startPinIndex += 1
    if startPinIndex >= startPins.count {
      startPinIndex = 0
    }
  }
  
  @IBAction func goToEndPin(_ sender: Any) {
    moveTo(location: endPins[endPinIndex].coordinate)
    
    endPinIndex += 1
    if endPinIndex >= endPins.count {
      endPinIndex = 0
    }
  }
  
  func moveTo(location: CLLocationCoordinate2D){
    if CLLocationCoordinate2DIsValid(location) {
      let span = MKCoordinateSpanMake(0.05, 0.05)
      let region = MKCoordinateRegionMake(location, span)
      mapView.setRegion(region, animated: true)
    }
  }
  
  @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
    let url = URL(fileURLWithPath: filePathForShare)
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    present(activityVC, animated: true, completion: nil)
    let presentationController = activityVC.popoverPresentationController
    presentationController?.barButtonItem = sender
    presentationController?.sourceView = view
  }
  
  // MARK: - MapView
  func draw(file: GTFile) {
    startPinButton.isEnabled = true
    endPinButton.isEnabled = true
    zoomToFitButton.isEnabled = true
    shareButton.isEnabled = true
    
    allPoints.removeAll()
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
    startPins.removeAll()
    endPins.removeAll()
    
    let parser = ParserController(file: file)
    self.navigationItem.title = parser.title()
    
    parser.places()?.forEach({ place in
      mapView.addAnnotation(place)
    })
    
    parser.lines()?.forEach({ line in
      mapView.add(line.polyline)
      mapView.addAnnotation(line.startPin)
      mapView.addAnnotation(line.endPin)
      allPoints.append(contentsOf: line.coordinates)
      startPins.append(line.startPin)
      endPins.append(line.endPin)
    })

    HUD.hide()
    
    zoomToFit()
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is GTPolyline {
      let renderer = MKPolylineRenderer(overlay: overlay)
      let polyline = overlay as! GTPolyline
      renderer.strokeColor = polyline.strokeColor
      renderer.lineWidth = polyline.lineWidth
      return renderer
    }
    
    return MKOverlayRenderer()
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if !(annotation is GTPin) {
      return nil
    }
    
    let pin = annotation as! GTPin
    let reuseId = pin.identifier
    let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView.canShowCallout = true
    pinView.animatesDrop = true
    pinView.pinTintColor = pin.color
    
    let navigationButton = UIButton(type: .custom)
    navigationButton.setImage(UIImage(named: "car"), for: UIControlState())
    navigationButton.imageEdgeInsets = UIEdgeInsetsMake(16, 12, 29, 12)
    navigationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 64)
    navigationButton.backgroundColor = UIColor(red: 0, green: (122/255), blue: (255/255), alpha: 1)
    pinView.leftCalloutAccessoryView = navigationButton
    
    if let url = pin.iconUrl {
      let imagePinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      imagePinView.canShowCallout = true
      imagePinView.leftCalloutAccessoryView = pinView.leftCalloutAccessoryView
      
      let imageUrl = URL(string: url)
      
      if url.hasPrefix("/") {
        do {
          let imageData = try Data(contentsOf: imageUrl!)
          imagePinView.image = UIImage(data: imageData)
        } catch {
          print(error.localizedDescription)
        }
      }
      else {
        let request = URLRequest(url: imageUrl!)
        
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
          if error == nil {
            DispatchQueue.main.async {
              imagePinView.image = UIImage(data: data!)
            }
          }
        }
        session.resume()
      }
      
      return imagePinView
    }
    
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.leftCalloutAccessoryView {
      let annotation = view.annotation
      let placeMark = MKPlacemark(coordinate: annotation!.coordinate, addressDictionary: nil)
      let mapItem = MKMapItem(placemark: placeMark)
      mapItem.name = annotation!.title!
      
      let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
  }
  
  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    UIApplication.shared.isIdleTimerDisabled = mode == MKUserTrackingMode.follow || mode == MKUserTrackingMode.followWithHeading
  }
}

