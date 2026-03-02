import SwiftUI

struct ContentView: View {
  @Environment(AppState.self) private var appState
  @State private var showFileList = false

  var body: some View {
    NavigationStack {
      MapContentView()
        .navigationTitle(appState.mapTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              showFileList = true
            } label: {
              Image(systemName: "list.bullet")
            }
          }
          if let shareURL = appState.filePathForShare {
            ToolbarItem(placement: .topBarTrailing) {
              ShareLink(item: shareURL)
            }
          }
        }
    }
    .sheet(isPresented: $showFileList) {
      NavigationStack {
        FileListView()
          .navigationTitle("Files")
          .toolbar {
            ToolbarItem(placement: .topBarLeading) {
              Button {
                appState.loadFiles()
              } label: {
                Image(systemName: "arrow.clockwise")
              }
            }
            ToolbarItem(placement: .topBarTrailing) {
              Button("Done") { showFileList = false }
            }
          }
      }
    }
    .onAppear {
      appState.loadFiles()
    }
  }
}
