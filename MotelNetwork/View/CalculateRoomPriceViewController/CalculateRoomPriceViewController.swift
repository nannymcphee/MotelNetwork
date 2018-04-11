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
    @IBOutlet weak var tfElectricPrice: UITextField!
    @IBOutlet weak var tfWaterPrice: UITextField!
    @IBOutlet weak var tfInternetPrice: UITextField!
    @IBOutlet weak var tfOtherPrice: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToDismissKeyboard()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    //MARK: Handle button pressed
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnCalculatePressed(_ sender: Any) {
        
        //Do calculate
    }
    
}
