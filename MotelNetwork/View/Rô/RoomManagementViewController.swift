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
import SwipeBack
import Kingfisher


class RoomManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var btnCreateRoom: UIButton!
    @IBOutlet weak var tbRoomManagement: UITableView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblRoomCount: UILabel!
    
    
    var dbReference: DatabaseReference!
    var listRooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbRoomManagement.delegate = self
        tbRoomManagement.dataSource = self
        tbRoomManagement.register(UINib(nibName: "ListRoomsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListRoomsTableViewCell")
        tbRoomManagement.reloadData()


        loadData()
        setUpView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tbRoomManagement.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            let resource = ImageResource(downloadURL: URL(string: profileImageUrl)!)
            
            self.lblUserFullName.text = userName
            self.ivAvatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    
    
    //MARK: Database interaction
    
    func loadData() {
        
        let uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("Rooms").child(uid!).child("MyRooms").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let room = Room(dictionary: dictionary)
                room.id = snapshot.key
                self.listRooms.append(room)
                
                DispatchQueue.main.async(execute: {
                    self.reloadInputViews()
                })
                
                room.name = dictionary["RoomName"] as? String
                let priceStr = dictionary["Price"] as? String
                room.price = Double(priceStr ?? "0.0")
                room.area = dictionary["Area"] as? String
                room.user = dictionary["User"] as? String
                room.roomImageUrl0 = dictionary["roomImageUrl0"] as? String
            }
        }, withCancel: nil)
    }
    
    //MARK: Logic for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listRooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbRoomManagement.dequeueReusableCell(withIdentifier: "ListRoomsTableViewCell") as! ListRoomsTableViewCell
        
        let room = listRooms[indexPath.row]
        cell.populateData(room: room)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailRoomViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: Handle button pressed
    
    @IBAction func btnCreateRoomPressed(_ sender: Any) {
        let vc = CreateRoomViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)

    }
    
 
}
