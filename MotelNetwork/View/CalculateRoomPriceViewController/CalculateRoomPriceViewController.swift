//
//  CalculateRoomPriceViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/11/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class CalculateRoomPriceViewController: UIViewController {
    
    @IBOutlet weak var btnCalculate: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var tfRoomPrice: UITextField!
    @IBOutlet weak var tfWaterPrice: UITextField!
    @IBOutlet weak var tfInternetPrice: UITextField!
    @IBOutlet weak var tfOtherPrice: UITextField!
    @IBOutlet weak var tfNewElectricNumber: UITextField!
    @IBOutlet weak var tfOldElectricNumber: UITextField!
    @IBOutlet weak var tfElectricPrice: UITextField!
    @IBOutlet weak var tfUserCount: UITextField!
    @IBOutlet weak var tfUser: UITextField!
    
    var currentRoom = Room()
    var roomPrice: Double = 0.0
    var oldElectricNumber: Double = 0.0
    var newElectricNumber: Double = 0.0
    var electricPrice: Double = 0.0
    var waterPrice: Double = 0.0
    var userCount: Double = 0.0
    var internetPrice: Double = 0.0
    var otherPrice: Double = 0.0
    var totalWaterPrice: Double = 0.0 // = waterPrice * userCount
    var totalElectricPrice: Double = 0.0 // = electricPrice * (newElectricNumber - oldElectricNumber)
    var totalPrice: Double = 0.0 // = roomPrice + totalWaterPrice + totalElectricPrice + internetPrice + otherPrice
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToDismissKeyboard()
        setUpView()

        // Do any additional setup after loading the view.
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
        tfUser.text = currentRoom.user
        tfUser.isEnabled = false
        tfRoomPrice.isEnabled = false
    }
    
    func resetView() {
        tfOtherPrice.text = nil
        tfOldElectricNumber.text = nil
        tfNewElectricNumber.text = nil
        tfElectricPrice.text = nil
        tfWaterPrice.text = nil
        tfUserCount.text = nil
        tfInternetPrice.text = nil
    }
    
    //MARK: Do calculation
    
    func calculateRoomPrice() -> Double {
        
        totalWaterPrice = waterPrice * userCount
        totalElectricPrice = electricPrice * (newElectricNumber - oldElectricNumber)
        totalPrice = roomPrice + totalWaterPrice + totalElectricPrice + internetPrice + otherPrice
        
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
        otherPrice = (tfOtherPrice.text?.toDouble)!
        
        if tfElectricPrice.text == nil || tfNewElectricNumber.text == nil || tfOldElectricNumber.text == nil || tfWaterPrice.text == nil || tfUserCount.text == nil || tfInternetPrice.text == nil {
            
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
            
            numberFormatter.numberStyle = .decimal
            var priceStr = String(totalPrice)
            var roomPriceStr = String(roomPrice)
            var totalWaterPriceStr = String(totalWaterPrice)
            var totalElectricPriceStr = String(totalElectricPrice)
            var internetPriceStr = String(internetPrice)
            var otherPriceStr = String(otherPrice)
            priceStr = numberFormatter.string(from: totalPrice as NSNumber)!
            roomPriceStr = numberFormatter.string(from: roomPrice as NSNumber)!
            totalWaterPriceStr = numberFormatter.string(from: totalWaterPrice as NSNumber)!
            totalElectricPriceStr = numberFormatter.string(from: totalElectricPrice as NSNumber)!
            internetPriceStr = numberFormatter.string(from: internetPrice as NSNumber)!
            otherPriceStr = numberFormatter.string(from: otherPrice as NSNumber)!
            
            showAlert(alertMessage: "Tiền phòng là: \(priceStr)đ. Chi tiết:\nTiền phòng: \(roomPriceStr)đ\nTiền điện: \(totalElectricPriceStr)đ\nTiền nước: \(totalWaterPriceStr)đ\nTiền internet: \(internetPriceStr)đ\nPhụ thu: \(otherPriceStr)đ")
            
            resetView()
        }
        return
    }
}


extension String {
    var toDouble: Double {
        return Double(self) ?? 0
    }
}
