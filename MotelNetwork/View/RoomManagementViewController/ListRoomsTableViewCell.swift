//
//  ListRoomsTableViewCell.swift
//  MotelNetwork
//
//  Created by Phùng Trọng Huy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class ListRoomsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var lblRoomPrice: UILabel!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var ivRoomImage: UIImageView!
    
    var renterName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(room: Room) {
        numberFormatter.numberStyle = .decimal
        self.lblRoomName.text = room.name
        self.lblRoomPrice.text = numberFormatter.string(from: room.price! as NSNumber)
        self.lblArea.text = String("\(room.area ?? "")m2")
        
        if let renterID = room.renterID {
            let ref = Database.database().reference().child("Users").child(renterID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    if (snapshot.value != nil) {
                        self.lblUserFullName.text = dictionary["FullName"] as? String
                    } else {
                        self.lblUserFullName.text = "Chưa có người thuê"
                    }
                }
            }, withCancel: nil)  
        }
        
        if URL(string: room.roomImageUrl0!) != nil {
            let resource = ImageResource(downloadURL: URL(string: room.roomImageUrl0!)!)
            
            ivRoomImage.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultImage") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            
            ivRoomImage.image = #imageLiteral(resourceName: "defaultImage")
        }
    }
    
    func populateDataForRenter(room: Room) {
        numberFormatter.numberStyle = .decimal
        self.lblRoomName.text = room.name
        self.lblRoomPrice.text = numberFormatter.string(from: room.price! as NSNumber)
        self.lblArea.text = String("\(room.area ?? "")m2")
        
        if let ownerID = room.ownerID {
            let ref = Database.database().reference().child("Users").child(ownerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.lblUserFullName.text = dictionary["FullName"] as? String
                }
            }, withCancel: nil)
        }
        
        if URL(string: room.roomImageUrl0!) != nil {
            let resource = ImageResource(downloadURL: URL(string: room.roomImageUrl0!)!)
            
            ivRoomImage.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultImage") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            
            ivRoomImage.image = #imageLiteral(resourceName: "defaultImage")
        }
    }
}
