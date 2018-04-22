//
//  ListBillTableViewCell.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/21/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListBillTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRoomName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(bill: Bill) {
        
        var monthStr: String = ""
        let timestampDouble = Double(bill.timestamp!)
        let timestampDate = NSDate(timeIntervalSince1970: timestampDouble)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM"
        monthStr = dateFormatter.string(from: timestampDate as Date)
        self.lblTitle.text = "Hoá đơn tháng \(monthStr)"
        
        if let roomID = bill.roomID {
            let ref = Database.database().reference().child("Rooms").child(roomID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.lblRoomName.text  = dictionary["roomName"] as? String
                }
            }, withCancel: nil)
        }
    }
}
