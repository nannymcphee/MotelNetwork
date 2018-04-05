//
//  User.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var pass: String?
    var birthDay: String?
    var profileImageUrl: String?
    var cmnd: String?
    var userType: Int?
    
    init(dictionary:[String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.pass = dictionary["pass"] as? String
        self.birthDay = dictionary["birthDay"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.cmnd = dictionary["cmnd"] as? String
        self.userType = dictionary["userType"] as? Int
    }
}
