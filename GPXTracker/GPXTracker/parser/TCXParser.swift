import Foundation
import Kanna
import MapKit

class TCXParser: BaseParser {
  let xml: XMLDocument

  init(xml: XMLDocument) {
    self.xml = xml
  }

  func title() -> String? {
    guard let result = xml.css("Course Name").first?.text else { return nil }
    return result
  }

  func places() -> [GTPin]? {
    var result: [GTPin] = []

    for point in xml.css("CoursePoint") {
      guard let name: String = point.css("Name").first?.text,
            let lat: NSString = point.css("LatitudeDegrees").first?.text as NSString?,
            let lon: NSString = point.css("LongitudeDegrees").first?.text as NSString?
      else { continue }

      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      var color: UIColor = .systemPurple

      if let type: String = point.css("PointType").first?.text {
        switch type.lowercased() {
        case "right":
          color = .yellow

        case "left":
          color = .orange

        case "danger":
          color = .magenta

        case "water":
          color = .cyan

        case "submmit":
          color = .gray

        case "food":
          color = .brown

        case "straight":
          color = .black

        default:
          color = .systemPurple
        }
      }

      result.append(GTPin(title: name, coordinate: location, color: color))
    }

    return result
  }

  func lines() -> [GTLine]? {
    var locations: [CLLocationCoordinate2D] = []

    for point in xml.css("Trackpoint") {
      for position in point.css("Position") {
        guard let lat: NSString = position.css("LatitudeDegrees").first?.text as NSString?,
              let lon: NSString = position.css("LongitudeDegrees").first?.text as NSString?
        else { continue }

        locations.append(CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue))
      }
    }

    var result: [GTLine] = []
    if !locations.isEmpty {
      result.append(GTLine(coordinates: &locations, color: .systemRed, lineWidth: 4))
    }
    return result
  }
}
