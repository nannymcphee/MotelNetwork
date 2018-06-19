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
//            return "\(secondsAgo) giây trước"
            return "Vừa xong"
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
    
    // Usage:
    // lblTimeAgo.text = Date.timeAgoDisplay(timestampDate as Date)()

}

extension UIViewController {
    public func timeAgoSince(_ date: Date) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year) năm trước"
        }
        
        if let year = components.year, year >= 1 {
            return "1 năm trước"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month) tháng trước"
        }
        
        if let month = components.month, month >= 1 {
            return "1 tháng trước"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week) tuần trước"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "1 tuần trước"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day) ngày trước"
        }
        
        if let day = components.day, day >= 1 {
            return "Hôm qua"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) giờ"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "1 giờ"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) phút"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "1 phút"
        }
        
        if let second = components.second, second >= 3 {
            return "Vừa xong"
        }
        
        return "Vừa xong"
    }
    
    // Usage:
    // lblTimeAgo.text = timeAgoSince(timestampDate as Date)
}
