//
//  News.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/13/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation

class News {
    var id: String?
    var ownerID: String?
    var title: String?
    var area: String?
    var address: String?
    var postImageUrl0: String?
    var postImageUrl1: String?
    var postImageUrl2: String?
    var district: String?
    var description: String?
    var phoneNumber: String?
    var timestamp: Int?
    var lat: String?
    var long: String?
    var usersAllowed: String?
    var price: Double?
    var electricPrice: Double?
    var waterPrice: Double?
    var internetPrice: Double?
    var views: Int?

    
    init() {
    }
    
    init(id: String, title: String, area: String, address: String, postImageUrl0: String, postImageUrl1: String, postImageUrl2: String, ownerID: String, district: String, description: String, phoneNumber: String, timestamp: Int, lat: String, long: String, usersAllowed: String, price: Double, electricPrice: Double, waterPrice: Double, internetPrice: Double, views: Int) {
        
        self.id = id
        self.title = title
        self.area = area
        self.address = address
        self.price = price
        self.postImageUrl0 = postImageUrl0
        self.postImageUrl1 = postImageUrl1
        self.postImageUrl2 = postImageUrl2
        self.ownerID = ownerID
        self.description = description
        self.district = district
        self.electricPrice = electricPrice
        self.waterPrice = waterPrice
        self.electricPrice = electricPrice
        self.phoneNumber = phoneNumber
        self.timestamp = timestamp
        self.lat = lat
        self.long = long
        self.usersAllowed = usersAllowed
        self.views = views
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.title = dictionary["title"] as? String
        self.area = dictionary["area"] as? String
        self.price = dictionary["price"] as? Double
        self.electricPrice = dictionary["electricPrice"] as? Double
        self.waterPrice = dictionary["waterPrice"] as? Double
        self.internetPrice = dictionary["internetPrice"] as? Double
        self.ownerID = dictionary["ownerID"] as? String
        self.postImageUrl0 = dictionary["postImageUrl0"] as? String
        self.postImageUrl1 = dictionary["postImageUrl1"] as? String
        self.postImageUrl2 = dictionary["postImageUrl2"] as? String
        self.description = dictionary["description"] as? String
        self.district = dictionary["district"] as? String
        self.address = dictionary["address"] as? String
        self.phoneNumber = dictionary["phoneNumber"] as? String
        self.timestamp = dictionary["timestamp"] as? Int
        self.lat = dictionary["lat"] as? String
        self.long = dictionary["long"] as? String
        self.usersAllowed = dictionary["usersAllowed"] as? String
        self.views = dictionary["views"] as? Int
    }
    
}
