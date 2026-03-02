import Foundation
import Kanna
import MapKit
import SwiftUI

class KMLParser: BaseParser {
  let xml: XMLDocument

  init(xml: XMLDocument) {
    self.xml = xml
  }

  func title() -> String? {
    guard let result = xml.css("Document name").first?.text else { return nil }
    return result
  }

  func places() -> [GTPin]? {
    var result: [GTPin] = []

    var iconStyleMap: [String: String] = [:]

    for style in xml.css("Style") {
      guard let id: String = style["id"],
            let href = style.css("href").first?.text
      else { continue }

      iconStyleMap[id.replacingOccurrences(of: "-normal", with: "")] = href
    }

    for styleMap in xml.css("StyleMap") {
      guard let id: String = styleMap["id"],
            let normal = styleMap.css("Pair styleUrl").first?.text?.replacingOccurrences(of: "#", with: "")
      else { continue }

      if let href = iconStyleMap[normal] {
        iconStyleMap[id] = href
      }
    }

    for placemark in xml.css("Placemark") {
      guard let name: String = placemark.css("name").first?.text else { continue }

      for point in placemark.css("Point") {
        guard let coordinates = point.css("coordinates").first?.text else { continue }

        let split = coordinates.components(separatedBy: ",")
        guard split.count >= 2 else { continue }

        let lon: NSString = split[0].trimmingCharacters(in: .whitespacesAndNewlines) as NSString
        let lat: NSString = split[1].trimmingCharacters(in: .whitespacesAndNewlines) as NSString
        let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)

        guard let styleUrlString = placemark.css("styleUrl").first?.text else { continue }
        let styleUrl = styleUrlString.replacingOccurrences(of: "#", with: "")

        if let href = iconStyleMap[styleUrl] {
          result.append(GTPin(title: name, coordinate: location, iconUrl: href))
        }
      }
    }

    return result
  }

  func lines() -> [GTLine]? {
    var lineStyleMap: [String: LineStyle] = [:]

    for style in xml.css("Style") {
      guard let id: String = style["id"] else { continue }

      for lineStyle in style.css("LineStyle") {
        guard let width = lineStyle.css("width").first?.text,
              let color = lineStyle.css("color").first?.text else { continue }

        lineStyleMap[id.replacingOccurrences(of: "-normal", with: "")] =
          LineStyle(color: KMLParser.stringToColor(hexString: "#" + color), width: width)
      }
    }

    for styleMap in xml.css("StyleMap") {
      guard let id: String = styleMap["id"],
            let normal = styleMap.css("Pair styleUrl").first?.text?.replacingOccurrences(of: "#", with: "")
      else { continue }

      if let lineStyle = lineStyleMap[normal] {
        lineStyleMap[id] = lineStyle
      }
    }

    var result: [GTLine] = []

    for placemark in xml.css("Placemark") {
      guard let styleUrlString = placemark.css("styleUrl").first?.text else { continue }
      let styleUrl = styleUrlString.replacingOccurrences(of: "#", with: "")

      guard let lineStyle = lineStyleMap[styleUrl] else { continue }

      for lineString in placemark.css("LineString") {
        guard let coordinatesString = lineString.css("coordinates").first?.text else { continue }
        let coordinates = coordinatesString.replacingOccurrences(of: "\n", with: "")
        let splitLine = coordinates.split { $0 == " " }.map(String.init)

        var locations: [CLLocationCoordinate2D] = []

        for line in splitLine {
          let split = line.split { $0 == "," }.map(String.init)
          guard split.count >= 2 else { continue }

          let lon: NSString = split[0] as NSString
          let lat: NSString = split[1] as NSString
          locations.append(CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue))
        }

        if let gtLine = GTLine(coordinates: locations,
                               color: lineStyle.color,
                               lineWidth: CGFloat((lineStyle.width as NSString).floatValue)) {
          result.append(gtLine)
        }
      }
    }

    return result
  }

  // KML color format: #ffBBGGRR (alpha, blue, green, red)
  class func stringToColor(hexString: String) -> Color {
    if hexString.hasPrefix("#") {
      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      let hexColor = hexString[start...]

      if hexColor.count == 8 {
        let scanner = Scanner(string: String(hexColor))
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          let a = Double((hexNumber & 0xFF00_0000) >> 24) / 255
          let b = Double((hexNumber & 0x00FF_0000) >> 16) / 255
          let g = Double((hexNumber & 0x0000_FF00) >> 8) / 255
          let r = Double(hexNumber & 0x0000_00FF) / 255
          return Color(red: r, green: g, blue: b, opacity: a)
        }
      }
    }
    return .blue
  }

  struct IconStyle {
    var id: String
    var href: String
  }

  struct LineStyle {
    var color: Color
    var width: String
  }
}
