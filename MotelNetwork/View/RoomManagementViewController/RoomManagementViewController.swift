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
    
    @IBOutlet weak var vEmptyData: UIView!
    @IBOutlet weak var btnCreateRoom: UIButton!
    @IBOutlet weak var btnBills: UIButton!
    @IBOutlet weak var tbRoomManagement: UITableView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblRoomCount: UILabel!
    
    @IBOutlet weak var vInfoView: UIView!
    @IBOutlet weak var svScrollView: UIScrollView!
    
    var dbReference: DatabaseReference!
    var listRooms = [Room]()
    var roomsCount: Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tbRoomManagement.delegate = self
        tbRoomManagement.dataSource = self
        tbRoomManagement.register(UINib(nibName: "ListRoomsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListRoomsTableViewCell")
        tbRoomManagement.reloadData()

        loadData()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tbRoomManagement.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshData() {
        
        listRooms.removeAll()
        loadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func showEmptyDataView() {
        
        if listRooms.count == 0 {
            tbRoomManagement.backgroundView = vEmptyData
        }
        else {
            tbRoomManagement.backgroundView = nil
        }
    }
    
    //MARK: Set up view
    func setUpView() {
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbRoomManagement.refreshControl = refreshControl
        }
        else {
            tbRoomManagement.addSubview(refreshControl)
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
        showEmptyDataView()
    }
    
    //MARK: Database interaction
    
    func loadData() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let queryMyRoomsOrderByRoomName = ref.child("Rooms").queryOrdered(byChild: "ownerID").queryEqual(toValue: uid)
        
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
                self.listRooms = self.listRooms.sorted(by: { (room0, room1) -> Bool in
                    return room0.name?.localizedStandardCompare(room1.name!) == .orderedAscending
                })
                self.roomsCount = self.listRooms.count
                self.lblRoomCount.text = "\(self.roomsCount)"
                self.tbRoomManagement.reloadData()
            }
        }, withCancel: nil)
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnCreateRoomPressed(_ sender: Any) {
        
        let vc = CreateRoomViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBillsPressed(_ sender: Any) {
        
        let vc = BillManagementViewController()
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }

}

extension RoomManagementViewController {
    
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
        
        let room = listRooms[indexPath.row]
        let vc = DetailRoomViewController()
        
        vc.currentRoom = room
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        let calculate = calculateAction(at: indexPath)
        let config = UISwipeActionsConfiguration(actions: [delete, edit, calculate])
        
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    // Swipe actions
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let room = listRooms[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "") { (action, view, nil) in
            
            let vc = EditRoomViewController()
            vc.currentRoom = room
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        action.image = #imageLiteral(resourceName: "icEdit")
        action.backgroundColor = UIColor(red: 34/255, green: 119/255, blue: 233/255, alpha: 1.0)
        
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "") { (action, view, nil) in
            
            // Query delete from database
            let room = self.listRooms[indexPath.row]
            let roomID = room.id
            
            let ref = Database.database().reference().child("Rooms").child(roomID!)
            
            // Show confirmation alert
            let alert = UIAlertController(title: messageConfirmDeleteRoom, message: nil, preferredStyle: .actionSheet)
            let actionDestroy = UIAlertAction(title: "Xóa", style: .destructive) { (action) in
                self.deleteData(reference: ref)
                self.listRooms.remove(at: indexPath.row)
                self.tbRoomManagement.deleteRows(at: [indexPath], with: .automatic)
                self.tbRoomManagement.reloadData()
                self.roomsCount = self.listRooms.count
                self.lblRoomCount.text = "\(self.roomsCount)"
            }
            
            let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(actionDestroy)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        action.image = #imageLiteral(resourceName: "icDelete")
        
        return action
    }
    
    func calculateAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let room = listRooms[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "") { (action, view, nil) in
            
            let vc = CalculateRoomPriceViewController()
            vc.currentRoom = room
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController?.pushViewController(vc, animated: true)
        }
        
        action.image = #imageLiteral(resourceName: "icCalculator")
        action.backgroundColor = UIColor(red: 75/255, green: 151/255, blue: 253/255, alpha: 1.0)
        return action
    }
}
