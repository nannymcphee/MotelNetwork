//
//  Room.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class Room {
    var id: String?
    var name: String?
    var area: String?
    var roomImageUrl0: String?
    var roomImageUrl1: String?
    var roomImageUrl2: String?
    var user: String?
    var price: Double?
    
    init() {
    }
    
    init(id: String, name: String, area: String, roomImageUrl0: String, roomImageUrl1: String, roomImageUrl2: String, user: String, price: Double) {
        self.id = id
        self.name = name
        self.area = area
        self.price = price
        self.roomImageUrl0 = roomImageUrl0
        self.roomImageUrl1 = roomImageUrl1
        self.roomImageUrl2 = roomImageUrl2
        self.user = user
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.area = dictionary["area"] as? String
        self.price = dictionary["price"] as? Double
        self.user = dictionary["user"] as? String
        self.roomImageUrl0 = dictionary["roomImageUrl0"] as? String
    }
    
}
