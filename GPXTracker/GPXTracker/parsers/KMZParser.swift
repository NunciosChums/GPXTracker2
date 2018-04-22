import Foundation
import MapKit
import Kanna

class KMZParser: BaseParser {
  let xml: XMLDocument
  let kmlParser: KMLParser
  let imageFolderPath: String
  
  init(xml: XMLDocument, imageFolderPath: String) {
    self.xml = xml
    kmlParser = KMLParser.init(xml: xml)
    self.imageFolderPath = imageFolderPath
  }
  
  func title() -> String? {
    return kmlParser.title()
  }
  
  func places() -> [GTPin]? {
    var places: [GTPin] = []
    
    kmlParser.places()?.forEach({ (pin) in
      let newPin = pin
      
      if let iconUrl = pin.iconUrl {
        if !iconUrl.hasPrefix("http") {
          newPin.iconUrl = imageFolderPath + iconUrl
        }
      }
      
      places.append(newPin)
    })
    
    return places
  }
  
  func lines() -> [GTLine]? {
    return kmlParser.lines()
  }
}
