import CoreLocation
import MapKit
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
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "location.fill"), for: .normal)
    button.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
    navigationItem.setRightBarButton(UIBarButtonItem(customView: button), animated: true)
    mapView.setUserTrackingMode(.follow, animated: true)
  }

  func registerObserver() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fileSelected(notification:)),
                                           name: Notification.Name(rawValue: SELECTED_FILE),
                                           object: nil)
  }

  // MARK: - User Action

  @objc func currentLocationButtonTapped() {
    switch mapView.userTrackingMode {
    case .none:
      mapView.setUserTrackingMode(.follow, animated: true)
    case .follow:
      mapView.setUserTrackingMode(.followWithHeading, animated: true)
    case .followWithHeading:
      mapView.setUserTrackingMode(.none, animated: true)
    @unknown default:
      mapView.setUserTrackingMode(.follow, animated: true)
    }
  }

  func updateCurrentLocationButtonImage() {
    guard let button = navigationItem.rightBarButtonItem?.customView as? UIButton else { return }
    let imageName: String
    switch mapView.userTrackingMode {
    case .none: imageName = "location"
    case .follow: imageName = "location.fill"
    case .followWithHeading: imageName = "location.north.fill"
    @unknown default: imageName = "location"
    }
    button.setImage(UIImage(systemName: imageName), for: .normal)
  }

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
    let all = MKPolyline(coordinates: &allPoints, count: allPoints.count)
    mapView.setVisibleMapRect(all.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
  }

  @objc func fileSelected(notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: GTFile],
          let file = userInfo[SELECTED_FILE_PATH]
    else { return }

    ProgressHUD.show()
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

    ProgressHUD.hide()

    zoomToFit()
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? GTPolyline {
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = polyline.strokeColor
      renderer.lineWidth = polyline.lineWidth
      return renderer
    }

    return MKOverlayRenderer()
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let pin = annotation as? GTPin else {
      return nil
    }

    let blueColor = UIColor(red: 0, green: 122 / 255, blue: 255 / 255, alpha: 1)
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 12, bottom: 29, trailing: 12)
    configuration.baseBackgroundColor = blueColor
    configuration.image = UIImage(systemName: "car.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    configuration.background.cornerRadius = 0

    let navigationButton = UIButton(configuration: configuration)
    navigationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 64)

    if let url = pin.iconUrl, let imageUrl = URL(string: url) {
      let reuseId = "ImagePinView"
      let imagePinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        ?? MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      imagePinView.annotation = annotation
      imagePinView.canShowCallout = true
      imagePinView.leftCalloutAccessoryView = navigationButton

      let request = URLRequest(url: imageUrl)
      URLSession.shared.dataTask(with: request) { data, _, error in
        guard error == nil, let data = data else { return }
        DispatchQueue.main.async {
          imagePinView.image = UIImage(data: data)
        }
      }.resume()

      return imagePinView
    }

    let reuseId = "MarkerPinView"
    let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
      ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView.annotation = annotation
    pinView.canShowCallout = true
    pinView.animatesWhenAdded = true
    pinView.markerTintColor = pin.color
    pinView.leftCalloutAccessoryView = navigationButton

    return pinView
  }

  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.leftCalloutAccessoryView,
       let annotation = view.annotation
    {
      let placeMark = MKPlacemark(coordinate: annotation.coordinate)
      let mapItem = MKMapItem(placemark: placeMark)
      mapItem.name = annotation.title ?? ""

      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
  }

  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    UIApplication.shared.isIdleTimerDisabled = mode == .follow || mode == .followWithHeading
    updateCurrentLocationButtonImage()
  }
}
