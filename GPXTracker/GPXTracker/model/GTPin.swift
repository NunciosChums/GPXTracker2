import Foundation
import MapKit

class GTPin: NSObject, MKAnnotation {
  let identifier: String
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let color: UIColor
  var iconUrl: String?

  init(title: String, coordinate: CLLocationCoordinate2D, color: UIColor = .systemPurple) {
    identifier = String(arc4random())
    self.title = title
    self.coordinate = coordinate
    self.color = color
    iconUrl = nil
  }

  init(title: String, coordinate: CLLocationCoordinate2D, iconUrl: String = "") {
    identifier = String(arc4random())
    self.title = title
    self.coordinate = coordinate
    color = .systemPurple
    self.iconUrl = iconUrl.count == 0 ? nil : iconUrl
  }
}
