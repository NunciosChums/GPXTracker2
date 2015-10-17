//
//  Line.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 10. 4..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit

class Line {
  let coordinates: [CLLocationCoordinate2D]
  let polyLine: GTPolyLine
  let startPin: ColorPin
  let endPin: ColorPin

  init(var coordinates: [CLLocationCoordinate2D], color: UIColor, lineWidth: CGFloat){
    self.coordinates = coordinates;
    self.polyLine = GTPolyLine(coordinates: &coordinates, count: coordinates.count)
    self.polyLine.strokeColor = color ?? UIColor.blueColor()
    self.polyLine.lineWidth = lineWidth ?? 3
    
    self.startPin = ColorPin(title: START, coordinate: coordinates.first!, color: UIColor.greenColor())
    self.endPin = ColorPin(title: END, coordinate: coordinates.last!, color: UIColor.redColor())
  }
}