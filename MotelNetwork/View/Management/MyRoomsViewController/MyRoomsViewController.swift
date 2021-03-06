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
import ObjectMapper

class MyRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnBills: UIButton!
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
        
        loadData2()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tbMyRooms.reloadData()
    }
    
    @objc func refreshData() {
        
        listRooms.removeAll()
        loadData2()
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
            
            self.lblUserFullName.text = userName
            self.loadImageToImageView(imageUrl: profileImageUrl, imageView: self.ivAvatar)
        }
        
        makeImageViewRounded(imageView: ivAvatar)
    }
    
    //MARK: Database interaction
    
    func loadData() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let queryMyRoomsOrderByRoomName = ref.child("Rooms").queryOrdered(byChild: "renterID").queryEqual(toValue: uid)
        
        queryMyRoomsOrderByRoomName.keepSynced(true)
        
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
                room.address = dictionary["address"] as? String
                
                self.listRooms.append(room)
                self.roomsCount = self.listRooms.count
                self.lblRoomCount.text = "Số phòng: \(self.roomsCount)"
                self.tbMyRooms.reloadData()
            }
        }, withCancel: nil)
    }
    
    func loadData2() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let queryMyRoomsOrderByRoomName = ref.child("Rooms").queryOrdered(byChild: "renterID").queryEqual(toValue: uid)
        
        queryMyRoomsOrderByRoomName.keepSynced(true)
        
        queryMyRoomsOrderByRoomName.observe(.childAdded) { (snapshot) in
            if let json = snapshot.value as? [String: AnyObject] {
                var room = Room()
                
                room = Mapper<Room>().map(JSON: json) ?? Room()
                
                self.listRooms.append(room)
                self.roomsCount = self.listRooms.count
                
                DispatchQueue.main.async {
                    self.lblRoomCount.text = "Số phòng: \(self.roomsCount)"
                    self.tbMyRooms.reloadData()
                }
            }
        }
    }

    @IBAction func btnBillsPressed(_ sender: Any) {
        
        let vc = BillManagementViewController()
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MyRoomsViewController {
    
    //MARK: Logic for UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if listRooms.isEmpty {
            
            tbMyRooms.showEmptyDataView(message: messageEmptyRoom, image: #imageLiteral(resourceName: "icEmptyRoom"))
        }
        else {
            
            tbMyRooms.backgroundView = nil
            
            return 1
        }
        
        return 1
    }
    
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
        return 165
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let room = listRooms[indexPath.row]
        let vc = DetailRoomViewController()
        
        vc.currentRoom = room
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
}


