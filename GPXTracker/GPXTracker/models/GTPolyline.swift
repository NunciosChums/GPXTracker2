import Foundation
import MapKit

class GTPolyline: MKPolyline {
  var strokeColor: UIColor
  var lineWidth: CGFloat

  override init() {
    strokeColor = UIColor.blue
    lineWidth = 3
  }

  func set(color: UIColor, width: CGFloat = 3) {
    strokeColor = color
    lineWidth = width
  }
}
