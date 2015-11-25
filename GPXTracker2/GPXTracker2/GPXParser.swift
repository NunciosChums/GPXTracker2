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
  
  class func title(xml: XMLIndexer) -> String {
    return (xml["gpx"]["trk"]["name"].element?.text)!
  }
  
  class func places(xml: XMLIndexer) -> [GTPin] {
    var result: [GTPin] = []
    
    let wpts = xml["gpx"]["wpt"]
    for wpt in wpts {
      let lon: NSString = (wpt.element?.attributes["lon"])!
      let lat: NSString = (wpt.element?.attributes["lat"])!
      let name: String = (wpt["name"].element?.text)!
      
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      
      result.append(GTPin(title: name, coordinate: location, color: UIColor.purpleColor()))
    }
    
    return result
  }
  
  class func lines(xml: XMLIndexer) -> [Line] {
    var locations: [CLLocationCoordinate2D] = []
    let trkpts = xml["gpx"]["trk"]["trkseg"]["trkpt"]
    for trkpt in trkpts {
      let lon: NSString = (trkpt.element?.attributes["lon"])!
      let lat: NSString = (trkpt.element?.attributes["lat"])!
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      locations.append(location)
    }
    
    var result: [Line] = []

    result.append(Line(coordinates: locations, color: UIColor.blueColor(), lineWidth: 3))
    
    return result
  }
}