//
//  MyRoomsViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/29/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class MyRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblRoomCount: UILabel!
    @IBOutlet weak var tbMyRooms: UITableView!
    
    var dbReference: DatabaseReference!
    var listRooms = [Room]()
    var roomsCount: Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbMyRooms.delegate = self
        tbMyRooms.dataSource = self
        tbMyRooms.register(UINib(nibName: "ListRoomsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListRoomsTableViewCell")
        tbMyRooms.reloadData()
        
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        listRooms.removeAll()
        loadData()
        tbMyRooms.reloadData()
    }
    
    @objc func refreshData() {
        
        listRooms.removeAll()
        loadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: Set up view
    func setUpView() {
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbMyRooms.refreshControl = refreshControl
        }
        else {
            tbMyRooms.addSubview(refreshControl)
        }
        
        // Fetch user from database
        
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
        let ref = Database.database().reference()
        let queryMyRoomsOrderByRoomName = ref.child("Rooms").queryOrdered(byChild: "renterID").queryEqual(toValue: uid)
        
        queryMyRoomsOrderByRoomName.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let room = Room(dictionary: dictionary)
                room.id = snapshot.key
                
                DispatchQueue.main.async(execute: {
                    self.reloadInputViews()
                })
                
                room.name = dictionary["roomName"] as? String
                let priceStr = dictionary["price"] as? String
                room.price = Double(priceStr ?? "0.0")
                room.area = dictionary["area"] as? String
                room.renterID = dictionary["renterID"] as? String
                room.ownerID = dictionary["ownerID"] as? String
                room.roomImageUrl0 = dictionary["roomImageUrl0"] as? String
                room.roomImageUrl1 = dictionary["roomImageUrl1"] as? String
                room.roomImageUrl2 = dictionary["roomImageUrl2"] as? String
                room.usersAllowed = dictionary["usersAllowed"] as? String
                
                self.listRooms.append(room)
                self.roomsCount = self.listRooms.count
                self.lblRoomCount.text = "Số phòng: \(self.roomsCount)"
                self.tbMyRooms.reloadData()
            }
        }, withCancel: nil)
    }

}

extension MyRoomsViewController {
    
    //MARK: Logic for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbMyRooms.dequeueReusableCell(withIdentifier: "ListRoomsTableViewCell") as! ListRoomsTableViewCell
        
        let room = listRooms[indexPath.row]
        cell.populateDataForRenter(room: room)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let room = listRooms[indexPath.row]
        let vc = DetailRoomViewController()
        
        vc.currentRoom = room
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}


