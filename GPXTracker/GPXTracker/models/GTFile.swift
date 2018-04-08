import Foundation
import Zip

class GTFile {
  private let KMZ_DOC_KML = "doc.kml"
  
  let path: URL // file:///xxx/yyy/Document/aaa.kmz
  let name: String // aaa
  let fileExtension: String // kmz
  let fullName: String // aaa.kmz
  let documentFolderPath: String // /xxx/yyy/Document/
  let unzippedFolderPath: String // /xxx/yyy/Document/unzip/
  let xmlFileFullPath: String // /xxx/yyy/Document/unzip/aaa/doc.kml
  
  init(file: URL) {
    path = file
    name = path.deletingPathExtension().lastPathComponent
    fileExtension = path.pathExtension
    fullName = path.lastPathComponent
    
    if path.deletingLastPathComponent().path.hasSuffix("/Inbox") {
      documentFolderPath = path.deletingLastPathComponent().deletingLastPathComponent().path
    }
    else {
      documentFolderPath = path.deletingLastPathComponent().path
    }
    
    if file.pathExtension.lowercased() == "kmz" {
      unzippedFolderPath = "\(documentFolderPath)/\(UNZIP_FOLER_NAME)/\(name)"
      xmlFileFullPath = "\(unzippedFolderPath)/\(KMZ_DOC_KML)"
      
      if(!isUnzipped()) {
        unzip()
      }
    }
    else {
      unzippedFolderPath = "" // not use
      xmlFileFullPath = path.path
    }
  }
  
  func isUnzipped() -> Bool {
    return FileManager().fileExists(atPath: xmlFileFullPath)
  }
  
  func unzip() {
    let tempFile = "\(documentFolderPath)/\(name)"
    let tempFileFullPath = "\(tempFile).zip"
    let tempFileUrl = URL(fileURLWithPath: tempFileFullPath)
    do {
      try FileManager().copyItem(atPath: path.path, toPath: tempFileFullPath)
      try Zip.unzipFile(tempFileUrl,
                        destination: URL(fileURLWithPath: unzippedFolderPath),
                        overwrite: true, password: nil)
      
      try FileManager().removeItem(at: tempFileUrl)
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
