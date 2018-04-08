import Foundation

protocol BaseParser {
  func title() -> String?
  
  func places() -> [GTPin]?
  
  func lines() -> [GTLine]?
}

