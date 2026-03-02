import CoreLocation
import SwiftUI

struct GTPin: Identifiable, Sendable {
  let id: UUID
  let title: String
  let coordinate: CLLocationCoordinate2D
  let color: Color
  var iconUrl: String?

  init(title: String, coordinate: CLLocationCoordinate2D, color: Color = .purple) {
    id = UUID()
    self.title = title
    self.coordinate = coordinate
    self.color = color
    iconUrl = nil
  }

  init(title: String, coordinate: CLLocationCoordinate2D, iconUrl: String = "") {
    id = UUID()
    self.title = title
    self.coordinate = coordinate
    color = .purple
    self.iconUrl = iconUrl.isEmpty ? nil : iconUrl
  }
}
