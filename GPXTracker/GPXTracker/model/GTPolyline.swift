//
//  GTPolyline.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/05/05.
//  Copyright © 2020 susemi99. All rights reserved.
//

import Foundation
import MapKit

class GTPolyline: MKPolyline {
  var strokeColor: UIColor
  var lineWidth: CGFloat

  override init() {
    strokeColor = UIColor.blue
    lineWidth = 3
  }

  func set(color: UIColor, width: CGFloat = 3) {
    strokeColor = color
    lineWidth = width
  }
}
