import SwiftUI

struct ContentView: View {
  @Environment(AppState.self) private var appState
  @State private var showFileList = false
  @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

  var body: some View {
    Group {
      if UIDevice.current.userInterfaceIdiom == .pad {
        iPadLayout
      } else {
        iPhoneLayout
      }
    }
    .onAppear {
      appState.loadFiles()
    }
  }

  // MARK: - iPad: NavigationSplitView

  private var iPadLayout: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      FileListView()
        .navigationTitle("Files")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              appState.loadFiles()
            } label: {
              Image(systemName: "arrow.clockwise")
            }
          }
        }
    } detail: {
      NavigationStack {
        MapContentView()
          .navigationTitle(appState.mapTitle)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            if let shareURL = appState.filePathForShare {
              ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareURL)
              }
            }
          }
      }
    }
  }

  // MARK: - iPhone: Full-screen map + sheet

  private var iPhoneLayout: some View {
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
  }
}
