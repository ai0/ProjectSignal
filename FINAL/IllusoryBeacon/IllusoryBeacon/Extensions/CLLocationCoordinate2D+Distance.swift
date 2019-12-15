//
//  CLLocationCoordinate2D+Distance.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func distanceInMeters(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location2.distance(from: location1)
    }
    
    func isInsideSMUCampus() -> Bool {
        32.836688...32.848366 ~= self.latitude && (-96.7900987)...(-96.7811797) ~= self.longitude
    }
}
