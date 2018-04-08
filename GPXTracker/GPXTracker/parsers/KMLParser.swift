import Foundation
import MapKit
import Kanna

class KMLParser: BaseParser {
  let xml: XMLDocument
  
  init(xml: XMLDocument) {
    self.xml = xml
  }
  
  func title() -> String? {
    guard let result = xml.css("Document name").first?.text else { return  nil }
    return result
  }
  
  func places() -> [GTPin]? {
    var result: [GTPin] = []
    
    var iconStyles: [IconStyle] = []
    
    for style in xml.css("Style") {
      guard let id:String = style["id"],
        let href = style.css("href").first?.text
        else {continue}
      
      iconStyles.append(IconStyle(id: id.replacingOccurrences(of: "-normal", with: ""), href: href))
    }
    
    for styleMap in xml.css("StyleMap"){
      guard let id:String = styleMap["id"],
        let normal = styleMap.css("Pair styleUrl").first?.text?.replacingOccurrences(of: "#", with: "")
        else {continue}
      
      for iconStyle in iconStyles {
        if iconStyle.id == normal {
          iconStyles.append(IconStyle(id: id, href: iconStyle.href))
          break
        }
      }
    }
    
    for placemark in xml.css("Placemark") {
      guard let name:String = placemark.css("name").first?.text else {continue}
      
      for _ in placemark.css("Point") {
        guard let coordinates = placemark.css("coordinates").first?.text else {continue}
        
        let split = coordinates.components(separatedBy: ",")
        let lon:NSString = split[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let lat:NSString = split[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
        guard let styleUrlString = placemark.css("styleUrl").first?.text else {continue}
        let styleUrl = styleUrlString.replacingOccurrences(of: "#", with: "")
        
        for icon in iconStyles {
          if icon.id == styleUrl {
            result.append(GTPin(title: name, coordinate: location, iconUrl: icon.href))
          }
        }
      }
    }
    
    return result
  }
  
  func lines() -> [GTLine]? {
    var lineStyles: [LineStyle] = []
    
    for style in xml.css("Style") {
      let id = style["id"]!
      
      for lineStyle in style.css("LineStyle") {
        guard let width = lineStyle.css("width").first?.text,
          let color = lineStyle.css("color").first?.text else {continue}
        
        lineStyles.append(LineStyle(id: id.replacingOccurrences(of: "-normal", with: ""),
                                    color:KMLParser.stringToColor(hexString: "#"+color), width:width))
      }
    }
    
    for styleMap in xml.css("StyleMap"){
      guard let id:String = styleMap["id"],
        let normal = styleMap.css("Pair styleUrl").first?.text?.replacingOccurrences(of: "#", with: "")
        else {continue}
      
      for lineStyle in lineStyles {
        if lineStyle.id == normal {
          lineStyles.append(LineStyle(id: id, color:lineStyle.color, width:lineStyle.width))
          break
        }
      }
    }
    
    var result: [GTLine] = []
    
    for placemark in xml.css("Placemark") {
      guard let styleUrlString = placemark.css("styleUrl").first?.text else {continue}
      let styleUrl = styleUrlString.replacingOccurrences(of: "#", with: "")
      
      for lineString in placemark.css("LineString"){
        guard let coordinatesString = lineString.css("coordinates").first?.text else {continue}
        let coordinates = coordinatesString.replacingOccurrences(of: "\n", with: "")
        let splitLine = coordinates.split{$0 == " "}.map(String.init)
        
        var locations: [CLLocationCoordinate2D] = []
        
        for line in splitLine {
          let split = line.split{$0 == ","}.map(String.init)
          let lon:NSString = split[0] as NSString
          let lat:NSString = split[1] as NSString
          let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
          locations.append(location)
        }
        
        for lineStyle in lineStyles {
          if lineStyle.id == styleUrl {
            result.append(GTLine(coordinates: &locations,
                                 color:lineStyle.color ,
                                 lineWidth: CGFloat((lineStyle.width as NSString).floatValue)))
          }
        }
      }
    }
    
    return result
  }
  
  // hexString #ffF08641, ff: a, f0: b, 86: b, 41: r
  class func stringToColor(hexString:String) -> UIColor {
    let r, g, b, a: CGFloat
    
    if hexString.hasPrefix("#") {
      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      let hexColor = hexString[start...]
      
      if hexColor.count == 8 {
        let scanner = Scanner(string: String(hexColor))
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
          a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          b = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          r = CGFloat(hexNumber & 0x000000ff) / 255
          
          return UIColor(red: r, green: g, blue: b, alpha: a)
        }
      }
    }
    
    return UIColor.blue
  }
  
  struct IconStyle {
    var id:String
    var href:String
  }
  
  struct LineStyle {
    var id:String
    var color:UIColor
    var width:String
  }
  
  struct Placemark {
    var name:String
    var styleUrl:String
    var coordinates:String
  }
}
