//
//  UserDefaults.swift
//  GPXTracker
//
//  Created by 진창훈 on 2021/01/06.
//  Copyright © 2021 susemi99. All rights reserved.
//

import MapKit

extension UserDefaults {
  private enum Keys {
    static let IS_FIRST_RUN = "is_first_run_v2"
    static let MAP_TYPE = "map_type_v2"
  }

  /// 최초 실행인가?
  static var isFirstRun: Bool {
    get { return standard.bool(forKey: Keys.IS_FIRST_RUN) }
    set { standard.set(newValue, forKey: Keys.IS_FIRST_RUN) }
  }

  /// 지도 종류(기본, 위성)
  static var mapType: MKMapType {
    get {
      let type = MKMapType.standard
      return MKMapType(rawValue: MKMapType.RawValue(standard.integer(forKey: Keys.MAP_TYPE))) ?? type
    }
    set {
      standard.set(newValue.rawValue, forKey: Keys.MAP_TYPE)
    }
  }
}
