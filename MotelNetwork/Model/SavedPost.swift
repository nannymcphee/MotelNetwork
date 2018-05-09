//
//  SavedPost.swift
//  Motel Network
//
//  Created by Nguyên Duy on 5/7/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import UIKit

class SavedPost {
    
    var id: String?
    var postID: String?

    init() {
    }
    
    init(id: String, postID: String) {
        
        self.id = id
        self.postID = postID
    }
    
    init(dictionary:[String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.postID = dictionary["postID"] as? String
        
    }
}
