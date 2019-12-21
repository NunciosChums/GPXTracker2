import Foundation
import Zip

class GTFile {
  private let KMZ_DOC_KML = "doc.kml"
  
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
    
    let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let downloadedFileFullPath = "\(documentsFolder.path)/\(fullName)"
    
    if path.deletingLastPathComponent().path.hasSuffix("/Inbox") {
      documentFolderPath = path.deletingLastPathComponent().deletingLastPathComponent().path
    }
    else if FileManager.default.isUbiquitousItem(at: path) || !FileManager.default.fileExists(atPath: downloadedFileFullPath) {
      // file in iCloud Document and not downloaded
      _ = path.startAccessingSecurityScopedResource()
      
      do {
        try FileManager.default.startDownloadingUbiquitousItem(at: path)

        var isDownloaded = false
        while !isDownloaded {
          if FileManager.default.fileExists(atPath: path.path) {
            isDownloaded = true
          }
        }
      
        try FileManager.default.copyItem(atPath: path.path, toPath: downloadedFileFullPath)
      } catch {}

      documentFolderPath = documentsFolder.path
    }
    else if FileManager.default.fileExists(atPath: downloadedFileFullPath) { // file in iCloud Document but downloaded
      documentFolderPath = documentsFolder.path
    }
    else {
      documentFolderPath = path.deletingLastPathComponent().path
    }
    
    if file.pathExtension.lowercased() == "kmz" {
      unzippedFolderPath = "\(documentFolderPath)/\(UNZIP_FOLER_NAME)/\(name.hashValue)"
      xmlFileFullPath = "\(unzippedFolderPath)/\(KMZ_DOC_KML)"
      
      if(!isUnzipped()) {
        unzip()
      }
    }
    else {
      unzippedFolderPath = "" // not use
      
      if FileManager.default.isUbiquitousItem(at: path) {
        xmlFileFullPath = "\(documentFolderPath)/\(fullName)"
        path.stopAccessingSecurityScopedResource()
      }
      else if FileManager.default.fileExists(atPath: downloadedFileFullPath) {
        xmlFileFullPath = "\(documentFolderPath)/\(fullName)"
      }
      else {
        xmlFileFullPath = path.path
      }
    }
  }
  
  func isUnzipped() -> Bool {
    return FileManager.default.fileExists(atPath: xmlFileFullPath)
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
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  func imageFolderPath() -> String {
    return "file://\(unzippedFolderPath)/"
  }
  
  func isKML() -> Bool {
    return fileExtension.lowercased() == "kml"
  }
  
  func isGPX() -> Bool {
    return fileExtension.lowercased() == "gpx"
  }
  
  func isTCX() -> Bool {
    return fileExtension.lowercased() == "tcx"
  }
  
  func isKMZ() -> Bool {
    return fileExtension.lowercased() == "kmz"
  }
}
