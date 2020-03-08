//
//  MapViewModel.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/08.
//  Copyright © 2020 susemi99. All rights reserved.
//

import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
  /// 유저 위치 추적 모드
  @Published var userTrackingMode: MKUserTrackingMode = .follow

  /// 지도 종류
  @Published var mapType: MKMapType = UserDefaults.mapType {
    willSet {
      UserDefaults.mapType = newValue
    }
  }

  @Published var hasLocations = false
}
