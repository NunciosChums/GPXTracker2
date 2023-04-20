import CoreLocation
import MapKit
import PKHUD
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var shareButton: UIBarButtonItem!
  @IBOutlet var toggleMapTypeButton: UIButton!
  @IBOutlet var zoomToFitButton: UIButton!
  @IBOutlet var endPinButton: UIButton!
  @IBOutlet var startPinButton: UIButton!
  @IBOutlet var bottomMarginConstraint: NSLayoutConstraint!

  var allPoints: [CLLocationCoordinate2D] = []
  var startPinIndex = 0
  var endPinIndex = 0
  var startPins: [GTPin] = []
  var endPins: [GTPin] = []
  var filePathForShare: String = ""

  override func viewDidLoad() {
    super.viewDidLoad()

    registerObserver()
    addGoToCurrentLocationBarButtonItem()

    mapView.mapType = UserDefaults.mapType
    updateMapTypeButtonImage()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Initial

  func addGoToCurrentLocationBarButtonItem() {
    LocationProvider.shared.request()
    let currentLocationItem = MKUserTrackingBarButtonItem(mapView: mapView)
    navigationItem.setRightBarButton(currentLocationItem, animated: true)
    currentLocationItem.perform(currentLocationItem.action)
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
    UserDefaults.mapType = mapType
    updateMapTypeButtonImage()
  }

  @IBAction func zoomToFitButtonClicked(_ sender: Any) {
    zoomToFit()
  }

  func updateMapTypeButtonImage() {
    toggleMapTypeButton.isSelected = mapView.mapType == MKMapType.hybrid
  }

  func zoomToFit() {
    mapView.annotations.forEach { annotation in
      if annotation is GTPin {
        allPoints.append(annotation.coordinate)
      }
    }

    let all = MKPolyline(coordinates: &allPoints, count: allPoints.count)
    mapView.setVisibleMapRect(all.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
  }

  @objc func fileSelected(notification: Notification) {
    HUD.show(.progress)

    let userInfo: [String: GTFile] = (notification as NSNotification).userInfo as! [String: GTFile]
    let file: GTFile = userInfo[SELECTED_FILE_PATH]!
    filePathForShare = file.path.path

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.draw(file: file)
    }
  }

  @IBAction func goToStartPin(_ sender: Any) {
    guard !startPins.isEmpty else { return }

    moveTo(location: startPins[startPinIndex].coordinate)

    startPinIndex += 1
    if startPinIndex >= startPins.count {
      startPinIndex = 0
    }
  }

  @IBAction func goToEndPin(_ sender: Any) {
    guard !endPins.isEmpty else { return }

    moveTo(location: endPins[endPinIndex].coordinate)

    endPinIndex += 1
    if endPinIndex >= endPins.count {
      endPinIndex = 0
    }
  }

  func moveTo(location: CLLocationCoordinate2D) {
    if CLLocationCoordinate2DIsValid(location) {
      let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      let region = MKCoordinateRegion(center: location, span: span)
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
    navigationItem.title = parser.title()

    parser.places()?.forEach { place in
      mapView.addAnnotation(place)
    }

    parser.lines()?.forEach { line in
      mapView.addOverlay(line.polyline)
      mapView.addAnnotation(line.startPin)
      mapView.addAnnotation(line.endPin)
      allPoints.append(contentsOf: line.coordinates)
      startPins.append(line.startPin)
      endPins.append(line.endPin)
    }

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
    let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView.canShowCallout = true
    pinView.animatesWhenAdded = true
    pinView.markerTintColor = pin.color

    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 12, bottom: 29, trailing: 12)
    
    let navigationButton = UIButton(type: .custom)
    navigationButton.configuration = configuration
    navigationButton.setImage(UIImage(systemName: "car.fill")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
    navigationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 64)
    navigationButton.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 255 / 255, alpha: 1)
    pinView.leftCalloutAccessoryView = navigationButton

    if let url = pin.iconUrl {
      let imagePinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      imagePinView.canShowCallout = true
      imagePinView.leftCalloutAccessoryView = pinView.leftCalloutAccessoryView

      let imageUrl = URL(string: url)
      let request = URLRequest(url: imageUrl!)

      let session = URLSession.shared.dataTask(with: request) { data, _, error in
        if error == nil {
          DispatchQueue.main.async {
            imagePinView.image = UIImage(data: data!)
          }
        }
      }
      session.resume()

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

      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
  }

  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    UIApplication.shared.isIdleTimerDisabled = mode == MKUserTrackingMode.follow || mode == MKUserTrackingMode.followWithHeading
  }
}
