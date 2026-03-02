import SwiftUI

@main
struct GPXTrackerApp: App {
  @State private var appState = AppState()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(appState)
        .onOpenURL { url in
          appState.openFileFromURL(url)
        }
    }
  }
}
