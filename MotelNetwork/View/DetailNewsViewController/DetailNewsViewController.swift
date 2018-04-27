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
import Floaty

class DetailNewsViewController: UIViewController {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvPhoneNumber: UITextView!
    @IBOutlet weak var btnBack2: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var ivNewsImage0: UIImageView!
    @IBOutlet weak var ivNewsImage1: UIImageView!
    @IBOutlet weak var ivNewsImage2: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblDistrict: UILabel!
    @IBOutlet weak var lblWaterPrice: UILabel!
    @IBOutlet weak var lblElectricPrice: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var lblInternetPrice: UILabel!
    @IBOutlet weak var tvAddress: UITextView!
    @IBOutlet weak var tvDescription: UITextView!
    
    var dbReference: DatabaseReference!
    var currentNews = News()
    var floaty = Floaty()

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
        
        layoutFAB()
        numberFormatter.numberStyle = .decimal
        let postImageUrl0 = currentNews.postImageUrl0
        let postImageUrl1 = currentNews.postImageUrl1
        let postImageUrl2 = currentNews.postImageUrl2
        let formattedPrice = numberFormatter.string(from: currentNews.price! as NSNumber)
        let formattedElectricPrice = numberFormatter.string(from: currentNews.electricPrice! as NSNumber)
        let formattedWaterPrice = numberFormatter.string(from: currentNews.waterPrice! as NSNumber)
        let formattedInternetPrice = numberFormatter.string(from: currentNews.internetPrice! as NSNumber)
        
        if let ownerID = currentNews.ownerID {
            
            let ref = Database.database().reference().child("Users").child(ownerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    if let userProfileImageUrl = dictionary["ProfileImageUrl"] as? String {
                        
                        let profileImgResource = ImageResource(downloadURL: URL(string: userProfileImageUrl)!)
                        
                        self.ivAvatar.kf.setImage(with: profileImgResource, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                    
                    if let userName = dictionary["FullName"] as? String {
                        self.lblUserName.text = userName
                    }
                }
            }, withCancel: nil)
        }

        lblPrice.text = "\(formattedPrice ?? "")đ"
        lblElectricPrice.text = "\(formattedElectricPrice ?? "")đ"
        lblWaterPrice.text = "\(formattedWaterPrice ?? "")đ"
        lblInternetPrice.text = "\(formattedInternetPrice ?? "")đ"
        lblArea.text = String("\(currentNews.area ?? "")m2")
        lblDistrict.text = currentNews.district
        tvDescription.text = currentNews.description
        tvPhoneNumber.text = currentNews.phoneNumber
        lblPostDate.text = currentNews.postDate
        tvAddress.text = currentNews.address
        lblTitle.text = currentNews.title
        
        loadImageToImageView(imageUrl: postImageUrl0!, imageView: ivNewsImage0)
        loadImageToImageView(imageUrl: postImageUrl1!, imageView: ivNewsImage1)
        loadImageToImageView(imageUrl: postImageUrl2!, imageView: ivNewsImage2)
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    

    //MARK: Handling button pressed
    
    @IBAction func btnBack2Pressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
}

extension DetailNewsViewController: FloatyDelegate {
    func layoutFAB() {
       
        floaty.paddingX = self.view.frame.width / 2 - floaty.frame.width * 3
        floaty.fabDelegate = self
        floaty.buttonImage = #imageLiteral(resourceName: "icDirection")
        floaty.buttonColor = UIColor.white
//        floaty.buttonColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        self.view.addSubview(floaty)
        
    }
    
    // MARK: - Floaty Delegate Methods
    func emptyFloatySelected(_ floaty: Floaty) {
        let vc = NavigationViewController()
        let news = currentNews
        
        vc.currentNews = news
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}


