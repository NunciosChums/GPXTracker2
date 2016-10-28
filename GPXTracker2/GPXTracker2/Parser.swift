//
//  Parser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import Kanna

class Parser {
  let path: URL
  let xml: XMLDocument?
  
  init(path: URL) {
    self.path = path
    let data = try? Data(contentsOf: path)
    let datastring = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    let str = datastring!.replacingOccurrences(of: "xmlns", with: "no_xmlns")
    self.xml = Kanna.XML(xml: str, encoding: String.Encoding.utf8)
  }
  
  func title() -> String {
    if self.xml == nil {
      return (self.path.deletingPathExtension().lastPathComponent)
    }
    
    var title: String
    
    if isKML() {
      title = KMLParser.title(self.xml!)
    }
    else if isGPX() {
      title = GPXParser.title(self.xml!)
    }
    else if isTCX() {
      title = TCXParser.title(self.xml!)
    }
    else {
      title = (self.path.deletingPathExtension().lastPathComponent)
    }
    
    return title.isEmpty ? (self.path.deletingPathExtension().lastPathComponent) : title
  }
  
  func places() -> [GTPin]? {
    if isGPX() {
      return GPXParser.places(self.xml!)
    }
    else if isKML() {
      return KMLParser.places(self.xml!)
    }
    else if isTCX() {
      return TCXParser.places(self.xml!)
    }
    
    let result: [GTPin] = []
    return result
  }
  
  func lines() -> [Line]? {
    if isGPX() {
      return GPXParser.lines(self.xml!)
    }
    else if isKML() {
      return KMLParser.lines(self.xml!)
    }
    else if isTCX() {
      return TCXParser.lines(self.xml!)
    }
    
    let result: [Line] = []
    return result
  }
  
  func isGPX() -> Bool {
    return self.path.pathExtension.lowercased() == "gpx"
  }
  
  func isTCX() -> Bool {
    return self.path.pathExtension.lowercased() == "tcx"
  }
  
  func isKML() -> Bool {
    return self.path.pathExtension.lowercased() == "kml"
  }
}
