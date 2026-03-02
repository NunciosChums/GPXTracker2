import SwiftUI

struct FileListView: View {
  @Environment(AppState.self) private var appState
  @Environment(\.dismiss) private var dismiss
  var body: some View {
    List {
      ForEach(appState.files, id: \.path) { file in
        Button {
          appState.selectFile(file)
          dismiss()
        } label: {
          Text(file.fullName)
            .foregroundStyle(.primary)
        }
      }
      .onDelete { offsets in
        for index in offsets {
          appState.deleteFile(appState.files[index])
        }
      }
    }
    .overlay {
      if appState.isLoadingFiles {
        ProgressView()
          .padding()
          .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
      } else if appState.files.isEmpty {
        ContentUnavailableView(
          "No Files",
          systemImage: "doc.slash",
          description: Text("Add GPX, KML, KMZ, or TCX files via Files app or AirDrop.")
        )
      }
    }
    .refreshable {
      appState.loadFiles()
    }
  }
}
