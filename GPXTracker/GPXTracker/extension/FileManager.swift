//
//  FileManager.swift
//  GPXTracker
//
//  Created by 진창훈 on 2021/01/06.
//  Copyright © 2021 susemi99. All rights reserved.
//

import Foundation

extension FileManager {
  /// document directory 경로
  var documentDirectory: URL {
    urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  /// 번들에 있던 파일을 실제 사용하는 폴더로 이동
  func copyBundleToDocumentDirectory() {
    guard let path = Bundle.main.resourcePath else { return }

    let sourceFolder = path + "/samples"
    try? contentsOfDirectory(atPath: sourceFolder).forEach {
      let destination = documentDirectory.path + "/" + $0
      guard !fileExists(atPath: destination) else { return }
      try? copyItem(atPath: "\(sourceFolder)/\($0)", toPath: destination)
    }
  }

  /// 목록에 표시할 파일 목록
  func files() -> [GTFile] {
    var result = files(in: documentDirectory)

    // received from iCloud Drive
    result.append(contentsOf: files(in: NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)))

    return result.sorted { $0.name.lowercased() < $1.name.lowercased() }
  }

  /// 폴더 안의 파일 목록 가져오기
  /// - Parameter directory: folder path
  func files(in directory: URL) -> [GTFile] {
    var result = [GTFile]()

    if directory.absoluteString.contains(UNZIP_FOLDER_NAME) {
      return result
    }

    let contents = (try? contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []

    contents.forEach {
      if $0.hasDirectoryPath {
        result += files(in: $0)
      } else if ["kml", "kmz", "gpx", "tcx"].contains($0.pathExtension) {
        result.append(GTFile(file: $0))
      }
    }

    return result
  }

  /// 파일 삭제
  /// - Parameter file: GTFile
  func delete(file: GTFile) {
    do {
      try removeItem(at: file.path)

      if fileExists(atPath: file.unzippedFolderPath) {
        try removeItem(atPath: file.unzippedFolderPath)
      }
    } catch {
      log.warning(error.localizedDescription)
    }
  }
}
