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
      let name: String = point.css("Name").text!
      let lat: NSString = point.css("LatitudeDegrees").text!
      let lon: NSString = point.css("LongitudeDegrees").text!
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      
      let type: String = point.css("PointType").text!
      var color: UIColor = UIColor.purpleColor()
      
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
      
      result.append(GTPin(title: name, coordinate: location, color: color))
    }
    
    return result
  }
  
  class func lines(xml: XMLDocument) -> [Line] {
    var locations: [CLLocationCoordinate2D] = []
    
    for point in xml.css("Trackpoint") {
      let lat: NSString = point.css("LatitudeDegrees").text!
      let lon: NSString = point.css("LongitudeDegrees").text!
      
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      locations.append(location)
    }
    
    var result: [Line] = []
    if locations.count > 0 {
      result.append(Line(coordinates: &locations, color: UIColor.blueColor(), lineWidth: 3))
    }
    return result
  }
}