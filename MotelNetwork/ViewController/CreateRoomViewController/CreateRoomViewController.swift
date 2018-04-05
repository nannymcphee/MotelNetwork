//
//  CreateRoomViewController.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/5/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController {

    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var tfRoomName: UITextField!
    @IBOutlet weak var tfArea: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var ivRoomImage: UIImageView!
    @IBOutlet weak var ivRoomImage1: UIImageView!
    @IBOutlet weak var ivRoomImage2: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
    
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
    
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
