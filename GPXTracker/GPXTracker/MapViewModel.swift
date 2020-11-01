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

  /// 선택된 경로가 있는가?
  @Published var hasLocations = false

  /// 선택된 파일
  @Published var selectedFile: GTFile?
  
  @Published var locations: [CLLocation]?
}
