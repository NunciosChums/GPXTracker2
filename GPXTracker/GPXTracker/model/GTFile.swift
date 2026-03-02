import Foundation
import Zip

final class GTFile: Sendable {
  private let unzipFolderName = "unzip"
  private let kmzDocKml = "doc.kml"

  /// file:///xxx/yyy/Document/aaa.kmz
  let path: URL

  /// aaa
  let name: String

  /// kmz
  let fileExtension: String

  /// aaa.kmz
  let fullName: String

  /// /xxx/yyy/Document/
  let documentFolderPath: String

  /// /xxx/yyy/Document/unzip/zzzz
  let unzippedFolderPath: String

  /// /xxx/yyy/Document/unzip/aaa/doc.kml
  let xmlFileFullPath: String

  init(file: URL) {
    path = file
    name = path.deletingPathExtension().lastPathComponent
    fileExtension = path.pathExtension
    fullName = path.lastPathComponent

    let documentsFolder = FileManager.default.documentDirectory
    let downloadedFileFullPath = "\(documentsFolder.path)/\(fullName)"

    if path.deletingLastPathComponent().path.hasSuffix("/Inbox") {
      documentFolderPath = path.deletingLastPathComponent().deletingLastPathComponent().path
    } else if FileManager.default.isUbiquitousItem(at: path) {
      _ = path.startAccessingSecurityScopedResource()

      do {
        try FileManager.default.startDownloadingUbiquitousItem(at: path)
        if FileManager.default.fileExists(atPath: path.path) {
          try FileManager.default.copyItem(atPath: path.path, toPath: downloadedFileFullPath)
        }
      } catch {}

      documentFolderPath = documentsFolder.path
    } else if FileManager.default.fileExists(atPath: downloadedFileFullPath) {
      documentFolderPath = documentsFolder.path
    } else {
      documentFolderPath = path.deletingLastPathComponent().path
    }

    let unzipFolder = "unzip"
    if file.pathExtension.lowercased() == "kmz" {
      unzippedFolderPath = "\(documentFolderPath)/\(unzipFolder)/\(name.hashValue)"
      xmlFileFullPath = "\(unzippedFolderPath)/doc.kml"

      if !FileManager.default.fileExists(atPath: xmlFileFullPath) {
        GTFile.performUnzip(
          path: path,
          documentFolderPath: documentFolderPath,
          name: name,
          unzippedFolderPath: "\(documentFolderPath)/\(unzipFolder)/\(name.hashValue)"
        )
      }
    } else {
      unzippedFolderPath = ""

      if FileManager.default.isUbiquitousItem(at: path) {
        xmlFileFullPath = "\(documentFolderPath)/\(fullName)"
        path.stopAccessingSecurityScopedResource()
      } else if FileManager.default.fileExists(atPath: downloadedFileFullPath) {
        xmlFileFullPath = "\(documentFolderPath)/\(fullName)"
      } else {
        xmlFileFullPath = path.path
      }
    }
  }

  private static func performUnzip(path: URL, documentFolderPath: String, name: String, unzippedFolderPath: String) {
    let tempFileFullPath = "\(documentFolderPath)/\(name.hashValue).zip"
    let tempFileUrl = URL(fileURLWithPath: tempFileFullPath)
    do {
      try FileManager.default.copyItem(atPath: path.path, toPath: tempFileFullPath)
      try Zip.unzipFile(tempFileUrl,
                        destination: URL(fileURLWithPath: unzippedFolderPath),
                        overwrite: true, password: nil)
      try FileManager.default.removeItem(at: tempFileUrl)
    } catch {
      log.warning("unzip failed: \(error.localizedDescription)")
    }
  }

  func imageFolderPath() -> String {
    return "file://\(unzippedFolderPath)/"
  }

  func isKML() -> Bool { fileExtension.lowercased() == "kml" }
  func isGPX() -> Bool { fileExtension.lowercased() == "gpx" }
  func isTCX() -> Bool { fileExtension.lowercased() == "tcx" }
  func isKMZ() -> Bool { fileExtension.lowercased() == "kmz" }
}
