//
//  DetailBillViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/20/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DetailBillViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var lblRenterName: UILabel!
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblOldElectricNumber: UILabel!
    @IBOutlet weak var lblNewElectricNumber: UILabel!
    @IBOutlet weak var lblUserCount: UILabel!
    @IBOutlet weak var lblElectricNumberCount: UILabel!
    @IBOutlet weak var lblRoomPrice: UILabel!
    @IBOutlet weak var lblInternetPrice: UILabel!
    @IBOutlet weak var lblWaterPrice: UILabel!
    @IBOutlet weak var lblElectricPrice: UILabel!
    @IBOutlet weak var lblRoomPrice2: UILabel!
    @IBOutlet weak var lblInternetPrice2: UILabel!
    @IBOutlet weak var lblTotalWaterPrice: UILabel!
    @IBOutlet weak var lblTotalElectricPrice: UILabel!
    @IBOutlet weak var lblTotalRoomPrice: UILabel!
    @IBOutlet weak var lblSurcharge: UILabel!
    @IBOutlet weak var lblSurchargeReason: UILabel!
    
    var currentBill = Bill()

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
        
        var monthStr: String = ""
        var dateStr: String = ""
        let timestampDouble = Double(currentBill.timestamp!)
        let timestampDate = NSDate(timeIntervalSince1970: timestampDouble)
        let dateFormatter = DateFormatter()
        let dateFormatter2 = DateFormatter()
        
        dateFormatter.dateFormat = "MM"
        dateFormatter2.dateFormat = "dd/MM/yyyy"
        monthStr = dateFormatter.string(from: timestampDate as Date)
        dateStr = dateFormatter2.string(from: timestampDate as Date)
        self.lblDate.text = "Ngày lập: \(dateStr)"
        self.lblTitle.text = "Hoá đơn tháng \(monthStr)"
        
        if let roomID = currentBill.roomID {
            let ref = Database.database().reference().child("Rooms").child(roomID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.lblRoomName.text  = dictionary["roomName"] as? String
                }
            }, withCancel: nil)
        }
        
        if let ownerID = currentBill.ownerID {
            let ref = Database.database().reference().child("Users").child(ownerID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                   let ownerName = dictionary["FullName"] as? String
                   self.lblOwnerName.text = "Người lập: \(ownerName ?? "")"
                }
            }, withCancel: nil)
        }
        
        if let renterID = currentBill.renterID {
            let ref = Database.database().reference().child("Users").child(renterID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let renterName = dictionary["FullName"] as? String
                    self.lblRenterName.text = "Người thuê phòng: \(renterName ?? "")"
                }
            }, withCancel: nil)
        }
        
        let formattedRoomPrice = numberFormatter.string(from: currentBill.roomPrice! as NSNumber)
        let formattedInternetPrice = numberFormatter.string(from: currentBill.internetPrice! as NSNumber)
        let formattedWaterPrice = numberFormatter.string(from: currentBill.waterPrice! as NSNumber)
        let formattedElectricPrice = numberFormatter.string(from: currentBill.electricPrice! as NSNumber)
        let formattedTotalRoomPrice = numberFormatter.string(from: currentBill.totalRoomPrice! as NSNumber)
        let formattedTotalWaterPrice = numberFormatter.string(from: currentBill.totalWaterPrice! as NSNumber)
        let formattedTotalElectricPrice = numberFormatter.string(from: currentBill.totalElectricPrice! as NSNumber)
        let formattedSurcharge = numberFormatter.string(from: currentBill.surcharge! as NSNumber)
        let formattedOldElectricNumber = numberFormatter.string(from: currentBill.oldElectricNumber! as NSNumber)
        let formattedNewElectricNumber = numberFormatter.string(from: currentBill.newElectricNumber! as NSNumber)
        let electricNumberCount = currentBill.newElectricNumber! - currentBill.oldElectricNumber!
        let formattedElectricNumberCount = numberFormatter.string(from: electricNumberCount as NSNumber)
        let formattedUserCount = numberFormatter.string(from: currentBill.userCount! as NSNumber)
        
        lblRoomPrice.text = "\(formattedRoomPrice ?? "0")"
        lblInternetPrice.text = "\(formattedInternetPrice ?? "0")"
        lblWaterPrice.text = "\(formattedWaterPrice ?? "0")"
        lblElectricPrice.text = "\(formattedElectricPrice ?? "0")"
        lblTotalRoomPrice.text = "\(formattedTotalRoomPrice ?? "0")đ"
        lblTotalWaterPrice.text = "\(formattedTotalWaterPrice ?? "0")"
        lblTotalElectricPrice.text = "\(formattedTotalElectricPrice ?? "0")"
        lblOldElectricNumber.text = "CSC: \(formattedOldElectricNumber ?? "0") kWh"
        lblNewElectricNumber.text = "CSM: \(formattedNewElectricNumber ?? "0") kWh"
        lblElectricNumberCount.text = "\(formattedElectricNumberCount ?? "0") kWh"
        lblUserCount.text = "\(formattedUserCount ?? "0") người"
        lblSurcharge.text = "\(formattedSurcharge ?? "0")"
        if !(currentBill.surchargeReason?.isEmpty)! {
            lblSurchargeReason.text = "Lí do phụ thu: \(currentBill.surchargeReason ?? "")"
        }
        else {
            lblSurchargeReason.text = "Lí do phụ thu: Không có."
        }
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    

}
