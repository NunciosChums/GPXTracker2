//
//  GPXParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import SWXMLHash
import MapKit

class GPXParser {
  
  class func places(xml: XMLIndexer) -> [GTPin] {
    var result: [GTPin] = []
    
    let wpts = xml["gpx"]["wpt"]
    for wpt in wpts {
      let lon: NSString = (wpt.element?.attributes["lon"])!
      let lat: NSString = (wpt.element?.attributes["lat"])!
      let name: String = (wpt["name"].element?.text)!
      
      print(lon.doubleValue)
      print(lat.doubleValue)
      print(name)
      
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      
      result.append(GTPin(title: name, coordinate: location, color: UIColor.purpleColor()))
    }
    
    return result;
  }
}