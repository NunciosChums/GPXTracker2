//
//  LocationProvider.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/08.
//  Copyright © 2020 susemi99. All rights reserved.
//

import CoreLocation

class LocationProvider: NSObject, CLLocationManagerDelegate {
  static let shared = LocationProvider()
  private let manager = CLLocationManager()

  func request() {
    manager.delegate = self
    manager.requestWhenInUseAuthorization()
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//    if status == .authorizedWhenInUse {
//      manager.startUpdatingLocation()
//    }
  }
}
