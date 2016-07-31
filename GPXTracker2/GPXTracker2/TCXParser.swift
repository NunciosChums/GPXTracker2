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
        let lat: NSString = point.css("LatitudeDegrees").first?.text,
        let lon: NSString = point.css("LongitudeDegrees").first?.text
        else {continue}
      
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      var color: UIColor = MKPinAnnotationView.purplePinColor()
      
      if let type: String = point.css("PointType").first?.text {
        switch(type.lowercaseString){
        case "right":
          color = UIColor.yellowColor()
          break;
          
        case "left":
          color = UIColor.orangeColor()
          break;
          
        case "danger":
          color = UIColor.magentaColor()
          break;
          
        case "water":
          color = UIColor.cyanColor()
          break;
          
        case "submmit":
          color = UIColor.grayColor()
          break;
          
        case "food":
          color = UIColor.brownColor()
          break;
          
        case "straight":
          color = UIColor.blackColor()
          break;
          
        default:
          color = UIColor.purpleColor()
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
        guard let lat: NSString = position.css("LatitudeDegrees").first?.text,
              let lon: NSString = position.css("LongitudeDegrees").first?.text
          else {continue}
        
        locations.append(CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue))
      }
    }
    
    var result: [Line] = []
    if locations.count > 0 {
      result.append(Line(coordinates: &locations, color: UIColor.blueColor(), lineWidth: 3))
    }
    return result
  }
}