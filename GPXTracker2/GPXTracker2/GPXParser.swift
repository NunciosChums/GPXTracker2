//
//  GPXParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit
import Kanna

class GPXParser {
  
  class func title(xml: XMLDocument) -> String {
    guard let result = xml.css("trk name").first?.text else { return  "" }
    return result
  }
  
  class func places(xml: XMLDocument) -> [GTPin] {
    var result: [GTPin] = []
    
    for wpt in xml.css("wpt") {
      guard let lon: NSString = wpt["lon"],
        let lat: NSString = wpt["lat"],
        let name: String = wpt.css("name").first?.text
        else { continue }
      
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      result.append(GTPin(title: name, coordinate: location, color: MKPinAnnotationView.purplePinColor()))
    }
    
    return result
  }
  
  class func lines(xml: XMLDocument) -> [Line] {
    var locations: [CLLocationCoordinate2D] = []
    
    for trkpt in xml.css("trkpt") {
      let lon: NSString = trkpt["lon"]!
      let lat: NSString = trkpt["lat"]!
      let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
      locations.append(location)
    }
    
    var result: [Line] = []
    result.append(Line(coordinates: &locations, color: UIColor.blueColor(), lineWidth: 3))
    return result
  }
}