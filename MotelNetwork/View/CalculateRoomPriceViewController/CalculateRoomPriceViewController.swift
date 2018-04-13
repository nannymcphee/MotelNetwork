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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        
        //Do calculate
    }
    
}
