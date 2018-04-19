//
//  ListMostViewTableViewCell.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/19/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Kingfisher

class ListMostViewTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var ivPostImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func populateData(news: News) {
        
        numberFormatter.numberStyle = .decimal
        let postImageUrl0 = news.postImageUrl0
        self.lblPrice.text = numberFormatter.string(from: news.price! as NSNumber)
        self.lblTitle.text = news.title
        self.lblArea.text = String("\(news.area ?? "")m2")
        self.lblLocation.text = news.district
        
        //         Use Kingfisher to download & show image
//        if URL(string: postImageUrl0!) != nil {
//            let resource = ImageResource(downloadURL: URL(string: postImageUrl0!)!)
//            
//            ivPostImage.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultImage"), options: nil, progressBlock: nil, completionHandler: nil)
//        }
        
    }
    
}
