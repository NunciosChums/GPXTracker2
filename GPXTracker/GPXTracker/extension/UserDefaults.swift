//
//  UserDefaults.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/08.
//  Copyright © 2020 susemi99. All rights reserved.
//

import MapKit
import SwiftUI

extension UserDefaults {
  private struct Keys {
    static let isFirstRun = "isFirstRun"
    static let MapType = "MapType"
  }

  /// 최초 실행인가?
  static var isFirstRun: Bool {
    get { return standard.bool(forKey: Keys.isFirstRun) }
    set { standard.set(newValue, forKey: Keys.isFirstRun) }
  }

  /// 지도 종류(기본, 위성)
  static var mapType: MKMapType {
    get {
      let type = MKMapType.standard
      return MKMapType(rawValue: MKMapType.RawValue(standard.integer(forKey: Keys.MapType))) ?? type
    }
    set { standard.set(newValue.rawValue, forKey: Keys.MapType) }
  }
}
