//
//  FloatingPoint+Round.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

public extension FloatingPoint {
  /// Rounds the double to decimal places value
  func roundTo(places: Int) -> Self {
    let divisor = Self(Int(pow(10.0, Double(places))))
    return (self * divisor).rounded() / divisor
  }
}
