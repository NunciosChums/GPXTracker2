//
//  Parser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import SWXMLHash

class Parser {
  let path: NSURL
  let xml: XMLIndexer?
//  let places: [GTPin] = []
  let lines: [Line] = []
  
  init(path: NSURL) {
    self.path = path
    self.xml = SWXMLHash.parse(try! String(contentsOfFile: path.path!, encoding: NSUTF8StringEncoding))
  }
  
  func title() -> String {
    if self.xml == nil {
      return (self.path.URLByDeletingPathExtension?.lastPathComponent)!
    }
    
    if isKML() {
      return KMLParser.title(self.xml!)
    }
    else {
      return (self.path.URLByDeletingPathExtension?.lastPathComponent)!
    }
  }
  
  func places() -> [GTPin]? {
    if isGPX() {
      return GPXParser.places(self.xml!)
    }
    return nil
  }
  
  func isGPX() -> Bool {
    return self.path.pathExtension?.lowercaseString == "gpx"
  }
  
  func isTCX() -> Bool {
    return self.path.pathExtension?.lowercaseString == "tcx"
  }
  
  func isKML() -> Bool {
    return self.path.pathExtension?.lowercaseString == "kml"
  }
}