//
//  ListNewsTableViewCell.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/2/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Kingfisher


class ListNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lblUsersAllowed: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var ivPostImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivPostImage.layer.cornerRadius = 5
        ivPostImage.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(news: News) {
        
        let placeholderImage = UIImage(named: "defaultImage")
        
        numberFormatter.numberStyle = .decimal
        let priceStr = numberFormatter.string(from: news.price! as NSNumber)
        self.lblPrice.text = "\(priceStr ?? "0")đ"
        self.lblTitle.text = news.title
        self.lblArea.text = "\(news.area ?? "")m2"
        self.lblLocation.text = news.district
        self.lblUsersAllowed.text = "Số người cho phép: \(news.usersAllowed ?? "0")"
        
        if news.postImageUrl0 != nil {
            let resource = ImageResource(downloadURL: URL(string: news.postImageUrl0!)!)
            
            ivPostImage.kf.setImage(with: resource, placeholder: placeholderImage , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            
            ivPostImage.image = placeholderImage
        }
        
    }
}

