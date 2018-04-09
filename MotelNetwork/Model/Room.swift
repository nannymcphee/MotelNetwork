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
    var price: Double?
    
    init() {
    }
    
    init(id: String, name: String, area: String, price: Double) {
        self.id = id
        self.name = name
        self.area = area
        self.price = price
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.area = dictionary["area"] as? String
        self.price = dictionary["price"] as? Double
    }
}
