import Foundation

class FileController {
  static func copyBundleToFolder() {
    guard let path = Bundle.main.resourcePath else { return }
    let sourceFolder = path + "/samples"
    let files = try! FileManager().contentsOfDirectory(atPath: sourceFolder)
    let destinationFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    do {
      for file in files {
        try FileManager().copyItem(atPath: "\(sourceFolder)/\(file)", toPath: "\(destinationFolder)/\(file)")
      }
    } catch let error{
      print(error.localizedDescription)
    }
  }
  
  static func files() -> [GTFile] {
    var result: [GTFile] = []
    
    let documentDirectory =  FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    result.append(contentsOf: addFilesInDirectory(path: documentDirectory))
    
    // received from iCloud Drive
    let temporaryDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    result.append(contentsOf: addFilesInDirectory(path: temporaryDirectory))
    
    return result.sorted {$0.name.lowercased() < $1.name.lowercased()}
  }
  
  static func addFilesInDirectory(path: URL) -> [GTFile] {
    var result: [GTFile] = []
    
    if path.absoluteString.contains(UNZIP_FOLER_NAME) {
      return result
    }
    
    do {
      let contentsOfDirectory = try FileManager().contentsOfDirectory(at: path,
                                                                      includingPropertiesForKeys: nil,
                                                                      options: FileManager.DirectoryEnumerationOptions())
      
      var isDirectory: ObjCBool = false
      for content in contentsOfDirectory {
        if FileManager().fileExists(atPath: content.path, isDirectory:&isDirectory) {
          if isDirectory.boolValue {
            result += addFilesInDirectory(path: content)
          }
          else {
            result.append(GTFile(file: content))
          }
        }
      }
    } catch let error {
      print(error.localizedDescription)
    }
    
    return result
  }
  
  static func delete(file: GTFile) {
    do {
      try FileManager().removeItem(at: file.path)
      
      if !file.unzippedFolderPath.isEmpty {
        try FileManager().removeItem(atPath: file.unzippedFolderPath)
      }
    } catch let error {
      print(error.localizedDescription)
    }
  }
}
