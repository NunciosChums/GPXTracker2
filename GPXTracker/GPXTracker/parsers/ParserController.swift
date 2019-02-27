import Foundation
import Kanna

class ParserController {
  let file: GTFile
  let parser: BaseParser?

  init(file: GTFile) {
    self.file = file
    let data = try? Data(contentsOf: URL(fileURLWithPath: file.xmlFileFullPath))
    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    let str = dataString!.replacingOccurrences(of: "xmlns", with: "no_xmlns")
    let xml = try? Kanna.XML(xml: str, encoding: String.Encoding.utf8)
    
    if file.isKML() {
      parser = KMLParser(xml: xml!)
    }
    else if file.isKMZ() {
      parser = KMZParser(xml: xml!, imageFolderPath: file.imageFolderPath())
    }
    else if file.isGPX() {
      parser = GPXParser(xml: xml!)
    }
    else if file.isTCX() {
      parser = TCXParser(xml: xml!)
    }
    else {
      parser = nil
    }
  }
  
  func title() -> String? {
    return parser?.title() ?? file.name
  }
  
  func places() -> [GTPin]? {
    return parser?.places()
  }
  
  func lines() -> [GTLine]? {
    return parser?.lines()
  }
}
