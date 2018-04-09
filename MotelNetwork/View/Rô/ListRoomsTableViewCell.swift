//
//  ListRoomsTableViewCell.swift
//  MotelNetwork
//
//  Created by Phùng Trọng Huy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class ListRoomsTableViewCell: UITableViewCell{

    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblRoomPrice: UILabel!
    
    @IBOutlet weak var lblUserFullName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
