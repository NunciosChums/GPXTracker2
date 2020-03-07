//
//  ContentView.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/03/07.
//  Copyright © 2020 susemi99. All rights reserved.
//

import PKHUD
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Button(action: { HUD.flash(.progress, delay: 10) }, label: { Text("aa") })
      Text("Hello, World!")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
