//
//  TimeAgoDisplay.swift
//  Motel Network
//
//  Created by Nguyên Duy on 5/1/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import UIKit

let now = Date()
let pastDate = Date(timeIntervalSinceNow: -60 * 60 * 24)

extension Date {
    
    func timeAgoDisplay() -> String{
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return "\(secondsAgo) giây trước"
        }
        else if secondsAgo < hour {
            return "\(secondsAgo / minute) giờ trước"
        }
        else if secondsAgo < day {
            return "\(secondsAgo / day) ngày trước"
        }
        else if secondsAgo < week {
            return "\(secondsAgo / week) tuần trước"
        }
        
        return "\(secondsAgo / week) tuần trước"
    }
}
