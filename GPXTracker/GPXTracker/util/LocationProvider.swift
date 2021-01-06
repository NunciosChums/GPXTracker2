//
//  LocationProvider.swift
//  GPXTracker
//
//  Created by 진창훈 on 2021/01/06.
//  Copyright © 2021 susemi99. All rights reserved.
//

import CoreLocation

class LocationProvider: NSObject, CLLocationManagerDelegate {
  static let shared = LocationProvider()
  private let manager = CLLocationManager()

  func request() {
    manager.delegate = self
    manager.requestWhenInUseAuthorization()
  }

  func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
//    if status == .authorizedWhenInUse {
//      manager.startUpdatingLocation()
//    }
  }
}
