//
//  GTPolyLine.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 10. 17..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit

class GTPolyLine: MKPolyline {
  var strokeColor: UIColor
  var lineWidth: Float
  
  override init() {
    self.strokeColor = UIColor.blue
    self.lineWidth = 3;
  }
  
  func set(_ color: UIColor, width: Float = 3) {
    self.strokeColor = color
    self.lineWidth = width
  }
}
