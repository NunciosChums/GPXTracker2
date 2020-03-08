//
//  MapView.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/07.
//  Copyright © 2020 susemi99. All rights reserved.
//

import Combine
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  @EnvironmentObject var mapViewModel: MapViewModel
  @State var coordinator = Coordinator()

  func makeUIView(context _: Context) -> MKMapView {
    let view = MKMapView(frame: .zero)
    view.showsUserLocation = true
    view.showsScale = true
    view.showsCompass = true
    view.showsBuildings = true
    return view
  }

  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    if coordinator.cancellable.isEmpty {
      didAppear(uiView)
    }
  }

  func makeCoordinator() -> MapView.Coordinator {
    return coordinator
  }

  final class Coordinator {
    var cancellable = Set<AnyCancellable>()

    deinit {
      cancellable.removeAll()
    }
  }

  func didAppear(_ mapView: MKMapView) {
    mapViewModel.$userTrackingMode
      .delay(for: .seconds(0.1), scheduler: RunLoop.main)
      .sink { mapView.userTrackingMode = $0 }
      .store(in: &coordinator.cancellable)

    mapViewModel.$mapType
      .delay(for: .seconds(0.1), scheduler: RunLoop.main)
      .sink { mapView.mapType = $0 }
      .store(in: &coordinator.cancellable)
  }
}
