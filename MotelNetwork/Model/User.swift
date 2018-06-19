//
//  User.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var id: String?
    var name: String?
    var email: String?
    var birthDay: String?
    var profileImageUrl: String?
    var cmnd: String?
    var phoneNumber: String?
    var userType: Int?
    
    init() {
    }
    
    init(id: String, name: String, email: String, birthDay: String, profileImageUrl: String, cmnd: String, phoneNumber: String ,userType: Int) {
        
        self.id = id
        self.name = name
        self.email = email
        self.birthDay = birthDay
        self.profileImageUrl = profileImageUrl
        self.cmnd = cmnd
        self.phoneNumber = phoneNumber
        self.userType = userType
    }
    
    init(dictionary:[String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.birthDay = dictionary["birthDay"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.cmnd = dictionary["cmnd"] as? String
        self.phoneNumber = dictionary["phoneNumber"] as? String
        self.userType = dictionary["userType"] as? Int
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["FullName"]
        email <- map["Email"]
        profileImageUrl <- map["ProfileImageUrl"]
        birthDay <- map["BirthDay"]
        cmnd <- map["CMND"]
        phoneNumber <- map["PhoneNumber"]
        userType <- map["UserType"]
    }
}
