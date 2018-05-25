//
//  CalculateRoomPriceViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/11/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CalculateRoomPriceViewController: UIViewController {
    
    @IBOutlet weak var btnCalculate: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var tfRoomPrice: UITextField!
    @IBOutlet weak var tfWaterPrice: UITextField!
    @IBOutlet weak var tfInternetPrice: UITextField!
    @IBOutlet weak var tfSurcharge: UITextField!
    @IBOutlet weak var tfNewElectricNumber: UITextField!
    @IBOutlet weak var tfOldElectricNumber: UITextField!
    @IBOutlet weak var tfElectricPrice: UITextField!
    @IBOutlet weak var tfUserCount: UITextField!
    @IBOutlet weak var tfUser: UITextField!
    @IBOutlet weak var tfSurchargeReason: UITextField!
    
    var currentRoom = Room()
    var roomPrice: Double = 0.0
    
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
        
        roomPrice = currentRoom.price!
        lblRoomName.text = currentRoom.name
        tfRoomPrice.text = "\(roomPrice)"
        
        if let renterID = currentRoom.renterID {
            
            let ref = Database.database().reference().child("Users").child(renterID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let renterName = dictionary["FullName"] as? String
                    self.tfUser.text = renterName
                }
            }, withCancel: nil)
        }
        
        tfUser.isEnabled = false
        tfRoomPrice.isEnabled = false
        self.tapToDismissKeyboard()
    }
    
    func resetView() {
        tfSurcharge.text = nil
        tfOldElectricNumber.text = nil
        tfNewElectricNumber.text = nil
        tfElectricPrice.text = nil
        tfWaterPrice.text = nil
        tfUserCount.text = nil
        tfInternetPrice.text = nil
        tfSurchargeReason.text = nil
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCalculatePressed(_ sender: Any) {
        
        let surchargeReason = tfSurchargeReason.text!
        let ownerID = currentRoom.ownerID!
        let renterID = currentRoom.renterID!
        let roomID = currentRoom.id!
        let roomPrice = currentRoom.price!
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let bill = Bill()
        
        bill.roomPrice = roomPrice
        bill.surcharge = (tfSurcharge.text?.toDouble)!
        bill.internetPrice = (tfInternetPrice.text?.toDouble)!
        bill.waterPrice = (tfWaterPrice.text?.toDouble)!
        bill.userCount = (tfUserCount.text?.toDouble)!
        bill.electricPrice = (tfElectricPrice.text?.toDouble)!
        bill.oldElectricNumber = (tfOldElectricNumber.text?.toDouble)!
        bill.newElectricNumber = (tfNewElectricNumber.text?.toDouble)!
        
        let oldElectricNumber = bill.oldElectricNumber!
        let newElectricNumber = bill.newElectricNumber!
        let userCount = Int(bill.userCount!)
        
        if bill.electricPrice == 0 || bill.newElectricNumber == 0 || bill.oldElectricNumber == 0 || bill.waterPrice == 0 || bill.internetPrice == 0 {
            
            showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
        }
        else if oldElectricNumber > newElectricNumber {
            
            showAlert(title: "Thông báo", alertMessage: "Công suất cũ phải nhỏ hơn công suất mới.")
        }
        else if userCount <= 0 {
            
            showAlert(title: "Thông báo", alertMessage: "Số người phải lớn hơn 0.")
        }
        else {

            let totalPrice: Double = self.calculateBill(bill: bill)
            let ref = Database.database().reference().child("Bills").childByAutoId()
            let values = ["roomID": roomID, "ownerID": ownerID, "renterID": renterID, "electricPrice": bill.electricPrice!, "waterPrice": bill.waterPrice!, "internetPrice": bill.internetPrice!, "oldElectricNumber": bill.oldElectricNumber!, "newElectricNumber": bill.newElectricNumber!, "userCount": bill.userCount!, "surcharge": bill.surcharge!, "timestamp": timestamp, "surchargeReason": surchargeReason, "totalRoomPrice": totalPrice, "totalWaterPrice": bill.totalWaterPrice!, "totalElectricPrice": bill.totalElectricPrice!, "roomPrice": bill.roomPrice!] as [String: AnyObject]

            self.storeInformationToDatabase(reference: ref, values: values)
            
            NativePopup.show(image: Preset.Feedback.done, title: messageCreateBillSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
            resetView()
            
            return
        }
        
    }

}

