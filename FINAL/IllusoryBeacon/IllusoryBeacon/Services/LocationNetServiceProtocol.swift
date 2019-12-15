//
//  LocationNetServiceProtocol.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import CoreML
import Vision

public protocol LocationNetServiceProtocol: class {
    init()
    func setup(for model: MLModel)
    func predict(image: CIImage)
}

public extension LocationNetServiceProtocol {
    
    // Handle results of the classification request
    func extractPredictionResult(from request: VNRequest, count: Int) -> [(String, Double)] {
        guard let observations = request.results as? [VNClassificationObservation] else {
            return []
        }
        return observations
            .prefix(upTo: count)
            .map { ($0.identifier, Double($0.confidence * 100.0).roundTo(places: 1)) }
    }
}
