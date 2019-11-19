//
//  DetectionService.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import CoreML
import Vision

protocol DetectionServiceDelegate: class {
  func detectionService(_ service: DetectionService, didDetectAge age: String)
}

final class DetectionService: DetectionServiceProtocol {
  /// The service's delegate
  weak var delegate: DetectionServiceDelegate?
  /// Array of vision requests
  private var requests = [VNRequest]()

  /// Create CoreML model and classification requests
  func setup() {
    do {
      requests.append(VNCoreMLRequest(
        model: try VNCoreMLModel(for: AgeNet().model),
        completionHandler: handleAgeClassification
      ))
    } catch {
      assertionFailure("Unable to load ML model: \(error)")
    }
  }

  /// Run individual requests one by one.
  func detect(image: CIImage) {
    do {
      for request in self.requests {
        let handler = VNImageRequestHandler(ciImage: image)
        try handler.perform([request])
      }
    } catch {
      print(error)
    }
  }

  // MARK: - Handling
  @objc private func handleAgeClassification(request: VNRequest, error: Error?) {
    let result = extractDetectionResult(from: request, count: 1)
    delegate?.detectionService(self, didDetectAge: result)
  }
}
