//
//  GTFile.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/05/05.
//  Copyright © 2020 susemi99. All rights reserved.
//

import CoreLocation
import Foundation
import Zip

class GTFile: Identifiable {
  private let KMZ_DOC_KML = "doc.kml"

  let id = UUID().uuidString

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

  /// /xxx/yyy/Document/unzip/
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
    } else if FileManager.default.isUbiquitousItem(at: path) || !FileManager.default.fileExists(atPath: downloadedFileFullPath) {
      // file in iCloud Document and not downloaded
      _ = path.startAccessingSecurityScopedResource()

      do {
        try FileManager.default.startDownloadingUbiquitousItem(at: path)

        var isDownloaded = false
        while !isDownloaded {
          isDownloaded = FileManager.default.fileExists(atPath: path.path)
        }

        try FileManager.default.copyItem(atPath: path.path, toPath: downloadedFileFullPath)
      } catch {}

      documentFolderPath = documentsFolder.path
    } else if FileManager.default.fileExists(atPath: downloadedFileFullPath) { // file in iCloud Document but downloaded
      documentFolderPath = documentsFolder.path
    } else {
      documentFolderPath = path.deletingLastPathComponent().path
    }

    if file.pathExtension.lowercased() == "kmz" {
      unzippedFolderPath = "\(documentFolderPath)/\(UNZIP_FOLER_NAME)/\(name.hashValue)"
      xmlFileFullPath = "\(unzippedFolderPath)/\(KMZ_DOC_KML)"

      if !isUnzipped {
        unzip()
      }
    } else {
      unzippedFolderPath = "" // not use

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

  func unzip() {
    let tempFile = "\(documentFolderPath)/\(name.hashValue)"
    let tempFileFullPath = "\(tempFile).zip"
    let tempFileUrl = URL(fileURLWithPath: tempFileFullPath)
    do {
      try FileManager.default.copyItem(atPath: path.path, toPath: tempFileFullPath)
      try Zip.unzipFile(tempFileUrl,
                        destination: URL(fileURLWithPath: unzippedFolderPath),
                        overwrite: true, password: nil)

      try FileManager.default.removeItem(at: tempFileUrl)
    } catch {
      log.warning(error)
    }
  }

  var isUnzipped: Bool { FileManager.default.fileExists(atPath: xmlFileFullPath) }

  var imageFolderPath: String { "file://\(unzippedFolderPath)/" }

  var isKML: Bool { fileExtension.lowercased() == "kml" }

  var isGPX: Bool { fileExtension.lowercased() == "gpx" }

  var isTCX: Bool { fileExtension.lowercased() == "tcx" }

  var isKMZ: Bool { fileExtension.lowercased() == "kmz" }
}
