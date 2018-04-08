import Foundation
import MapKit

class GTPolyline: MKPolyline {
  var strokeColor: UIColor
  var lineWidth: CGFloat
  
  override init() {
    self.strokeColor = UIColor.blue
    self.lineWidth = 3
  }
  
  func set(color: UIColor, width: CGFloat = 3) {
    self.strokeColor = color
    self.lineWidth = width
  }
}
