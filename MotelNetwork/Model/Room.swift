//
//  Room.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import ObjectMapper

class Room: Mappable {
    
    var id: String?
    var ownerID: String?
    var renterID: String?
    var renterName: String?
    var name: String?
    var area: String?
    var roomImageUrl0: String?
    var roomImageUrl1: String?
    var roomImageUrl2: String?
    var usersAllowed: String?
    var address: String?
    var price: Double?

    
    init() {
    }
    
    init(id: String, name: String, area: String, roomImageUrl0: String, roomImageUrl1: String, roomImageUrl2: String, ownerID: String, renterID: String, address: String, price: Double, usersAllowed: String, renterName: String) {
        self.id = id
        self.name = name
        self.area = area
        self.price = price
        self.roomImageUrl0 = roomImageUrl0
        self.roomImageUrl1 = roomImageUrl1
        self.roomImageUrl2 = roomImageUrl2
        self.ownerID = ownerID
        self.renterID = renterID
        self.usersAllowed = usersAllowed
        self.address = address
        self.renterName = renterName
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.renterID = dictionary["renterID"] as? String
        self.ownerID = dictionary["ownerID"] as? String
        self.name = dictionary["name"] as? String
        self.renterName = dictionary["renterName"] as? String
        self.area = dictionary["area"] as? String
        self.price = dictionary["price"] as? Double
        self.roomImageUrl0 = dictionary["roomImageUrl0"] as? String
        self.roomImageUrl1 = dictionary["roomImageUrl1"] as? String
        self.roomImageUrl2 = dictionary["roomImageUrl2"] as? String
        self.usersAllowed = dictionary["usersAllowed"] as? String
        self.address = dictionary["address"] as? String
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        address <- map["address"]
        area <- map["area"]
        ownerID <- map["ownerID"]
        price <- map["price"]
        renterID <- map["renterID"]
        renterName <- map["renterName"]
        roomImageUrl0 <- map["roomImageUrl0"]
        roomImageUrl1 <- map["roomImageUrl1"]
        roomImageUrl2 <- map["roomImageUrl2"]
        name <- map["roomName"]
        usersAllowed <- map["usersAllowed"]
    }
}
