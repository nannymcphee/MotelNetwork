//
//  DetailRoomViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/10/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
import Floaty
import ImageSlideshow

class DetailRoomViewController: UIViewController {

    @IBOutlet weak var vSlideShow: ImageSlideshow!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblUsersAllowed: UILabel!
    @IBOutlet weak var btnEditRoom: UIButton!
    @IBOutlet weak var btnNotification: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var btnCalculate: UIButton!
    @IBOutlet weak var tvPhoneNumber: UITextView!
    
    var currentRoom = Room()
    var dbReference: DatabaseReference!
    var renterName: String = ""
    var floaty = Floaty()
    var userType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUser()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    
    func setUpView() {
        
        let formattedPrice = numberFormatter.string(from: currentRoom.price! as NSNumber)
        lblPrice.text = "\(formattedPrice ?? "")đ"
        lblRoomName.text = currentRoom.name
        lblArea.text = String("\(currentRoom.area ?? "")m2")
        lblUsersAllowed.text = "Số người cho phép: \(currentRoom.usersAllowed ?? "")"
        lblAddress.text = currentRoom.address
        lblAddress.sizeToFit()
        makeImageViewRounded(imageView: ivAvatar)
        setUpSlideShow()
    }
    
    func setUpSlideShow() {

        let roomImageUrl0 = currentRoom.roomImageUrl0
        let roomImageUrl1 = currentRoom.roomImageUrl1
        let roomImageUrl2 = currentRoom.roomImageUrl2
        let kingfisherSource = [KingfisherSource(urlString: roomImageUrl0!), KingfisherSource(urlString: roomImageUrl1!), KingfisherSource(urlString: roomImageUrl2!)]
        let placeholderSource = [ImageSource(image: #imageLiteral(resourceName: "defaultImage")), ImageSource(image: #imageLiteral(resourceName: "defaultImage")), ImageSource(image: #imageLiteral(resourceName: "defaultImage"))]
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        vSlideShow.backgroundColor = UIColor.white
        vSlideShow.slideshowInterval = 3.0
        vSlideShow.pageControlPosition = PageControlPosition.underScrollView
        vSlideShow.pageControl.currentPageIndicatorTintColor = UIColor.black
        vSlideShow.pageControl.pageIndicatorTintColor = UIColor.lightGray
        vSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        vSlideShow.activityIndicator = DefaultActivityIndicator()
        vSlideShow.addGestureRecognizer(recognizer)
        
        if (roomImageUrl0?.isEmpty)! || (roomImageUrl1?.isEmpty)! || (roomImageUrl2?.isEmpty)! {
            vSlideShow.setImageInputs(placeholderSource)
        }
        else {
            vSlideShow.setImageInputs(kingfisherSource as! [InputSource])
        }
    }
    
    @objc func didTapImage() {
        let fullScreenController = vSlideShow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func setUpViewForOwner() {
        
        btnNotification.isHidden = true
        
        if let renterID = currentRoom.renterID {
            if renterID.isEmpty {
                
                self.lblUser.text = "Chưa có người thuê"
            }
            else {
                
                let ref = Database.database().reference().child("Users").child(renterID)
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        
                        if let userName = dictionary["FullName"] as? String {
                            
                            self.lblUser.text = userName
                        }
                        
                        if let phoneNumber = dictionary["PhoneNumber"] as? String {
                            
                            self.tvPhoneNumber.text = phoneNumber
                        }
                    }
                }, withCancel: nil)
            }
        }
        
        makeButtonRounded(button: btnCalculate)
        makeButtonRounded(button: btnEditRoom)
    }
    
    func setUpViewForRenter() {
        
        btnNotification.isHidden = true
        
        if let ownerID = currentRoom.ownerID {
            let ref = Database.database().reference().child("Users").child(ownerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.lblUser.text = dictionary["FullName"] as? String
                    self.tvPhoneNumber.text = dictionary["PhoneNumber"] as? String
                }
            }, withCancel: nil)
        }
        
        btnCalculate.isHidden = true
        btnEditRoom.isHidden = true
    }
    
    //MARK: Database interaction
    
    func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid!).observe(.value) { (snapshot) in
            
            // Get user value
            let dictionary = snapshot.value as! NSDictionary
            let userName = dictionary["FullName"] as? String ?? ""
            let profileImageUrl = dictionary["ProfileImageUrl"] as? String ?? ""
            
            self.lblFullName.text = userName
            self.userType = (dictionary["UserType"] as? Int)!
            
            if self.userType == 0 {
                self.setUpViewForOwner()
            }
            else {
                self.setUpViewForRenter()
            } 
            
            let resource = ImageResource(downloadURL: URL(string: profileImageUrl)!)
            self.ivAvatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCalculatePressed(_ sender: Any) {

        let room = currentRoom
        let renterID = room.renterID!
        
        if renterID.isEmpty {
            
            showAlert(alertMessage: "Không thể tính tiền phòng chưa có người thuê.")
        }
        else {
            let vc = CalculateRoomPriceViewController()
            
            vc.currentRoom = room
            
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func btnNotificationPressed(_ sender: Any) {
        
        let vc = CreateNotificationViewController()
        let room = currentRoom
        
        vc.currentRoom = room
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnEditRoomPressed(_ sender: Any) {

        let vc = EditRoomViewController()
        let room = currentRoom
        vc.currentRoom = room

        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}


