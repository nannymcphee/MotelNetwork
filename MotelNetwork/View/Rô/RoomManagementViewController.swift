//
//  RoomManagementViewController.swift
//  MotelNetwork
//
//  Created by Phùng Trọng Huy on 4/4/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RoomManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnCreateRoom: UIButton!
    @IBOutlet weak var tbRoomManagement: UITableView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    
    var dbReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbRoomManagement.delegate = self
        tbRoomManagement.dataSource = self
        tbRoomManagement.register(UINib(nibName: "ListRoomsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListRoomsTableViewCell")
        
        setUpView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set up view
    func setUpView() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            return
        }
        
        dbReference = Database.database().reference()
        dbReference.child("Users").child(uid).observe(.value) { (snapshot) in
            
            // Get user value
            let value = snapshot.value as! NSDictionary
            let userName = value["FullName"] as? String ?? ""
            let profileImageUrl = value["ProfileImageUrl"] as? String ?? ""
            
            self.lblUserFullName.text = userName
            self.ivAvatar.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    
    //MARK: Logic for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbRoomManagement.dequeueReusableCell(withIdentifier: "ListRoomsTableViewCell") as! ListRoomsTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblRoom.text = "Phòng 101"
            cell.lblRoomPrice.text = "4.000.000"
            cell.lblUserFullName.text = "Nguyễn Cao Cường"
        case 1:
            cell.lblRoom.text = "Phòng 102"
            cell.lblRoomPrice.text = "3.000.000"
            cell.lblUserFullName.text = "Nguyễn Lùn Cường"
        case 2:
            cell.lblRoom.text = "Phòng 103"
            cell.lblRoomPrice.text = "7.000.000"
            cell.lblUserFullName.text = "Nguyễn Thấp Cường"
        case 3:
            cell.lblRoom.text = "Phòng 104"
            cell.lblRoomPrice.text = "1.000.000"
            cell.lblUserFullName.text = "Nguyễn Siêu Cường"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnCreateRoomPressed(_ sender: Any) {
        let vc = CreateRoomViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
 
}
