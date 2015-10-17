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
  var lineWidth: CGFloat
  
  override init() {
    self.strokeColor = UIColor.blueColor()
    self.lineWidth = 3;
  }
  
  func set(color: UIColor, width: CGFloat) {
    self.strokeColor = color
    self.lineWidth = width
  }
}