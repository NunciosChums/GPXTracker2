//
//  TCXParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import SWXMLHash
import MapKit

class TCXParser {
  
  class func title(xml:XMLIndexer) -> String {
    let result = xml["TrainingCenterDatabase"]["Courses"]["Course"]["Name"].element?.text
    return result ?? ""
  }
  
  class func places(xml: XMLIndexer) -> [GTPin] {
    var result: [GTPin] = []
    
    let coursePoints = xml["TrainingCenterDatabase"]["Courses"]["Course"]["CoursePoint"]
    for point in coursePoints {
      let name: String = (point["Name"].element?.text)!
      let lat: NSString = (point["Position"]["LatitudeDegrees"].element?.text)!
      let lon: NSString = (point["Position"]["LongitudeDegrees"].element?.text)!
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      
      let type: String = (point["PointType"].element?.text)!
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
  
  class func lines(xml: XMLIndexer) -> [Line] {
    var locations: [CLLocationCoordinate2D] = []
    let trackPoints = xml["TrainingCenterDatabase"]["Courses"]["Course"]["Track"]["Trackpoint"]
    for point in trackPoints {
      let lat: NSString = (point["Position"]["LatitudeDegrees"].element?.text)!
      let lon: NSString = (point["Position"]["LongitudeDegrees"].element?.text)!
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      locations.append(location)
    }
    
    var result: [Line] = []
    
    result.append(Line(coordinates: locations, color: UIColor.blueColor(), lineWidth: 3))
    
    return result
  }
}