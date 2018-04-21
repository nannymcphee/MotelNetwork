//
//  Notification.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/21/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation

class Notification {
    var id: String?
    var ownerID: String?
    var renterID: String?
    var roomID: String?
    var title: String?
    var content: String?
    var ownerName: String?
    var ownerProfileImageUrl: String?
    var timestamp: Int?
    
    init() {
    }
    
    init(id: String, ownerID: String, renterID: String, roomID: String, title: String, content: String, ownerName: String, ownerProfileImageUrl: String, timestamp: Int) {
        self.id = id
        self.ownerID = ownerID
        self.renterID = renterID
        self.roomID = roomID
        self.title = title
        self.content = content
        self.ownerName = ownerName
        self.ownerProfileImageUrl = ownerProfileImageUrl
        self.timestamp = timestamp
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["roomID"] as? String
        self.renterID = dictionary["renterID"] as? String
        self.ownerID = dictionary["ownerID"] as? String
        self.roomID = dictionary["roomID"] as? String
        self.title = dictionary["title"] as? String
        self.content = dictionary["content"] as? String
        self.ownerName = dictionary["ownerName"] as? String
        self.ownerProfileImageUrl = dictionary["ownerProfileImageUrl"] as? String
        self.timestamp = dictionary["timestamp"] as? Int
    }
}
