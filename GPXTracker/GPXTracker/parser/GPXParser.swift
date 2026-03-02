import Foundation
import Kanna
import MapKit
import SwiftUI

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
      result.append(GTPin(title: name, coordinate: location, color: .purple))
    }

    return result
  }

  func lines() -> [GTLine]? {
    var result: [GTLine] = []

    var trkLocations: [CLLocationCoordinate2D] = []
    for trkpt in xml.css("trkpt") {
      if let location = makeLocation(point: trkpt) {
        trkLocations.append(location)
      }
    }
    if let line = GTLine(coordinates: trkLocations, color: .red, lineWidth: 4) {
      result.append(line)
    }

    var rteLocations: [CLLocationCoordinate2D] = []
    for rtept in xml.css("rtept") {
      if let location = makeLocation(point: rtept) {
        rteLocations.append(location)
      }
    }
    if let line = GTLine(coordinates: rteLocations, color: .blue, lineWidth: 4) {
      result.append(line)
    }

    return result
  }

  private func makeLocation(point: XMLElement) -> CLLocationCoordinate2D? {
    guard let lonStr = point["lon"], let latStr = point["lat"] else { return nil }
    let lon = (lonStr as NSString).doubleValue
    let lat = (latStr as NSString).doubleValue
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
}
