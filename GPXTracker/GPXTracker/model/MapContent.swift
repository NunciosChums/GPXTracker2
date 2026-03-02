import CoreLocation
import MapKit

struct MapContent: Sendable {
  let title: String
  let lines: [GTLine]
  let places: [GTPin]
  let allCoordinates: [CLLocationCoordinate2D]

  static let empty = MapContent(title: "", lines: [], places: [], allCoordinates: [])
}

extension Array where Element == CLLocationCoordinate2D {
  var boundingMapRect: MKMapRect {
    let points = map { MKMapPoint($0) }
    guard let first = points.first else { return .world }
    var rect = MKMapRect(origin: first, size: MKMapSize(width: 0, height: 0))
    for point in points.dropFirst() {
      let pointRect = MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
      rect = rect.union(pointRect)
    }
    return rect
  }
}

extension MKMapRect {
  /// rect를 각 방향으로 비율만큼 확장한다. factor가 양수면 축소, 음수면 확장.
  func insetBy(factor: Double) -> MKMapRect {
    let dx = size.width * factor
    let dy = size.height * factor
    return MKMapRect(
      x: origin.x + dx,
      y: origin.y + dy,
      width: size.width - dx * 2,
      height: size.height - dy * 2
    )
  }
}
