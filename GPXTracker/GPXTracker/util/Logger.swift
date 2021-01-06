//
//  Logger.swift
//  GPXTracker
//
//  Created by 진창훈 on 2021/01/06.
//  Copyright © 2021 susemi99. All rights reserved.
//

import XCGLogger

// MARK: - 콘솔 로그

let log: XCGLogger = {
  /// verbose, debug, info, info, warning, error, severe
  let log = XCGLogger.default
  log.levelDescriptions = [
    XCGLogger.Level.verbose: "💜 Verbose",
    XCGLogger.Level.debug: "💙 Debug",
    XCGLogger.Level.info: "💚 Info",
    XCGLogger.Level.warning: "💛 Warning",
    XCGLogger.Level.error: "💔 Error",
    XCGLogger.Level.severe: "💔💔 Servere",
    XCGLogger.Level.none: "None",
  ]
  #if DEBUG
    log.setup(level: .verbose, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .severe)
  #else
    log.setup(level: .severe, showThreadName: false, showLevel: true, showFileNames: false, showLineNumbers: false, writeToFile: nil, fileLevel: .severe)
  #endif
  return log
}()
