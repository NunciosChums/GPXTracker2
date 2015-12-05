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
  
  init(path: NSURL) {
    self.path = path
    self.xml = SWXMLHash.parse(try! String(contentsOfFile: path.path!, encoding: NSUTF8StringEncoding))
  }
  
  func title() -> String {
    if self.xml == nil {
      return (self.path.URLByDeletingPathExtension?.lastPathComponent)!
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
      title = (self.path.URLByDeletingPathExtension?.lastPathComponent)!
    }
    
    return title.isEmpty ? (self.path.URLByDeletingPathExtension?.lastPathComponent)! : title
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
    return nil
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