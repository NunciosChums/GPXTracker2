//
//  Line.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 10. 4..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit

class Line: MKPolyline {
  let coordinates: [CLLocationCoordinate2D]
  let color: UIColor
  let lineWidth: CGFloat
  let startPin: ColorPin
  let endPin: ColorPin

  init(coordinates: [CLLocationCoordinate2D], color: UIColor, lineWidth: CGFloat){
    self.coordinates = coordinates
    self.startPin = ColorPin(title: START, coordinate: coordinates.first!, color: UIColor.greenColor())
    self.endPin = ColorPin(title: END, coordinate: coordinates.last!, color: UIColor.redColor())
    
    self.color = color ?? UIColor.blueColor()
    self.lineWidth = lineWidth ?? 3
  }
}