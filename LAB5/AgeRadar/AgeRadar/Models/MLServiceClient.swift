//
//  MLServiceClient.swift
//  AgeRadar
//
//  Created by Jing Su on 11/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import Just

class MLServiceClient {

    static let shared = MLServiceClient()
    
    var signedUser: String?
    
    private let serverURL: String = "https://ageradar.io.vc"
    private var session: JustOf<HTTP>
    
    init() {
        let sessionDefaults = JustSessionDefaults()
        session = JustOf<HTTP>(defaults: sessionDefaults)
    }
    
    func signup(username: String, password: String) -> Bool {
        let handlerURL = "\(serverURL)/Signup"
        let r = session.post(handlerURL, json:["username": username, "password": password])
        guard r.ok, r.statusCode == 200 else {
            return false
        }
        signedUser = username
        return true
    }
    
    func login(username: String, password: String) -> Bool {
        let handlerURL = "\(serverURL)/Login"
        let r = session.post(handlerURL, json:["username": username, "password": password])
        guard r.ok, r.statusCode == 200 else {
            return false
        }
        signedUser = username
        return true
    }
    
    func logout() {
        let handlerURL = "\(serverURL)/Logout"
        let r = session.get(handlerURL)
        guard r.ok, r.statusCode == 200 else {
            return
        }
        signedUser = nil
    }
    
    func addDataPoint(label: String, with image: UIImage, and imageQuality: Float) -> Bool {
        let imageData = image.jpeg(imageQuality)!
        
        let handlerURL = "\(serverURL)/AddDataPoint"
        let r = session.post(handlerURL,
                             data: ["label": label],
                             files: ["image": .data("image.jpg", imageData, nil)])
        guard r.ok, r.statusCode == 200 else {
            return false
        }
        return true
    }
    
    func updateModel(algorithm: String, kNNneighbors: Int?) -> Bool {
        let handlerURL = "\(serverURL)/UpdateModel"
        let r = session.post(handlerURL, json: ["algorithm": algorithm, "neighbors": kNNneighbors ?? 1])
        guard r.ok, r.statusCode == 200 else {
            return false
        }
        return true
    }
    
    func predict(with image: UIImage, and imageQuality: Float) -> String {
        let imageData = image.jpeg(imageQuality)!
        
        let handlerURL = "\(serverURL)/PredictOne"
        let r = session.post(handlerURL, files: ["image": .data("image.jpg", imageData, nil)])
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return "N/A"
        }
        let json = r.json as? [String: String]
        return json?["prediction"] ?? "N/A"
    }
}
