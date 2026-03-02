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

  override init() {
    super.init()
    manager.delegate = self
  }

  func request() {
    manager.requestWhenInUseAuthorization()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
  }
}
