//
//  FileManager.swift
//  GPXTracker
//
//  Created by susemi99 on 2020/05/05.
//  Copyright © 2020 susemi99. All rights reserved.
//

import Foundation

extension FileManager {
  /// document directory 경로
  var documentDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  /// 번들에 있던 파일을 실제 사용하는 폴더로 이동
  func copyBundleToDocumentDirectory() {
    guard let path = Bundle.main.resourcePath else { return }

    let sourceFolder = path + "/samples"
    try? FileManager.default.contentsOfDirectory(atPath: sourceFolder).forEach {
      try? FileManager.default.copyItem(atPath: "\(sourceFolder)/\($0)", toPath: "\(documentDirectory.path)/\($0)")
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
  /// - Parameter path: folder path
  func files(in directory: URL) -> [GTFile] {
    var result = [GTFile]()

    if directory.absoluteString.contains(UNZIP_FOLER_NAME) {
      return result
    }

    let contentsOfDirectory = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

    // 폴더 안의 파일 가져오기
    _ = contentsOfDirectory?
      .filter { $0.hasDirectoryPath }
      .map { result += files(in: $0) }

    // 파싱 가능한 파일이면 목록에 표시하기
    _ = contentsOfDirectory?
      .filter { !$0.hasDirectoryPath }
      .filter { ["kml", "kmz", "gpx", "tcx"].contains($0.pathExtension) }
      .map { GTFile(file: $0) }
      .map { result.append($0) }

    return result
  }
}
