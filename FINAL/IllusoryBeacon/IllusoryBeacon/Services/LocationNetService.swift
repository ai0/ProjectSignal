//
//  LocationNetService.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import CoreML
import Vision

protocol LocationNetServiceDelegate: class {
  func locationNetService(_ service: LocationNetService, didPredictLocation location: [(String, Double)])
}

final class LocationNetService: LocationNetServiceProtocol {
    /// The service's delegate
    weak var delegate: LocationNetServiceDelegate?
    /// Array of vision requests
    private var requests = [VNRequest]()
    
    /// Create CoreML model and classification requests
    func setup(for model: MLModel) {
        do {
            requests.append(VNCoreMLRequest(
                model: try VNCoreMLModel(for: model),
                completionHandler: handleLocationClassification
            ))
        } catch {
            assertionFailure("Unable to load ML model: \(error)")
        }
    }
    
    /// Run individual requests one by one.
    func predict(image: CIImage) {
        do {
            for request in self.requests {
                let handler = VNImageRequestHandler(ciImage: image)
                try handler.perform([request])
            }
        } catch {
            print(error)
        }
    }
    
    func predict(image: CVPixelBuffer) {
      do {
        for request in self.requests {
          let handler = VNImageRequestHandler(cvPixelBuffer: image)
          try handler.perform([request])
        }
      } catch {
        print(error)
      }
    }
    
    
    
    // MARK: - Handling
    @objc private func handleLocationClassification(request: VNRequest, error: Error?) {
        let result = extractPredictionResult(from: request, count: 1)
        delegate?.locationNetService(self, didPredictLocation: result)
    }
}
