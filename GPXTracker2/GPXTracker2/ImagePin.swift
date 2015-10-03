//
//  ImageLocatonPin.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 10. 3..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import MapKit

class ImagePin: ColorPin {
  let url: String
  
  init(title: String, coordinate: CLLocationCoordinate2D, url: String){
    self.url = url
    super.init(title: title, coordinate: coordinate, color: UIColor.purpleColor())
  }
}