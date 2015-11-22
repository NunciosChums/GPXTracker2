//
//  KMLParser.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 11. 21..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import Foundation
import SWXMLHash

class KMLParser {
  
  class func title(xml: XMLIndexer) -> String {
    return (xml["kml"]["Document"]["name"].element?.text)!
  }
}