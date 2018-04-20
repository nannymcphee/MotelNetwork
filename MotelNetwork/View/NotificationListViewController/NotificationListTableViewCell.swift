//
//  NotificationListTableViewCell.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/20/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class NotificationListTableViewCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTimestamp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
