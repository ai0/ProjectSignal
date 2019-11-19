//
//  DetectionServiceProtocol.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import Vision

public protocol DetectionServiceProtocol: class {
  init()
  func setup()
  func detect(image: CIImage)
}

public extension DetectionServiceProtocol {
  /// Handle results of the classification request
  func extractDetectionResult(from request: VNRequest, count: Int) -> String {
    guard let observations = request.results as? [VNClassificationObservation] else {
      return "Unknown"
    }
    return observations
      .prefix(upTo: count)
      .map({ "\($0.identifier) (\($0.confidence.roundTo(places: 3) * 100.0)%)" })
      .joined(separator: "\n\n")
  }
}
