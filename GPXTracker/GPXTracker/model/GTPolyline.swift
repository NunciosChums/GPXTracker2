import Foundation
import MapKit

class GTPolyline: MKPolyline {
  var strokeColor: UIColor
  var lineWidth: CGFloat

  override init() {
    strokeColor = .systemRed
    lineWidth = 4
  }

  func set(color: UIColor, width: CGFloat = 4) {
    strokeColor = color
    lineWidth = width
  }
}
