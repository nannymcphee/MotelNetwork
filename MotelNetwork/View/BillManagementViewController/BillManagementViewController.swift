//
//  BillManagementViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/19/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher


class BillManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var vEmptyData: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tbBills: UITableView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblBillsCount: UILabel!
    
    var listBill = [Bill]()
    var billsCount : Int = 0
    var timestampStr: String = ""
    var userType: Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbBills.delegate = self
        tbBills.dataSource = self
        tbBills.register(UINib(nibName: "ListBillTableViewCell", bundle: nil), forCellReuseIdentifier: "ListBillTableViewCell")
        tbBills.reloadData()
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tbBills.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshData() {
        
        listBill.removeAll()
        
        if self.userType == 0 {
            loadDataForOwner()
        }
        else {
            loadDataForRenter()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func showEmptyDataView() {
        
        if listBill.count == 0 {
            vEmptyData.isHidden = false
        }
        else {
            vEmptyData.isHidden = true
        }
    }
    
    //MARK: Set up view
    func setUpView() {
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tbBills.refreshControl = refreshControl
        }
        else {
            tbBills.addSubview(refreshControl)
        }
        
        fetchUser()
        makeImageViewRounded(imageView: ivAvatar)
        vEmptyData.isHidden = true
        showEmptyDataView()
    }
    
    //MARK: Database interaction
    
    func fetchUser() {
        
        let reference = Database.database().reference().child("Users").child(uid!)
        reference.observe(.value) { (snapshot) in
            
            // Get user value
            let dictionary = snapshot.value as! NSDictionary
            let userName = dictionary["FullName"] as? String ?? ""
            let profileImageUrl = dictionary["ProfileImageUrl"] as? String ?? ""
            
            self.userType = (dictionary["UserType"] as? Int)!
            
            if self.userType == 0 {
                self.loadDataForOwner()
            }
            else if self.userType == 1 {
                self.loadDataForRenter()
            }
            
            self.lblUserFullName.text = userName
            let resource = ImageResource(downloadURL: URL(string: profileImageUrl)!)
            self.ivAvatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "defaultAvatar"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    func loadDataForOwner() {
        
        let ref = Database.database().reference()
        let myRecentBillsQuery = ref.child("Bills").queryOrdered(byChild: "ownerID").queryEqual(toValue: uid).queryLimited(toFirst: 100)
        
        myRecentBillsQuery.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let bill = Bill(dictionary: dictionary)
                bill.id = snapshot.key
                
                DispatchQueue.main.async {
                    self.reloadInputViews()
                }

                bill.roomPrice = dictionary["roomPrice"] as? Double
                bill.waterPrice = dictionary["waterPrice"] as? Double
                bill.electricPrice = dictionary["electricPrice"] as? Double
                bill.internetPrice = dictionary["internetPrice"] as? Double
                bill.totalElectricPrice = dictionary["totalElectricPrice"] as? Double
                bill.totalWaterPrice = dictionary["totalWaterPrice"] as? Double
                bill.totalRoomPrice = dictionary["totalRoomPrice"] as? Double
                bill.surcharge = dictionary["surcharge"] as? Double
                bill.userCount = dictionary["userCount"] as? Double
                bill.oldElectricNumber = dictionary["oldElectricNumber"] as? Double
                bill.newElectricNumber = dictionary["newElectricNumber"] as? Double
                bill.ownerID = dictionary["ownerID"] as? String
                bill.renterID = dictionary["renterID"] as? String
                bill.roomID = dictionary["roomID"] as? String
                bill.surchargeReason = dictionary["surchargeReason"] as? String
                bill.timestamp = dictionary["timestamp"] as? Int
   
                self.listBill.append(bill)
                self.listBill = self.listBill.sorted(by: { (bill0, bill1) -> Bool in
                    return bill0.timestamp! > bill1.timestamp!
                })
                self.billsCount = self.listBill.count
                self.lblBillsCount.text = "\(self.billsCount)"
                self.tbBills.reloadData()
            }
        }, withCancel: nil)
    }
    
    func loadDataForRenter() {
        
        let ref = Database.database().reference()
        let myRecentBillsQuery = ref.child("Bills").queryOrdered(byChild: "renterID").queryEqual(toValue: uid).queryLimited(toFirst: 100)
        
        myRecentBillsQuery.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let bill = Bill(dictionary: dictionary)
                bill.id = snapshot.key
                
                DispatchQueue.main.async {
                    self.reloadInputViews()
                }
                
                bill.roomPrice = dictionary["roomPrice"] as? Double
                bill.waterPrice = dictionary["waterPrice"] as? Double
                bill.electricPrice = dictionary["electricPrice"] as? Double
                bill.internetPrice = dictionary["internetPrice"] as? Double
                bill.totalElectricPrice = dictionary["totalElectricPrice"] as? Double
                bill.totalWaterPrice = dictionary["totalWaterPrice"] as? Double
                bill.totalRoomPrice = dictionary["totalRoomPrice"] as? Double
                bill.surcharge = dictionary["surcharge"] as? Double
                bill.userCount = dictionary["userCount"] as? Double
                bill.oldElectricNumber = dictionary["oldElectricNumber"] as? Double
                bill.newElectricNumber = dictionary["newElectricNumber"] as? Double
                bill.ownerID = dictionary["ownerID"] as? String
                bill.renterID = dictionary["renterID"] as? String
                bill.roomID = dictionary["roomID"] as? String
                bill.surchargeReason = dictionary["surchargeReason"] as? String
                bill.timestamp = dictionary["timestamp"] as? Int
                
                self.listBill.append(bill)
                self.listBill = self.listBill.sorted(by: { (bill0, bill1) -> Bool in
                    return bill0.timestamp! > bill1.timestamp!
                })
                self.billsCount = self.listBill.count
                self.lblBillsCount.text = "\(self.billsCount)"
                self.tbBills.reloadData()
            }
        }, withCancel: nil)
    }
    
    //MARK: Logic for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBill.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbBills.dequeueReusableCell(withIdentifier: "ListBillTableViewCell") as! ListBillTableViewCell
        
        let bill = listBill[indexPath.row]
        cell.populateData(bill: bill)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bill = listBill[indexPath.row]
        let vc = DetailBillViewController()
        
        vc.currentBill = bill
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        var config = UISwipeActionsConfiguration(actions: [delete, edit])
        
        if self.userType == 0 {
            config = UISwipeActionsConfiguration(actions: [delete, edit])
        }
        else if self.userType == 1 {
            config = UISwipeActionsConfiguration(actions: [])
        }

        config.performsFirstActionWithFullSwipe = false

        return config
    }

    func editAction(at indexPath: IndexPath) -> UIContextualAction {

        let bill = self.listBill[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "") { (action, view, nil) in

            let vc = EditBillViewController()
            vc.currentBill = bill
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController?.pushViewController(vc, animated: true)
        }

        action.image = #imageLiteral(resourceName: "icEdit")
        action.backgroundColor = UIColor(red: 34/255, green: 119/255, blue: 233/255, alpha: 1.0)

        return action
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {

        let action = UIContextualAction(style: .destructive, title: "") { (action, view, nil) in

            // Query delete from database
            let bill = self.listBill[indexPath.row]
            let billID = bill.id
            let ref = Database.database().reference().child("Bills").child(billID!)

            // Show confirmation alert
            let alert = UIAlertController(title: messageConfirmDeleteBill, message: nil, preferredStyle: .actionSheet)
            let actionDestroy = UIAlertAction(title: "Xóa", style: .destructive) { (action) in
                self.deleteData(reference: ref)
                self.listBill.remove(at: indexPath.row)
                self.tbBills.deleteRows(at: [indexPath], with: .automatic)
                self.tbBills.reloadData()
                self.billsCount = self.listBill.count
                self.lblBillsCount.text = "\(self.billsCount)"
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
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
}

