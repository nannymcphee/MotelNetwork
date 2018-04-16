//
//  SignedInDetailNewsViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher


class DetailNewsViewController: UIViewController {
    
    
    @IBOutlet weak var btnBack2: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var ivNewsImage: UIImageView!
    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblDistrict: UILabel!
    @IBOutlet weak var lblWaterPrice: UILabel!
    @IBOutlet weak var lblElectricPrice: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var lblInternetPrice: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    
    var dbReference: DatabaseReference!
    var currentNews = News()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        let userProfileImageUrl = currentNews.userProfileImageUrl
        let postImageUrl0 = currentNews.postImageUrl0
        let profileImgResource = ImageResource(downloadURL: URL(string: userProfileImageUrl!)!)
        
        numberFormatter.numberStyle = .decimal
        lblPrice.text = numberFormatter.string(from: currentNews.price! as NSNumber)
        lblElectricPrice.text = numberFormatter.string(from: currentNews.electricPrice! as NSNumber)
        lblWaterPrice.text = numberFormatter.string(from: currentNews.waterPrice! as NSNumber)
        lblInternetPrice.text = numberFormatter.string(from: currentNews.internetPrice! as NSNumber)
        lblArea.text = String("\(currentNews.area ?? "")m2")
        lblDistrict.text = currentNews.district
        tvDescription.text = currentNews.description
        lblPhoneNumber.text = currentNews.phoneNumber
        lblPostDate.text = currentNews.postDate
        lblAddress.text = currentNews.address
        lblNewsTitle.text = currentNews.title
        lblUserName.text = currentNews.user
        
        ivAvatar.kf.setImage(with: profileImgResource, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
        
        // Use Kingfisher to download & show image
        if URL(string: postImageUrl0!) != nil {
            let resource = ImageResource(downloadURL: URL(string: postImageUrl0!)!)
            
            ivNewsImage.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultImage") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else{
            ivNewsImage.image = #imageLiteral(resourceName: "defaultImage")
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    

    //MARK: Handling button pressed
    
    @IBAction func btnBack2Pressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
}
