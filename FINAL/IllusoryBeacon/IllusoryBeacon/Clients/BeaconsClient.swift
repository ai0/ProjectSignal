//
//  BeaconsClient.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/13/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

class BeaconsClient: WebSocketDelegate {
    
    private var socket: WebSocket

    var beacons: [Beacon] = []
    var beaconsID: [Int] = []
    var isConnected: Bool {
        socket.isConnected
    }
    
    var beaconsDelegate: BeaconsDelegate?
    
    init() {
        socket = WebSocket(url: URL(string: "\(WEBSOCKET_EP)/beacons")!)
        socket.delegate = self
        socket.connect()
    }
    
    func connect() -> Bool {
        socket.connect()
        return socket.isConnected
    }
    
    func updateBeacons(latitude: Double, longitude: Double, limit: Int) {
        let json: JSON = ["latitude": latitude, "longitude": longitude, "limit": limit]
        if let jsonString = json.rawString([.castNilToNSNull: true]) {
            socket.write(string: jsonString)
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocket Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket Disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            do {
                let json = try JSON(data: dataFromString)
                var latestBeacons: [Beacon] = []
                var latestBeaconsID: [Int] = []
                for (_, item): (String, JSON) in json {
                    let beacon = Beacon(type: item["type"].string!, content: item["content"].string!)
                    latestBeacons.append(beacon)
                    latestBeaconsID.append(item["id"].int!)
                }
                if latestBeaconsID != beaconsID {
                    beacons = latestBeacons
                    beaconsID = latestBeaconsID
                    beaconsDelegate?.loadBeacons()
                }
            } catch {}
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
    
}
