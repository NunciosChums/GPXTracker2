//
//  MapView.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/07.
//  Copyright © 2020 susemi99. All rights reserved.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  func makeUIView(context _: Context) -> MKMapView {
    let view = MKMapView(frame: .zero)
    view.showsUserLocation = true
    return view
  }

  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {}
}
