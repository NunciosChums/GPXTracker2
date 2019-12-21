import Foundation

class FileController {
  static func copyBundleToFolder() {
    guard let path = Bundle.main.resourcePath else { return }
    let sourceFolder = path + "/samples"
    let files = try! FileManager.default.contentsOfDirectory(atPath: sourceFolder)
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    do {
      for file in files {
        try FileManager.default.copyItem(atPath: "\(sourceFolder)/\(file)", toPath: "\(documentDirectory.path)/\(file)")
      }
    } catch {
      print(error.localizedDescription)
    }
  }

  static func files() -> [GTFile] {
    var result: [GTFile] = []

    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    result.append(contentsOf: addFilesInDirectory(path: documentDirectory))

    // received from iCloud Drive
    let temporaryDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    result.append(contentsOf: addFilesInDirectory(path: temporaryDirectory))

    return result.sorted { $0.name.lowercased() < $1.name.lowercased() }
  }

  /// 폴더 안의 파일 목록 가져오기
  /// - Parameter path: folder path
  static func addFilesInDirectory(path: URL) -> [GTFile] {
    var result: [GTFile] = []

    if path.absoluteString.contains(UNZIP_FOLER_NAME) {
      return result
    }

    do {
      let contentsOfDirectory = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)

      // 폴더 안의 파일 가져오기
      _ = contentsOfDirectory
        .filter { $0.hasDirectoryPath }
        .map { result += addFilesInDirectory(path: $0) }

      // 파싱 가능한 파일이면 목록에 표시하기
      _ = contentsOfDirectory
        .filter { !$0.hasDirectoryPath }
        .filter { ["kml", "kmz", "gpx", "tcx"].contains($0.pathExtension) }
        .map { GTFile(file: $0) }
        .map { result.append($0) }
    } catch {
      print(error.localizedDescription)
    }

    return result
  }

  /// 파일 삭제
  /// - Parameter file: GTFile
  static func delete(file: GTFile) {
    do {
      try FileManager.default.removeItem(at: file.path)

      if !file.unzippedFolderPath.isEmpty {
        try FileManager.default.removeItem(atPath: file.unzippedFolderPath)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}
