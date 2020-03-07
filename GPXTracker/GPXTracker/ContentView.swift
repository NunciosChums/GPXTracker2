//
//  ContentView.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/07.
//  Copyright © 2020 susemi99. All rights reserved.
//

import MapKit
import PKHUD
import SwiftUI

struct ContentView: View {
  @State var mapView = MapView()

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        mapView.edgesIgnoringSafeArea(.bottom)

        HStack {
          Button(action: {}) { Image(systemName: "mappin.circle.fill").resizable().frame(width: 30, height: 30).foregroundColor(.green) }.padding(.trailing, 3)
          Button(action: {}) { Image(systemName: "mappin.circle.fill").resizable().frame(width: 30, height: 30).foregroundColor(.red) }.padding(.trailing, 3)
          Button(action: {}) { Image(systemName: "scribble").resizable().frame(width: 30, height: 30).foregroundColor(.blue) }.padding(.trailing, 3)
          Button(action: {}) { Image(systemName: "map.fill").resizable().frame(width: 30, height: 30).foregroundColor(.white) }.padding(.trailing, 3)
          Button(action: {}) { Image(systemName: "map.fill").resizable().frame(width: 30, height: 30).foregroundColor(.black) }.padding(.trailing, 3)
        }.padding(.bottom, 30).padding(.trailing, 10)
      }
      .navigationBarTitle("Map", displayMode: .inline)
      .navigationBarItems(
        leading:
        HStack {
          Button(action: {}) { Image(systemName: "folder") }
          Button(action: {}) { Image(systemName: "square.and.arrow.up") }.padding()
        },

        trailing:
        HStack {
          Button(action: {}) {
            Image(systemName: "location.fill")
              .foregroundColor(Color.white)
              .frame(width: 40, height: 40)
          }
          .frame(width: 40, height: 40, alignment: .center)
          .background(Color.blue)
          .cornerRadius(5)
        }
      )
    }.navigationViewStyle(StackNavigationViewStyle())
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
