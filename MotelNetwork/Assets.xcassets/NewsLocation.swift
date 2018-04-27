//
//  NewsLocation.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/27/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import CoreLocation

class NewsLocation {
    var title: String?
    var address: String?
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    
    init() {
    }
    
    init(title: String, address: String, lat: CLLocationDegrees, long: CLLocationDegrees) {
        self.title = title
        self.lat = lat
        self.long = long
    }
    
    init(dictionary: [String: AnyObject]) {
        self.title = dictionary["title"] as? String
        self.address = dictionary["address"] as? String
        self.lat = dictionary["lat"] as? CLLocationDegrees
        self.long = dictionary["long"] as? CLLocationDegrees
    }
}
