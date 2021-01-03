//
//  CancelBag.swift
//  GPXTracker
//
//  Created by 진창훈 on 2021/01/03.
//  Copyright © 2021 susemi99. All rights reserved.
//

import Combine

typealias CancelBag = Set<AnyCancellable>

extension CancelBag {
  /// 모든 구독 취소
  func cancelAll() {
    forEach { $0.cancel() }
  }
}
