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
    
    //MARK: Handle button pressed

    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        let bill = Bill()
        
        bill.roomPrice = self.roomPrice
        bill.electricPrice = (tfElectricPrice.text?.toDouble)!
        bill.newElectricNumber = (tfNewElectricNumber.text?.toDouble)!
        bill.oldElectricNumber = (tfOldElectricNumber.text?.toDouble)!
        bill.waterPrice = (tfWaterPrice.text?.toDouble)!
        bill.userCount = (tfUserCount.text?.toDouble)!
        bill.internetPrice = (tfInternetPrice.text?.toDouble)!
        bill.surcharge = (tfSurcharge.text?.toDouble)!
        
        let billID = currentBill.id
        let oldElectricNumber = bill.oldElectricNumber!
        let newElectricNumber = bill.newElectricNumber!
        let userCount = Int(bill.userCount!)
        let timestampEdit = Int(NSDate().timeIntervalSince1970)
        let surchargeReason = tfSurchargeReason.text!
        
        
        //Create confirm alert
        let alert = UIAlertController(title: "Thông báo", message: messageConfirmEditData, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Không", style: .cancel) { (action) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
        let actionDestroy = UIAlertAction(title: "Có", style: .destructive) { (action) in
            
            if bill.electricPrice == 0 || bill.newElectricNumber == 0 || bill.oldElectricNumber == 0 || bill.waterPrice == 0 || bill.internetPrice == 0 {
                
                self.showAlert(title: "Thông báo", alertMessage: messageNilTextFields)
            }
            else if oldElectricNumber > newElectricNumber {
                
                self.showAlert(title: "Thông báo", alertMessage: "Công suất cũ phải nhỏ hơn công suất mới.")
            }
            else if userCount <= 0 {
                
                self.showAlert(title: "Thông báo", alertMessage: "Số người phải lớn hơn 0.")
            }
            else {
                
                let totalPrice = self.calculateBill(bill: bill)
                let ref = Database.database().reference().child("Bills").child(billID!)
                let values = ["electricPrice": bill.electricPrice as AnyObject, "waterPrice": bill.waterPrice as AnyObject, "internetPrice": bill.internetPrice as AnyObject, "oldElectricNumber": bill.oldElectricNumber as AnyObject, "newElectricNumber": bill.newElectricNumber as AnyObject, "userCount": bill.userCount as AnyObject, "surcharge": bill.surcharge as AnyObject, "timestampEdit": timestampEdit as AnyObject, "surchargeReason": surchargeReason as AnyObject, "totalRoomPrice": totalPrice, "totalWaterPrice": bill.totalWaterPrice!, "totalElectricPrice": bill.totalElectricPrice!, "roomPrice": bill.roomPrice!] as [String: AnyObject]
                
                self.editData(reference: ref, newValues: values)
                
                NativePopup.show(image: Preset.Feedback.done, title: messageEditBillSuccess, message: nil, duration: 1.5, initialEffectType: .fadeIn)
            }

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
