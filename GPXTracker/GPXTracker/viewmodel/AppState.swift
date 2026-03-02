import CoreLocation
import MapKit
import SwiftUI

@Observable
@MainActor
final class AppState {
  // MARK: - File State
  var files: [GTFile] = []
  var isLoadingFiles = false

  // MARK: - Map Content State
  var mapContent: MapContent = .empty
  var isParsingFile = false
  var mapTitle = ""

  // MARK: - Map UI State
  var isHybridMap: Bool = UserDefaults.isHybridMap
  var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
  var filePathForShare: URL? = nil

  // MARK: - Pin Detail Sheet
  var selectedPin: GTPin? = nil


  // MARK: - Navigation pin cycling
  private var startPinIndex = 0
  private var endPinIndex = 0

  // MARK: - Location permission
  private let locationManager = CLLocationManager()

  init() {
    locationManager.requestWhenInUseAuthorization()
    copyBundleSamplesIfNeeded()
  }

  // MARK: - Map Style

  var mapStyle: MapStyle {
    isHybridMap ? .hybrid : .standard
  }

  func toggleMapStyle() {
    isHybridMap.toggle()
    UserDefaults.isHybridMap = isHybridMap
  }

  // MARK: - File Actions

  func loadFiles() {
    isLoadingFiles = true
    Task.detached {
      let loaded = FileManager.default.files()
      await MainActor.run { [weak self] in
        self?.files = loaded
        self?.isLoadingFiles = false
      }
    }
  }

  func selectFile(_ file: GTFile) {
    filePathForShare = file.path
    parseFile(file)
  }

  func deleteFile(_ file: GTFile) {
    FileManager.default.delete(file: file)
    files.removeAll { $0.path == file.path }
  }

  func openFileFromURL(_ url: URL) {
    let needsSecurityScope = url.startAccessingSecurityScopedResource()
    defer {
      if needsSecurityScope { url.stopAccessingSecurityScopedResource() }
    }

    let documentsFolder = FileManager.default.documentDirectory
    let destinationURL = documentsFolder.appendingPathComponent(url.lastPathComponent)

    if !FileManager.default.fileExists(atPath: destinationURL.path) {
      do {
        try FileManager.default.copyItem(at: url, to: destinationURL)
      } catch {
        log.warning("copy failed: \(error.localizedDescription)")
        selectFile(GTFile(file: url))
        return
      }
    }

    selectFile(GTFile(file: destinationURL))
    loadFiles()
  }

  // MARK: - Map Actions

  func zoomToFit() {
    guard !mapContent.allCoordinates.isEmpty else { return }
    // 매번 극소량 다른 padding을 적용하여 SwiftUI가 항상 값 변경을 감지하도록 함
    let jitter = Double.random(in: -0.0001...0.0001)
    let rect = mapContent.allCoordinates.boundingMapRect.insetBy(factor: -0.15 + jitter)
    withAnimation {
      cameraPosition = .rect(rect)
    }
  }

  func goToNextStartPin() {
    let pins = mapContent.lines.map(\.startPin)
    guard !pins.isEmpty else { return }
    let pin = pins[startPinIndex]
    moveTo(coordinate: pin.coordinate)
    startPinIndex = (startPinIndex + 1) % pins.count
  }

  func goToNextEndPin() {
    let pins = mapContent.lines.map(\.endPin)
    guard !pins.isEmpty else { return }
    let pin = pins[endPinIndex]
    moveTo(coordinate: pin.coordinate)
    endPinIndex = (endPinIndex + 1) % pins.count
  }

  // MARK: - Private

  private func moveTo(coordinate: CLLocationCoordinate2D) {
    guard CLLocationCoordinate2DIsValid(coordinate) else { return }
    let region = MKCoordinateRegion(
      center: coordinate,
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    withAnimation {
      cameraPosition = .region(region)
    }
  }

  private func parseFile(_ file: GTFile) {
    isParsingFile = true
    startPinIndex = 0
    endPinIndex = 0

    Task.detached {
      let parser = ParserController(file: file)
      let title = parser.title() ?? file.name
      let places = parser.places() ?? []
      let lines = parser.lines() ?? []
      let allCoords = lines.flatMap(\.coordinates)

      let content = MapContent(
        title: title,
        lines: lines,
        places: places,
        allCoordinates: allCoords
      )

      await MainActor.run { [weak self] in
        guard let self else { return }
        self.mapContent = content
        self.mapTitle = title
        self.isParsingFile = false
        self.zoomToFit()
      }
    }
  }

  private func copyBundleSamplesIfNeeded() {
    if !UserDefaults.hasLaunchedBefore {
      FileManager.default.copyBundleToDocumentDirectory()
      UserDefaults.hasLaunchedBefore = true
    }
  }
}
