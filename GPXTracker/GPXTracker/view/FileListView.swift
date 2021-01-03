//
//  FileListView.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/05/10.
//  Copyright © 2020 susemi99. All rights reserved.
//

import SwiftUI

struct FileListView: View {
  @EnvironmentObject var mapViewModel: MapViewModel
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State private var items = [GTFile]()

  var body: some View {
    NavigationView {
      List(items) { item in
        Button {
          self.mapViewModel.selectedFile = item
          self.dismiss()
        } label: {
          VStack(alignment: .leading) {
            Text(item.name).font(.title2)
            Text(item.fullName).font(.subheadline)
          }
        }
      }
      .listStyle(PlainListStyle())
      .navigationBarItems(leading: Button(action: { self.dismiss() }, label: {
        Text("Close")
      }), trailing: Button(action: { self.refresh() }, label: {
        Image(systemName: "arrow.triangle.2.circlepath")
      }))
      .navigationTitle("Select")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear { self.didAppear() }
    }.frame(idealWidth: 50, idealHeight: 500)
  }

  func didAppear() {
    refresh()
  }

  func refresh() {
    items = FileManager.default.files()
  }

  func dismiss() {
    presentationMode.wrappedValue.dismiss()
  }
}
