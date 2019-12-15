//
//  UserClient.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation
import Just
import UIKit

class UserClient {
    
    static let shared = UserClient()
    
    private var token: String = "" {
        didSet {
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    private var session: JustOf<HTTP>
    
    var isLogged: Bool {
        token != ""
    }
    
    var cookies: [String: String] {
        ["session": token]
    }
    
    init() {
        token = UserDefaults.standard.string(forKey: "token") ?? ""
        let sessionDefaults = JustSessionDefaults()
        session = JustOf<HTTP>(defaults: sessionDefaults)
    }
    
    func signup(email: String, nickname: String, password: String) -> String? {
        let handlerURL = "\(API_EP)/user/signup"
        let r = session.post(handlerURL, json:["email": email, "nickname": nickname, "password": password])
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return "Connection failed"
        }
        let json = r.json as! [String: Any]
        if json["error"] != nil {
            return json["error"] as? String
        }
        token = r.cookies["session"]!.value
        return nil
    }
    
    func login(email: String, password: String) -> String? {
        let handlerURL = "\(API_EP)/user/login"
        let r = session.post(handlerURL, json:["email": email, "password": password])
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return "Connection failed"
        }
        let json = r.json as! [String: Any]
        if json["error"] != nil {
            return json["error"] as? String
        }
        token = r.cookies["session"]!.value
        return nil
    }
    
    func logout() -> Bool {
        let handlerURL = "\(API_EP)/user/logout"
        let r = session.get(handlerURL, cookies: cookies)
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return false
        }
        token = ""
        return true
    }
    
    func checkin() -> Bool {
        let handlerURL = "\(API_EP)/user/checkin"
        let r = session.get(handlerURL, cookies: cookies)
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return false
        }
        return true
    }
    
    func updateStatus() -> UserStatus? {
        let handlerURL = "\(API_EP)/user/status"
        let r = session.get(handlerURL, cookies: cookies)
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return nil
        }
        let json = r.json as! [String: Any]
        if json["error"] != nil {
            return nil
        }
        let email = json["email"] as! String
        let avatar = getAvatar(email: email)
        return UserStatus(email: email, nickname: json["nickname"] as! String, avatar: avatar, postTexts: json["post_texts"] as! Int, postImages: json["post_images"] as! Int)
    }
    
    func getAvatar(email: String) -> UIImage {
        let emailMD5 = email.md5
        let handlerURL = "\(GRAVATAR_EP)/\(emailMD5)"
        let r = Just.get(handlerURL)
        guard r.ok, r.statusCode == 200, r.content != nil else {
            return UIImage(named: "icon")!
        }
        return UIImage(data: r.content!) ?? UIImage(named: "icon")!
    }
    
    func postText(text: String, latitude: Double, longitude: Double) -> String? {
        guard isLogged else {
            return "Not logined"
        }
        let handlerURL = "\(API_EP)/item/new"
        let r = session.post(handlerURL, json:["type": "text", "content": text, "latitude": latitude, "longitude": longitude], cookies: cookies)
        guard r.ok, r.statusCode == 200, r.json != nil else {
            return "Connection failed"
        }
        let json = r.json as! [String: Any]
        if json["error"] != nil {
            return json["error"] as? String
        }
        return nil
    }
    
    func postImage(image:UIImage, latitude: Double, longitude: Double)  -> String? {
        guard isLogged else {
            return "Not logined"
        }
        let imageData = image.jpeg(.medium)!
        let uploadImageURL = "\(API_EP)/image/new"
        let r1 = session.post(uploadImageURL, files: ["image": .data("image.jpg", imageData, nil)], cookies: cookies)
        guard r1.ok, r1.statusCode == 200, r1.json != nil else {
            return "Connection failed"
        }
        let imageJson = r1.json as! [String: String]
        if imageJson["error"] != nil {
            return imageJson["error"]
        }
        let imageUUID = imageJson["id"]
        
        guard imageUUID != nil else {
            return "Upload image failed"
        }
        let handlerURL = "\(API_EP)/item/new"
        let r2 = session.post(handlerURL, json:["type": "image", "content": imageUUID!, "latitude": latitude, "longitude": longitude], cookies: cookies)
        guard r2.ok, r2.statusCode == 200, r2.json != nil else {
            return "Connection failed"
        }
        let json = r2.json as! [String: Any]
        if json["error"] != nil {
            return json["error"] as? String
        }
        return nil
    }
    
    
}
