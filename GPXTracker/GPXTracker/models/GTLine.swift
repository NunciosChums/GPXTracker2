import Foundation
import MapKit

class GTLine {
  let coordinates: [CLLocationCoordinate2D]
  let polyline: GTPolyline
  let startPin: GTPin
  let endPin: GTPin
  
  init(coordinates: inout [CLLocationCoordinate2D], color: UIColor, lineWidth: CGFloat = 3){
    self.coordinates = coordinates
    self.polyline = GTPolyline(coordinates: &coordinates, count: coordinates.count)
    self.polyline.strokeColor = color
    self.polyline.lineWidth = lineWidth
    
    self.startPin = GTPin(title: START, coordinate: coordinates.first!, color: MKPinAnnotationView.greenPinColor())
    self.endPin = GTPin(title: END, coordinate: coordinates.last!, color: MKPinAnnotationView.redPinColor())
  }
}
