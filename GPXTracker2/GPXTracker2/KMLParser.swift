//
//  KMLParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit
import Kanna

class KMLParser {
  
  class func title(xml: XMLDocument) -> String {
    let result = xml.css("Document name").first?.text
    return result ?? ""
  }
  
  class func places(xml: XMLDocument) -> [GTPin] {
    var result: [GTPin] = []
    
    var iconStyles: [IconStyle] = []
    
    for style in xml.css("Style") {
      guard let id:String = style["id"],
            let href = style.css("href").first?.text
        else {continue}
      
      iconStyles.append(IconStyle(id: id.stringByReplacingOccurrencesOfString("-normal", withString: ""), href: href))
    }
    
    for placemark in xml.css("Placemark") {
      guard let name:String = placemark.css("name").first?.text else {continue}
      
      for _ in placemark.css("Point") {
        guard let coordinates = placemark.css("coordinates").first?.text else {continue}
        
        let split = coordinates.characters.split{$0 == ","}.map(String.init)
        let lon:NSString = split[0]
        let lat:NSString = split[1]
        let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
        guard let styleUrlString = placemark.css("styleUrl").first?.text else {continue}
        let styleUrl = styleUrlString.stringByReplacingOccurrencesOfString("#", withString: "")
        
        for icon in iconStyles {
          if icon.id == styleUrl {
            result.append(GTPin(title: name, coordinate: location, iconUrl: icon.href))
          }
        }
      }
    }
    
    return result
  }
  
  class func lines(xml: XMLDocument) -> [Line] {
    var lineStyles: [LineStyle] = []
    
    for style in xml.css("Style") {
      let id = style["id"]!
      
      for lineStyle in style.css("LineStyle") {
        guard let width = lineStyle.css("width").first?.text,
          let color = lineStyle.css("color").first?.text else {continue}
        
        lineStyles.append(LineStyle(id: id.stringByReplacingOccurrencesOfString("-normal", withString: ""),
          color:KMLParser.stringToColor("#"+color), width:width))
      }
    }
    
    var result: [Line] = []
    
    for placemark in xml.css("Placemark") {
      guard let styleUrlString = placemark.css("styleUrl").first?.text else {continue}
      let styleUrl = styleUrlString.stringByReplacingOccurrencesOfString("#", withString: "")
      
      for lineString in placemark.css("LineString"){
        guard let coordinatesString = lineString.css("coordinates").first?.text else {continue}
        let coordinates = coordinatesString.stringByReplacingOccurrencesOfString("\n", withString: "")
        let splitLine = coordinates.characters.split{$0 == " "}.map(String.init)
        
        var locations: [CLLocationCoordinate2D] = []
        
        for line in splitLine {
          let split = line.characters.split{$0 == ","}.map(String.init)
          let lon:NSString = split[0]
          let lat:NSString = split[1]
          let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
          locations.append(location)
        }
        
        for lineStyle in lineStyles {
          if lineStyle.id == styleUrl {
            result.append(Line(coordinates: &locations, color:lineStyle.color , lineWidth: (lineStyle.width as NSString).floatValue))
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
      let start = hexString.startIndex.advancedBy(1)
      let hexColor = hexString.substringFromIndex(start)
      
      if hexColor.characters.count == 8 {
        let scanner = NSScanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexLongLong(&hexNumber) {
          a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          b = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          r = CGFloat(hexNumber & 0x000000ff) / 255
          
          return UIColor(red: r, green: g, blue: b, alpha: a)
        }
      }
    }
    
    return UIColor.blueColor()
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