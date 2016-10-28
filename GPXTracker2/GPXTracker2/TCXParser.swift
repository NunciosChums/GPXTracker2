//
//  TCXParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit
import Kanna

class TCXParser {
  
  class func title(xml:XMLDocument) -> String {
    let result = xml.css("Course Name").first?.text
    return result ?? ""
  }
  
  class func places(xml: XMLDocument) -> [GTPin] {
    var result: [GTPin] = []
    
    for point in xml.css("CoursePoint") {
      guard let name: String = point.css("Name").first?.text,
        let lat: NSString = point.css("LatitudeDegrees").first?.text as NSString?,
        let lon: NSString = point.css("LongitudeDegrees").first?.text as NSString?
        else {continue}
      
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      var color: UIColor = MKPinAnnotationView.purplePinColor()
      
      if let type: String = point.css("PointType").first?.text {
        switch(type.lowercased()){
        case "right":
          color = UIColor.yellow
          break;
          
        case "left":
          color = UIColor.orange
          break;
          
        case "danger":
          color = UIColor.magenta
          break;
          
        case "water":
          color = UIColor.cyan
          break;
          
        case "submmit":
          color = UIColor.gray
          break;
          
        case "food":
          color = UIColor.brown
          break;
          
        case "straight":
          color = UIColor.black
          break;
          
        default:
          color = UIColor.purple
          break;
        }
      }
      
      result.append(GTPin(title: name, coordinate: location, color: color))
    }
    
    return result
  }
  
  class func lines(xml: XMLDocument) -> [Line] {
    var locations: [CLLocationCoordinate2D] = []
    
    for point in xml.css("Trackpoint") {
      for position in point.css("Position") {
        guard let lat: NSString = position.css("LatitudeDegrees").first?.text as NSString?,
              let lon: NSString = position.css("LongitudeDegrees").first?.text as NSString?
          else {continue}
        
        locations.append(CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue))
      }
    }
    
    var result: [Line] = []
    if locations.count > 0 {
      result.append(Line(coordinates: &locations, color: UIColor.blue, lineWidth: 3))
    }
    return result
  }
}
