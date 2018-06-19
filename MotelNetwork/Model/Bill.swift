//
//  Bills.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/21/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import ObjectMapper

class Bill: Mappable {
    
    var id: String?
    var ownerID: String?
    var renterID: String?
    var roomID: String?
    var surchargeReason: String?
    var electricPrice: Double?
    var internetPrice: Double?
    var waterPrice: Double?
    var userCount: Double?
    var oldElectricNumber: Double?
    var newElectricNumber: Double?
    var surcharge: Double?
    var roomPrice: Double?
    var totalRoomPrice: Double?
    var totalWaterPrice: Double?
    var totalElectricPrice: Double?
    var timestamp: Int?
    
    init() {
    }
    
    init(id: String, ownerID: String, renterID: String, roomID: String, surchargeReason: String, electricPrice: Double, internetPrice: Double, waterPrice: Double, userCount: Double, oldElectricNumber: Double, newElectricNumber: Double, surcharge: Double, roomPrice: Double, totalRoomPrice: Double, totalWaterPrice: Double, totalElectricPrice: Double, timestamp: Int) {
        self.id = id
        self.ownerID = ownerID
        self.renterID = renterID
        self.roomID = roomID
        self.surchargeReason = surchargeReason
        self.electricPrice = electricPrice
        self.waterPrice = waterPrice
        self.internetPrice = internetPrice
        self.userCount = userCount
        self.oldElectricNumber = oldElectricNumber
        self.newElectricNumber = newElectricNumber
        self.surcharge = surcharge
        self.timestamp = timestamp
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["roomID"] as? String
        self.renterID = dictionary["renterID"] as? String
        self.ownerID = dictionary["ownerID"] as? String
        self.roomID = dictionary["roomID"] as? String
        self.surchargeReason = dictionary["surchargeReason"] as? String
        self.electricPrice = dictionary["electricPrice"] as? Double
        self.waterPrice = dictionary["waterPrice"] as? Double
        self.userCount = dictionary["userCount"] as? Double
        self.oldElectricNumber = dictionary["oldElectricNumber"] as? Double
        self.newElectricNumber = dictionary["newElectricNumber"] as? Double
        self.surcharge = dictionary["surcharge"] as? Double
        self.roomPrice = dictionary["roomPrice"] as? Double
        self.totalRoomPrice = dictionary["totalRoomPrice"] as? Double
        self.totalWaterPrice = dictionary["totalWaterPrice"] as? Double
        self.totalElectricPrice = dictionary["totalElectricPrice"] as? Double
        self.timestamp = dictionary["timestamp"] as? Int
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        renterID <- map["renterID"]
        ownerID <- map["ownerID"]
        roomID <- map["roomID"]
        surchargeReason <- map["surchargeReason"]
        electricPrice <- map["electricPrice"]
        waterPrice <- map["waterPrice"]
        userCount <- map["userCount"]
        oldElectricNumber <- map["oldElectricNumber"]
        newElectricNumber <- map["newElectricNumber"]
        surcharge <- map["surcharge"]
        roomPrice <- map["roomPrice"]
        totalRoomPrice <- map["totalRoomPrice"]
        totalWaterPrice <- map["totalWaterPrice"]
        totalElectricPrice <- map["totalElectricPrice"]
        internetPrice <- map["internetPrice"]
        timestamp <- map["timestamp"]
    }
}

