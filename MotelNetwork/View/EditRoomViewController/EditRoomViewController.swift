//
//  EditRoomViewController.swift
//  Motel Network
//
//  Created by Nguyên Duy on 4/10/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import UIKit

class EditRoomViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var ivRoomImage0: UIImageView!
    @IBOutlet weak var ivRoomImage1: UIImageView!
    @IBOutlet weak var ivRoomImage2: UIImageView!
    @IBOutlet weak var tfRoomName: UITextField!
    @IBOutlet weak var tfArea: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfUser: UITextField!
    
    var currentRoom = Room()
    
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
    
    func setUpView() {
        tfArea.text = currentRoom.area
        tfUser.text = currentRoom.user
        tfPrice.text = "\(currentRoom.price ?? 0.0)"
        tfRoomName.text = currentRoom.name
    }
    

    //MARK: Handle button pressed
   
    @IBAction func btnBackPressed(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddImagePressed(_ sender: Any) {
        
        
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        
    }
    
    
}
