//
//  GTPin.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 10. 3..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit

class GTPin: NSObject, MKAnnotation {
  let identifier: String
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let color: UIColor
  let iconUrl: String?
  
  init(title: String, coordinate: CLLocationCoordinate2D, color: UIColor = MKPinAnnotationView.purplePinColor()){
    self.identifier = String(random())
    self.title = title
    self.coordinate = coordinate
    self.color = color
    self.iconUrl = nil
  }
  
  init(title: String, coordinate: CLLocationCoordinate2D, iconUrl: String = ""){
    self.identifier = String(random())
    self.title = title
    self.coordinate = coordinate
    self.color = MKPinAnnotationView.purplePinColor()
    self.iconUrl = iconUrl.characters.count == 0 ? nil : iconUrl
  }
}