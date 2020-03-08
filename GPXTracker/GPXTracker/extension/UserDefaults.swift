//
//  UserDefaults.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/08.
//  Copyright © 2020 susemi99. All rights reserved.
//

import MapKit
import SwiftUI

@propertyWrapper
struct UserDefault<T> {
  let key: String
  let defaultValue: T

  var wrappedValue: T {
    get {
      return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key)
    }
  }
}

extension UserDefaults {
  private struct Keys {
    static let MapType = "MapType"
  }

  /// 지도 종류
  static var mapType: MKMapType {
    get {
      let type = MKMapType.standard
      return MKMapType(rawValue: MKMapType.RawValue(standard.integer(forKey: Keys.MapType))) ?? type }
    set { standard.set(newValue.rawValue, forKey: Keys.MapType) }
  }
}
