import Foundation
import MapKit

class GTPolyline: MKPolyline {
  var strokeColor: UIColor = .systemRed
  var lineWidth: CGFloat = 4

  func set(color: UIColor, width: CGFloat = 4) {
    strokeColor = color
    lineWidth = width
  }
}
