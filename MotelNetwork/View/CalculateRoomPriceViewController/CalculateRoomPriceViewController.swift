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
    var oldElectricNumber: Double = 0.0
    var newElectricNumber: Double = 0.0
    var electricPrice: Double = 0.0
    var waterPrice: Double = 0.0
    var userCount: Double = 0.0
    var internetPrice: Double = 0.0
    var surcharge: Double = 0.0
    var totalWaterPrice: Double = 0.0
    var totalElectricPrice: Double = 0.0
    var totalPrice: Double = 0.0
    let billID = UUID().uuidString
    
    
    
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
        tfRoomPrice.text = "\(currentRoom.price ?? 0.0)"
        
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
    
    //MARK: Do calculation
    
    func calculateRoomPrice() -> Double {
        
        totalWaterPrice = waterPrice * userCount
        totalElectricPrice = electricPrice * (newElectricNumber - oldElectricNumber)
        totalPrice = roomPrice + totalWaterPrice + totalElectricPrice + internetPrice + surcharge
        
        return totalPrice
    }
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnCalculatePressed(_ sender: Any) {

        electricPrice = (tfElectricPrice.text?.toDouble)!
        newElectricNumber = (tfNewElectricNumber.text?.toDouble)!
        oldElectricNumber = (tfOldElectricNumber.text?.toDouble)!
        waterPrice = (tfWaterPrice.text?.toDouble)!
        userCount = (tfUserCount.text?.toDouble)!
        internetPrice = (tfInternetPrice.text?.toDouble)!
        surcharge = (tfSurcharge.text?.toDouble)!
        
//        showLoading()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//            self.stopLoading()
//            self.showAlertNavigateToDetailBill()
//        }
        
        if electricPrice == 0 || newElectricNumber == 0 || oldElectricNumber == 0 || waterPrice == 0 || internetPrice == 0 {
            
            showAlert(alertMessage: messageNilTextFields)
        }
        else if oldElectricNumber > newElectricNumber {
            
            showAlert(alertMessage: "Công suất cũ phải nhỏ hơn công suất mới.")
        }
        else if userCount <= 0 {
            showAlert(alertMessage: "Số người phải lớn hơn 0.")
        }
        else {
            
            totalPrice = calculateRoomPrice()

            let surchargeReason = tfSurchargeReason.text!
            let ownerID = currentRoom.ownerID
            let renterID = currentRoom.renterID
            let roomID = currentRoom.id
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let roomPrice = currentRoom.price
            
            let ref = Database.database().reference().child("Bills").childByAutoId()
            let values = ["roomID": roomID ?? "", "ownerID": ownerID ?? "", "renterID": renterID ?? "", "electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "oldElectricNumber": oldElectricNumber, "newElectricNumber": newElectricNumber, "userCount": userCount, "surcharge": surcharge, "timestamp": timestamp, "surchargeReason": surchargeReason, "totalRoomPrice": totalPrice, "totalWaterPrice": totalWaterPrice, "totalElectricPrice": totalElectricPrice, "roomPrice": roomPrice ?? ""] as [String: AnyObject]

            self.storeInformationToDatabase(reference: ref, values: values)
            
            showAlert(alertMessage: messageCreateBillSuccess)
            resetView()
            return
        }
        
    }

}


extension String {
    var toDouble: Double {
        return Double(self) ?? 0
    }
}
