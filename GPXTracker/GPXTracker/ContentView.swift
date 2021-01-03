//
//  ContentView.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/07.
//  Copyright © 2020 susemi99. All rights reserved.
//

import Combine
import KRProgressHUD
import MapKit
import SwiftUI

struct ContentView: View {
  @EnvironmentObject var mapViewModel: MapViewModel
  @State private var cancellable = Set<AnyCancellable>()
  @State private var showFileListView = false

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        MapView().edgesIgnoringSafeArea(.bottom)
          .gesture(DragGesture().onChanged { _ in self.mapViewModel.userTrackingMode = .none })
          .gesture(RotationGesture().onChanged { _ in self.didRotateMapView() })

        HStack {
          Button(action: {}) { Image(systemName: "mappin.circle.fill").resizable()
            .frame(width: 30, height: 30).foregroundColor(.green)
          }.padding(.trailing, 3).disabled(!mapViewModel.hasLocations)

          Button(action: {}) { Image(systemName: "mappin.circle.fill").resizable()
            .frame(width: 30, height: 30).foregroundColor(.red)
          }.padding(.trailing, 3).disabled(!mapViewModel.hasLocations)

          Button(action: {}) { Image(systemName: "scribble").resizable()
            .frame(width: 30, height: 30).foregroundColor(.blue)
          }.padding(.trailing, 3).disabled(!mapViewModel.hasLocations)

          if mapViewModel.mapType == .hybrid {
            Button(action: { self.changeTapMapType(.standard) }) {
              Image(systemName: "map.fill").resizable()
                .frame(width: 30, height: 30).foregroundColor(.white)
            }.padding(.trailing, 3)
          } else {
            Button(action: { self.changeTapMapType(.hybrid) }) {
              Image(systemName: "map.fill").resizable()
                .frame(width: 30, height: 30).foregroundColor(.black)
            }.padding(.trailing, 3)
          }
        }.padding(.bottom, 30).padding(.trailing, 10)
      }
      .navigationBarTitle("Map")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(leading:
        HStack(spacing: 20) {
          Button(action: { self.showFileListView.toggle() },
                 label: { Image(systemName: "folder").resizable().scaledToFit().padding(7) })
            .frame(width: 40, height: 40, alignment: .center)
            .popover(isPresented: self.$showFileListView, content: { FileListView().environmentObject(self.mapViewModel) })

          Button(action: {},
                 label: { Image(systemName: "square.and.arrow.up").resizable().scaledToFit().padding(7) })
            .frame(width: 40, height: 40, alignment: .center)
        }, trailing:
        Button(action: { self.didTapUserTrackingButton() }) {
          if mapViewModel.userTrackingMode == .none {
            Image(systemName: "location")
          } else if mapViewModel.userTrackingMode == .followWithHeading {
            Image(systemName: "location.north.line.fill").foregroundColor(.white)
          } else {
            Image(systemName: "location.fill").foregroundColor(.white)
          }
        }
        .frame(width: 40, height: 40, alignment: .center)
        .background(mapViewModel.userTrackingMode == .none ? Color.white.opacity(0) : Color.blue)
        .cornerRadius(5))
    }.navigationViewStyle(StackNavigationViewStyle())
      .onAppear { self.didAppear() }
  }

  func didAppear() {
    LocationProvider.shared.request()
    changeTapMapType(mapViewModel.mapType)

    if !UserDefaults.isFirstRun {
      FileManager.default.copyBundleToDocumentDirectory()
      UserDefaults.isFirstRun = true
    }

    mapViewModel.$selectedFile
      .sink {
        log.info($0?.path ?? "")
      }
      .store(in: &cancellable)
  }

  func didTapUserTrackingButton() {
    switch mapViewModel.userTrackingMode {
    case .follow:
      mapViewModel.userTrackingMode = .followWithHeading

    case .followWithHeading:
      mapViewModel.userTrackingMode = .none

    default:
      mapViewModel.userTrackingMode = .follow
    }
  }

  func didRotateMapView() {
    if mapViewModel.userTrackingMode == .followWithHeading {
      mapViewModel.userTrackingMode = .follow
    }
  }

  func changeTapMapType(_ type: MKMapType) {
    mapViewModel.mapType = type
  }
}
