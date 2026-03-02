import Foundation

extension UserDefaults {
  private enum Keys {
    static let isFirstRun = "is_first_run_v2"
    static let isHybridMap = "is_hybrid_map_v3"
  }

  /// 샘플 파일 복사가 완료되었는가?
  static var hasLaunchedBefore: Bool {
    get { standard.bool(forKey: Keys.isFirstRun) }
    set { standard.set(newValue, forKey: Keys.isFirstRun) }
  }

  /// 위성 지도 모드인가?
  static var isHybridMap: Bool {
    get { standard.bool(forKey: Keys.isHybridMap) }
    set { standard.set(newValue, forKey: Keys.isHybridMap) }
  }
}
