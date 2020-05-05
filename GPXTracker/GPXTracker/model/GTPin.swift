//
//  GTPin.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/05/05.
//  Copyright © 2020 susemi99. All rights reserved.
//

import Foundation
import MapKit

class GTPin: NSObject, MKAnnotation {
  let identifier = String(arc4random())
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let color: UIColor
  var iconUrl: String?

  init(title: String, coordinate: CLLocationCoordinate2D, color: UIColor = MKPinAnnotationView.purplePinColor()) {
    self.title = title
    self.coordinate = coordinate
    self.color = color
    iconUrl = nil
  }

  init(title: String, coordinate: CLLocationCoordinate2D, iconUrl: String = "") {
    self.title = title
    self.coordinate = coordinate
    color = MKPinAnnotationView.purplePinColor()
    self.iconUrl = iconUrl.count == 0 ? nil : iconUrl
  }
}
