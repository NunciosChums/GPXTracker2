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
  let path: NSURL
  let xml: XMLDocument?
  
  init(path: NSURL) {
    self.path = path
    let data = NSData(contentsOfURL: path)
    let datastring = NSString(data: data!, encoding: NSUTF8StringEncoding)
    let str = datastring!.stringByReplacingOccurrencesOfString("xmlns", withString: "no_xmlns")
    self.xml = Kanna.XML(xml: str, encoding: NSUTF8StringEncoding)
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
    return self.path.pathExtension?.lowercaseString == "gpx"
  }
  
  func isTCX() -> Bool {
    return self.path.pathExtension?.lowercaseString == "tcx"
  }
  
  func isKML() -> Bool {
    return self.path.pathExtension?.lowercaseString == "kml"
  }
}