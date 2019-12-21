import Foundation
import Kanna
import MapKit

class GPXParser: BaseParser {
  let xml: XMLDocument

  init(xml: XMLDocument) {
    self.xml = xml
  }

  func title() -> String? {
    guard let result = xml.css("trk name").first?.text else { return nil }
    return result
  }

  func places() -> [GTPin]? {
    var result: [GTPin] = []

    for wpt in xml.css("wpt") {
      guard let lon = wpt["lon"],
        let lat = wpt["lat"],
        let name: String = wpt.css("name").first?.text
        else { continue }

      let location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (lon as NSString).doubleValue)
      result.append(GTPin(title: name, coordinate: location, color: MKPinAnnotationView.purplePinColor()))
    }

    return result
  }

  func lines() -> [GTLine]? {
    var locations: [CLLocationCoordinate2D] = []

    for trkpt in xml.css("trkpt") {
      locations.append(makeLocation(point: trkpt))
    }

    for rtept in xml.css("rtept") {
      locations.append(makeLocation(point: rtept))
    }

    var result: [GTLine] = []
    if !locations.isEmpty {
      result.append(GTLine(coordinates: &locations, color: UIColor.blue, lineWidth: 3))
    }

    return result
  }

  private func makeLocation(point: XMLElement) -> CLLocationCoordinate2D {
    let lon: NSString = point["lon"]! as NSString
    let lat: NSString = point["lat"]! as NSString
    return CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
  }
}
