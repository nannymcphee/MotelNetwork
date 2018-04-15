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

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var ivRoomImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var btnCalculate: UIButton!
    
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
        
        numberFormatter.numberStyle = .decimal
        lblPrice.text = numberFormatter.string(from: currentRoom.price! as NSNumber)
        lblRoomName.text = currentRoom.name
        lblArea.text = String("\(currentRoom.area ?? "")m2")
        lblUser.text = currentRoom.user
        
        // Use Kingfisher to download & show image
        if URL(string: roomImageUrl0!) != nil {
            let resource = ImageResource(downloadURL: URL(string: roomImageUrl0!)!)
            
            ivRoomImage.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultImage") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else{
            ivRoomImage.image = #imageLiteral(resourceName: "defaultImage")
        }
        
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
    
    @IBAction func btnEditPressed(_ sender: Any) {
        
        let vc = EditRoomViewController()
        let room = currentRoom
        
        vc.currentRoom = room
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCalculatePressed(_ sender: Any) {
        
        let room = currentRoom
        let vc = CalculateRoomPriceViewController()
        
        vc.currentRoom = room
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
}
