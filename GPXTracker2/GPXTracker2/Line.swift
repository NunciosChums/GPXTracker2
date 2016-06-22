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
  let startPin: GTPin
  let endPin: GTPin

  init(inout coordinates: [CLLocationCoordinate2D], color: UIColor, lineWidth: Float = 3){
    self.coordinates = coordinates;
    self.polyLine = GTPolyLine(coordinates: &coordinates, count: coordinates.count)
    self.polyLine.strokeColor = color ?? UIColor.blueColor()
    self.polyLine.lineWidth = lineWidth
    
    self.startPin = GTPin(title: START, coordinate: coordinates.first!, color: MKPinAnnotationView.greenPinColor())
    self.endPin = GTPin(title: END, coordinate: coordinates.last!, color: MKPinAnnotationView.redPinColor())
  }
}