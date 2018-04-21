import Foundation
import MapKit

class GTPin: NSObject, MKAnnotation {
  let identifier: String
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let color: UIColor
  var iconUrl: String?
  
  init(title: String, coordinate: CLLocationCoordinate2D, color: UIColor = MKPinAnnotationView.purplePinColor()){
    self.identifier = String(arc4random())
    self.title = title
    self.coordinate = coordinate
    self.color = color
    self.iconUrl = nil
  }
  
  init(title: String, coordinate: CLLocationCoordinate2D, iconUrl: String = ""){
    self.identifier = String(arc4random())
    self.title = title
    self.coordinate = coordinate
    self.color = MKPinAnnotationView.purplePinColor()
    self.iconUrl = iconUrl.count == 0 ? nil : iconUrl
  }
}
