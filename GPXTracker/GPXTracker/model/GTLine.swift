import CoreLocation
import SwiftUI

struct GTLine: Identifiable, Sendable {
  let id: UUID
  let coordinates: [CLLocationCoordinate2D]
  let strokeColor: Color
  let lineWidth: CGFloat
  let startPin: GTPin
  let endPin: GTPin

  init?(coordinates: [CLLocationCoordinate2D], color: Color, lineWidth: CGFloat = 4) {
    guard let first = coordinates.first, let last = coordinates.last else { return nil }
    id = UUID()
    self.coordinates = coordinates
    strokeColor = color
    self.lineWidth = lineWidth
    startPin = GTPin(title: "start", coordinate: first, color: .green)
    endPin = GTPin(title: "end", coordinate: last, color: .red)
  }
}
