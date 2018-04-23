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

class DetailRoomViewController: UIViewController {

    @IBOutlet weak var btnNotification: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var ivRoomImage0: UIImageView!
    @IBOutlet weak var ivRoomImage1: UIImageView!
    @IBOutlet weak var ivRoomImage2: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var btnCalculate: UIButton!
    @IBOutlet weak var vView1: UIView!
    @IBOutlet weak var vView2: UIView!
    @IBOutlet weak var vView3: UIView!
    
    var currentRoom = Room()
    var dbReference: DatabaseReference!
    var imageUrlsArray = [String]()
    
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
        
        fetchUser()
        
        let roomImageUrl0 = currentRoom.roomImageUrl0
        let roomImageUrl1 = currentRoom.roomImageUrl1
        let roomImageUrl2 = currentRoom.roomImageUrl2
        
        imageUrlsArray.append(roomImageUrl0!)
        imageUrlsArray.append(roomImageUrl1!)
        imageUrlsArray.append(roomImageUrl2!)
        
        let formattedPrice = numberFormatter.string(from: currentRoom.price! as NSNumber)
        lblPrice.text = "\(formattedPrice ?? "")đ"
        lblRoomName.text = currentRoom.name
        lblArea.text = String("\(currentRoom.area ?? "")m2")
        
        if let renterID = currentRoom.renterID {
            let ref = Database.database().reference().child("Users").child(renterID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    if let renterName = dictionary["FullName"] as? String {
                        if !(renterName.isEmpty) {
                            self.lblUser.text = renterName
                        } else {
                            self.lblUser.text = "Chưa có người thuê"
                        }
                    }
                }
            }, withCancel: nil)
        }

        loadImageToImageView(imageUrl: roomImageUrl0!, imageView: ivRoomImage0)
        loadImageToImageView(imageUrl: roomImageUrl1!, imageView: ivRoomImage1)
        loadImageToImageView(imageUrl: roomImageUrl2!, imageView: ivRoomImage2)
        
        makeButtonRounded(button: btnCalculate)
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    //MARK: Database interaction
    
    func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid!).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            
            self.lblFullName.text = userName
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
        let vc = CalculateRoomPriceViewController()
        
        vc.currentRoom = room
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNotificationPressed(_ sender: Any) {
        
        let vc = CreateNotificationViewController()
        let room = currentRoom
        
        vc.currentRoom = room
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
}
