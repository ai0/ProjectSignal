//
//  Constants.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

// MARK: Backend
let SERVER_URL = "ib.io.vc"
let API_EP = "https://\(SERVER_URL)"
let WEBSOCKET_EP = "wss://\(SERVER_URL)"

// MARK: ARScene
let IMAGE_CACHE_SIZE: Int = 32
let GPS_OFFSET_TOLERATE: Double = 10 // meters

// MARK: Copywriter
let TERMS_OF_SERVICE = """
1. During the service period, your location data will upload to our server when you post items. The location data includes latitude and longitude.

2. A third-party named Gravatar provides the avatar service. Your email address will be shared with them to pull the avatar.

3. The camera frame data will only process locally and will never upload to our server.

4. The gyroscope data will only process locally and will never upload to our server.

5. Your password will preserve as SHA-256 hash for verification purposes. No plaintext passwords will be persistently stored.
"""

// MARK: Service
let EXTERNAL_GRAVATAR_URL = "https://gravatar.com/"
let GRAVATAR_EP = "https://gravatar.com/avatar/"
