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
        Text(item.fullName).onTapGesture {
          self.mapViewModel.selectedFile = item
          self.dismiss()
        }
        Button {
          self.mapViewModel.selectedFile = item
          self.dismiss()
        } label: {
          Text(item.name)
        }
      }
      .toolbar(content: {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { self.dismiss() }, label: {
            Text("Close")
          })
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { self.refresh() }, label: {
            Image(systemName: "arrow.triangle.2.circlepath")
          })
        }
      })
      .navigationTitle("Select")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear { self.didAppear() }
    }
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

struct FileListView_Previews: PreviewProvider {
  static var previews: some View {
    FileListView()
  }
}
