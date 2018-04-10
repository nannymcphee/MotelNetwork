//
//  ListRoomsTableViewCell.swift
//  MotelNetwork
//
//  Created by Phùng Trọng Huy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class ListRoomsTableViewCell: UITableViewCell{

    
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var lblRoomPrice: UILabel!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var ivRoomImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(room: Room) {
        self.lblRoomName.text = room.name
        self.lblRoomPrice.text = String("\(room.price ?? 0.0)")
        self.lblArea.text = room.area
        self.lblUserFullName.text = room.user ?? "Không"
        
    }
}
