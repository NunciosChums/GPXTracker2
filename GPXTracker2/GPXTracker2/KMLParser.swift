//
//  KMLParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import SWXMLHash
import MapKit

class KMLParser {
  
  class func title(xml: XMLIndexer) -> String {
    let result = xml["kml"]["Document"]["name"].element?.text
    return result ?? ""
  }
  
  class func places(xml: XMLIndexer) -> [GTPin] {
    var result: [GTPin] = []
    
    let document = xml["kml"]["Document"]
    
    var iconStyles: [IconStyle] = []
    let styles = document["Style"]
    
    for style in styles {
      if style["IconStyle"] {
        let id:String = (style.element?.attributes["id"]!)!
        let href = (style["IconStyle"]["Icon"]["href"].element?.text)!
        iconStyles.append(IconStyle(id: id.stringByReplacingOccurrencesOfString("-normal", withString: ""), href: href))
      }
    }
    
    var folders = document["Folder"]
    if !folders {
      folders = document // when old type kml
    }

    for folder in folders {
      let placemarks = folder["Placemark"]
      
      for placemark in placemarks {
        let name:String = (placemark["name"].element?.text)!
        if let coordinates = placemark["Point"]["coordinates"].element {
          let coordinate:String = coordinates.text!
          let split = coordinate.characters.split{$0 == ","}.map(String.init)
          let lon:NSString = split[0]
          let lat:NSString = split[1]
          let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
          let styleUrl = placemark["styleUrl"].element?.text?.stringByReplacingOccurrencesOfString("#", withString: "")

          for icon in iconStyles {
            if icon.id == styleUrl {
              result.append(GTPin(title: name, coordinate: location, iconUrl: icon.href))
            }
          }
        }
      }
    }
    
    return result
  }
  
  class func lines(xml: XMLIndexer) -> [Line] {
    let document = xml["kml"]["Document"]
    
    var lineStyles: [LineStyle] = []
    let styles = document["Style"]
    
    for style in styles {
      let lineStyle = style["LineStyle"]
      
      if lineStyle {
        let id:String = (style.element?.attributes["id"]!)!
        let width = lineStyle["width"].element?.text
        let color = lineStyle["color"].element?.text
        lineStyles.append(LineStyle(id: id.stringByReplacingOccurrencesOfString("-normal", withString: ""), color:KMLParser.stringToColor("#"+color!), width:width!))
      }
    }
    
    var folders = document["Folder"]
    if !folders {
      folders = document // when old type kml
    }
    
    var result: [Line] = []
    
    for folder in folders {
      let placemarks = folder["Placemark"]
      
      for placemark in placemarks {
        let styleUrl = placemark["styleUrl"].element?.text?.stringByReplacingOccurrencesOfString("#", withString: "")
        let lineString = placemark["LineString"]
        if lineString {
          let coordinates = lineString["coordinates"].element?.text?.stringByReplacingOccurrencesOfString("\n", withString: "")
          let splitLine = coordinates!.characters.split{$0 == " "}.map(String.init)
          
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
              result.append(Line(coordinates: locations, color:lineStyle.color , lineWidth: (lineStyle.width as NSString).floatValue))
            }
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