//
//  PreviewContent.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/7/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Combine
import SwiftUI
import CoreLocation

final class PreviewContent: ObservableObject {

    enum ContentType {
        case Text
        case Image
        case Map
    }
    
    @Published var contentType: ContentType?
    @Published var textContent: String? {
        didSet {
            contentType = .Text
        }
    }
    @Published var imageContent: UIImage? {
        didSet {
            contentType = .Image
        }
    }
    @Published var locationCoordinate: CLLocationCoordinate2D? {
        didSet {
            contentType = .Map
        }
    }
    
    init() {}
    
    init(textContent: String) {
        self.contentType = .Text
        self.textContent = textContent
    }
    
    init(imageContent: UIImage) {
        self.contentType = .Image
        self.imageContent = imageContent
    }
    
    init(locationCoordinate: CLLocationCoordinate2D) {
        self.contentType = .Map
        self.locationCoordinate = locationCoordinate
    }
    
}
