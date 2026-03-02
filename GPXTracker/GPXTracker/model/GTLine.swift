import Foundation
import MapKit

class GTLine {
  let coordinates: [CLLocationCoordinate2D]
  let polyline: GTPolyline
  let startPin: GTPin
  let endPin: GTPin

  init?(coordinates: inout [CLLocationCoordinate2D], color: UIColor, lineWidth: CGFloat = 4) {
    guard let first = coordinates.first, let last = coordinates.last else { return nil }
    self.coordinates = coordinates
    polyline = GTPolyline(coordinates: &coordinates, count: coordinates.count)
    polyline.strokeColor = color
    polyline.lineWidth = lineWidth

    startPin = GTPin(title: START, coordinate: first, color: .systemGreen)
    endPin = GTPin(title: END, coordinate: last, color: .red)
  }
}
