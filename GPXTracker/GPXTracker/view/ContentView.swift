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
          fileListToolbarItem
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
              Button("Refresh", systemImage: "arrow.clockwise") {
                appState.loadFiles()
              }
            }
            ToolbarItem(placement: .topBarTrailing) {
              // 텍스트 버튼은 세로 바로 이동하지 못하므로 시스템 닫기 버튼(심볼)을 사용
              if #available(iOS 26.0, *) {
                Button(role: .close) { showFileList = false }
              } else {
                Button("Done") { showFileList = false }
              }
            }
          }
      }
    }
    .onAppear {
      appState.loadFiles()
    }
  }

  @ToolbarContentBuilder
  private var fileListToolbarItem: some ToolbarContent {
    // 제목+심볼을 함께 제공해야 아이폰 듀오의 세로 바/오버플로 메뉴에서 시스템이 알맞게 표시함
    let item = ToolbarItem(placement: .topBarLeading) {
      Button("Files", systemImage: "list.bullet") {
        showFileList = true
      }
    }
    if #available(iOS 27.0, *) {
      // 앱의 주 진입점이므로 공간이 부족해도 가장 늦게 오버플로되도록 함
      item.visibilityPriority(.high)
    } else {
      item
    }
  }
}
