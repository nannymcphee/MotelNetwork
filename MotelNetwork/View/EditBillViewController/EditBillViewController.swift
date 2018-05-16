//
//  EditBillViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 5/9/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EditBillViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
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
    
    var currentBill = Bill()
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
        
        if let roomID = currentBill.roomID {
            let ref = Database.database().reference().child("Rooms").child(roomID)
            
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {

                    self.lblRoomName.text = dictionary["roomName"] as? String
                }
            }, withCancel: nil)
        }
        
        if let renterID = currentBill.renterID {
            let ref = Database.database().reference().child("Users").child(renterID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.tfUser.text = dictionary["FullName"] as? String
                }
            }, withCancel: nil)
        }
        
        self.roomPrice = currentBill.roomPrice!
        tfRoomPrice.text = "\(currentBill.roomPrice!)"
        tfElectricPrice.text = "\(currentBill.electricPrice!)"
        tfOldElectricNumber.text = "\(currentBill.oldElectricNumber!)"
        tfNewElectricNumber.text = "\(currentBill.newElectricNumber!)"
        tfWaterPrice.text = "\(currentBill.waterPrice!)"
        tfUserCount.text = "\(currentBill.userCount!)"
        tfInternetPrice.text = "\(currentBill.internetPrice!)"
        tfSurcharge.text = "\(currentBill.surcharge!)"
        tfSurchargeReason.text = currentBill.surchargeReason
        tfUser.isEnabled = false
        tfRoomPrice.isEnabled = false
        self.tapToDismissKeyboard()
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
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        electricPrice = (tfElectricPrice.text?.toDouble)!
        newElectricNumber = (tfNewElectricNumber.text?.toDouble)!
        oldElectricNumber = (tfOldElectricNumber.text?.toDouble)!
        waterPrice = (tfWaterPrice.text?.toDouble)!
        userCount = (tfUserCount.text?.toDouble)!
        internetPrice = (tfInternetPrice.text?.toDouble)!
        surcharge = (tfSurcharge.text?.toDouble)!
        totalPrice = calculateRoomPrice()
        
        let billID = currentBill.id
        let timestampEdit = Int(NSDate().timeIntervalSince1970)
        let surchargeReason = tfSurchargeReason.text!
        let ref = Database.database().reference().child("Bills").child(billID!)
        let values = ["electricPrice": electricPrice, "waterPrice": waterPrice, "internetPrice": internetPrice, "oldElectricNumber": oldElectricNumber, "newElectricNumber": newElectricNumber, "userCount": userCount, "surcharge": surcharge, "timestampEdit": timestampEdit, "surchargeReason": surchargeReason, "totalRoomPrice": totalPrice, "totalWaterPrice": totalWaterPrice, "totalElectricPrice": totalElectricPrice, "roomPrice": roomPrice] as [String: AnyObject]
        
        //Create confirm alert
        let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
        let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
            
            if self.electricPrice == 0 || self.newElectricNumber == 0 || self.oldElectricNumber == 0 || self.waterPrice == 0 || self.internetPrice == 0 {
                
                self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
            }
            else if self.oldElectricNumber > self.newElectricNumber {
                
                self.showAlert(title: "Thông báo", alertMessage: "Công suất cũ phải nhỏ hơn công suất mới.")
            }
            else if self.userCount <= 0 {
                
                self.showAlert(title: "Thông báo", alertMessage: "Số người phải lớn hơn 0.")
            }
            else {
                
                self.editData(reference: ref, newValues: values)
            }
            self.noticeSuccess(messageEditInfoSuccess, autoClear: true, autoClearTime: 1)
            return
        }
        
        alert.addAction(actionDestroy)
        alert.addAction(actionCancel)

        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    
}
