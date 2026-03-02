import Foundation
import Kanna
import MapKit

class KMZParser: BaseParser {
  let xml: XMLDocument
  let kmlParser: KMLParser
  let imageFolderPath: String

  init(xml: XMLDocument, imageFolderPath: String) {
    self.xml = xml
    kmlParser = KMLParser(xml: xml)
    self.imageFolderPath = imageFolderPath
  }

  func title() -> String? {
    return kmlParser.title()
  }

  func places() -> [GTPin]? {
    kmlParser.places()?.map { pin in
      if let iconUrl = pin.iconUrl, !iconUrl.hasPrefix("http") {
        var updated = pin
        updated.iconUrl = imageFolderPath + iconUrl
        return updated
      }
      return pin
    }
  }

  func lines() -> [GTLine]? {
    return kmlParser.lines()
  }
}
