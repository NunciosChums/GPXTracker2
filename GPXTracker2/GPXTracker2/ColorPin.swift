//
//  StartPointPin.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 10. 3..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit

class ColorPin: NSObject, MKAnnotation {
  let identifier: String
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let color: UIColor
  
  init(title: String, coordinate: CLLocationCoordinate2D, color: UIColor){
    self.identifier = String(random())
    self.title = title
    self.coordinate = coordinate
    self.color = color
  }
}