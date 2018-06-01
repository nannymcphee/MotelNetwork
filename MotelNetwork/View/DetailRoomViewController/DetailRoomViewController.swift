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

    @IBOutlet var vHeader: UIView!
    @IBOutlet weak var svContent: UIScrollView!
    @IBOutlet weak var vSlideShow: ImageSlideshow!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblUsersAllowed: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblUser: UILabel!
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
        let placeholderImage = UIImage(named: "defaultImage")
        let placeholderSource = [ImageSource(image: placeholderImage!), ImageSource(image: placeholderImage!), ImageSource(image: placeholderImage!)]
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        if  roomImageUrl1 == nil || roomImageUrl2 == nil {
            let source = [KingfisherSource(urlString: roomImageUrl0!),
                          ImageSource(image: placeholderImage!),
                          ImageSource(image: placeholderImage!)]
            
            vSlideShow.setImageInputs(source as! [InputSource])
        }
        else if roomImageUrl0 == nil && roomImageUrl1 == nil && roomImageUrl2 == nil {
            vSlideShow.setImageInputs(placeholderSource)
        }
        else {
            
            let kingfisherSource = [KingfisherSource(urlString: roomImageUrl0!),
                                    KingfisherSource(urlString: roomImageUrl1!),
                                    KingfisherSource(urlString: roomImageUrl2!)]
            
            vSlideShow.setImageInputs(kingfisherSource as! [InputSource])
        }
        
        vSlideShow.backgroundColor = UIColor.white
        vSlideShow.slideshowInterval = 0
        vSlideShow.pageControlPosition = PageControlPosition.insideScrollView
        vSlideShow.pageControl.currentPageIndicatorTintColor = myBlue
        vSlideShow.pageControl.pageIndicatorTintColor = UIColor.white
        vSlideShow.circular = false
        vSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        vSlideShow.activityIndicator = DefaultActivityIndicator()
        vSlideShow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTapImage() {
        let fullScreenController = vSlideShow.presentFullScreenController(from: self)
        
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        fullScreenController.slideshow.circular = false
    }
    
    func setUpViewForOwner() {
        
        if let renterID = currentRoom.renterID {
            if renterID.isEmpty {
                
                self.lblUser.text = "Chưa có người thuê"
                self.tvPhoneNumber.text = "Chưa có người thuê"
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
    }
    
    func setUpViewForRenter() {
        
        if let ownerID = currentRoom.ownerID {
            let ref = Database.database().reference().child("Users").child(ownerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.lblUser.text = dictionary["FullName"] as? String
                    self.tvPhoneNumber.text = dictionary["PhoneNumber"] as? String
                }
            }, withCancel: nil)
        }
        
        btnMore.isHidden = true
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
            

            self.loadImageToImageView(imageUrl: profileImageUrl, imageView: self.ivAvatar)
        }
    }

    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMorePressed(_ sender: Any) {
        
        // Show confirmation alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionCalculate = UIAlertAction(title: "Tính tiền phòng", style: .default) { (action) in
            
            let room = self.currentRoom
            let renterID = room.renterID!
            
            if renterID.isEmpty {
                
                self.showAlert(title: "Thông báo", alertMessage: "Không thể tính tiền phòng chưa có người thuê.")
            }
            else {
                let vc = CalculateRoomPriceViewController()
                
                vc.currentRoom = room
                
                (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let actionEdit = UIAlertAction(title: "Sửa thông tin", style: .default) { (action) in
            
            let vc = EditRoomViewController()
            let room = self.currentRoom
            vc.currentRoom = room
            
            (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
        }
        
        let actionCancel = UIAlertAction(title: "Hủy", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionCalculate)
        alert.addAction(actionEdit)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

